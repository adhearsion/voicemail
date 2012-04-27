require 'spec_helper'

module Voicemail
  describe MailboxController do
    
    let(:call) { flexmock('Call') }
    let(:config) { Voicemail::Plugin.config }
    let(:metadata) do 
      { :mailbox => '100' }
    end
    let(:mailbox) do
      {
        :id => 100,
        :pin => 1234,
        :greeting_message => nil,
        :send_email => true,
        :email_address => "lpradovera@mojolingo.com"
      }
    end
    let(:storage_instance) { flexmock('StorageInstance') }

    let(:controller){ Voicemail::MailboxController.new call, metadata }
    subject { flexmock controller }
    
    before(:each) do
      storage_instance.should_receive(:get_mailbox).with(metadata[:mailbox]).and_return(mailbox)
      flexmock(Storage).should_receive(:instance).and_return(storage_instance)
    end

    describe "#run" do
      context "with a missing mailbox parameter in metadata" do
        let(:metadata) { Hash.new }
        it "should raise an error if there is no mailbox in the metadata" do
          expect { controller.run }.to raise_error ArgumentError
        end
      end

      context "with a present mailbox parameter in metadata" do
        context "with an invalid mailbox" do
          let(:mailbox) { nil }
          it "plays the mailbox not found message and hangs up" do
            subject.should_receive(:play).once.with(Adhearsion.config[:voicemail].mailbox_not_found)
            subject.should_receive(:hangup).once
            controller.run
          end
        end

        context "with an existing mailbox" do        
          it "plays the mailbox greeting message" do
            subject.should_receive(:play).once.with(Adhearsion.config[:voicemail].mailbox.greeting_message)
            subject.should_receive(:authenticate).and_return(true)
            subject.should_receive(:play_number_of_messages).and_return(true)
            subject.should_receive(:main_menu).and_return(true)
            controller.run 
          end
        end

      end

      describe "#authenticate" do
          it "authenticates an user that enters the correct pin" do
            subject.should_receive(:ask).with(
              Adhearsion.config[:voicemail].mailbox.please_enter_pin, :terminator => "#", :timeout => Adhearsion.config[:voicemail].prompt_timeout).once.and_return(1234)
            controller.authenticate.should == true
          end

          it "tell a user his pin is wrong and retries" do
            subject.should_receive(:ask).times(2).and_return(1111, 1234)
            subject.should_receive(:play).once.with(Adhearsion.config[:voicemail].mailbox.pin_wrong)
            controller.authenticate.should == true
          end

          it "fails with a message if the user enters a wrong PIN the set number of times" do
            subject.should_receive(:ask).times(3).and_return(1111, 2222, 3333)
            subject.should_receive(:play).times(3).with(Adhearsion.config[:voicemail].mailbox.pin_wrong)
            controller.authenticate.should == false
          end
      end

      describe "#play_number_of_messages" do
        it "plays the number of new messages if there is at least one" do
          storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return(3)
          subject.should_receive(:play).ordered.with(Adhearsion.config[:voicemail].mailbox.number_before)
          subject.should_receive(:play).ordered.with(3)
          subject.should_receive(:play).ordered.with(Adhearsion.config[:voicemail].mailbox.number_after)
          controller.play_number_of_messages
        end

        it "does not play anything if there are none" do
          storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return(0)
          subject.should_receive(:play).never
          controller.play_number_of_messages
        end
      end

      describe "#main_menu" do
        it "invokes MainMenuController" do
          subject.should_receive(:invoke).once.with(MailboxMainMenuController, {:mailbox => mailbox[:id]})
          controller.main_menu
        end
      end

    end#valid mailbox context

  end
end
