require 'spec_helper'

describe Voicemail::MailboxController do
  include VoicemailControllerSpecHelper

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
          should_play config.mailbox_not_found
          subject.should_receive(:hangup).once
          controller.run
        end
      end

      context "with an existing mailbox" do
        it "plays the mailbox greeting message" do
          should_play config.mailbox.greeting_message
          subject.should_receive(:authenticate).and_return(true)
          subject.should_receive(:play_number_of_messages).and_return(true)
          subject.should_receive(:main_menu).and_return(true)
          controller.run
        end
      end
    end

    describe "#authenticate" do
      it "authenticates an user that enters the correct pin" do
        should_ask(config.mailbox.please_enter_pin, terminator: "#", timeout: config.prompt_timeout).once.and_return(1234)
        controller.authenticate.should == true
      end

      it "tell a user his pin is wrong and retries" do
        subject.should_receive(:ask).times(2).and_return(1111, 1234)
        should_play config.mailbox.pin_wrong
        controller.authenticate.should == true
      end

      it "fails with a message if the user enters a wrong PIN the set number of times" do
        subject.should_receive(:ask).times(3).and_return(1111, 2222, 3333)
        subject.should_receive(:play).with(config.mailbox.pin_wrong).times(3)
        controller.authenticate.should == false
      end
    end

    describe "#play_number_of_messages" do
      it "plays the number of new messages if there is at least one" do
        flexmock(Adhearsion).should_receive("config.punchblock.platform" => :asterisk).once
        storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return(3)
        should_play(config.mailbox.number_before).ordered
        subject.should_receive(:play_numeric).ordered.with(3)
        should_play(config.mailbox.number_after).ordered
        controller.play_number_of_messages
      end

      it "does play the no messages audio if there are none" do
        storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return(0)
        should_play(config.messages.no_new_messages).ordered
        controller.play_number_of_messages
      end
    end

    describe "#main_menu" do
      it "passes to MainMenuController" do
        subject.should_receive(:pass).once.with(Voicemail::MailboxMainMenuController, mailbox: mailbox[:id])
        controller.main_menu
      end
    end
  end
end
