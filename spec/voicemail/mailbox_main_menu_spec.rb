require 'spec_helper'

module Voicemail
  describe MailboxMainMenuController do
    
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

    let(:controller){ Voicemail::MailboxMainMenuController.new call, metadata }
    subject { flexmock controller }
    
    before(:each) do
      storage_instance.should_receive(:get_mailbox).with(metadata[:mailbox]).and_return(mailbox)
      flexmock(Storage).should_receive(:instance).and_return(storage_instance)
    end

    describe "#main_menu" do
      it "calls #menu with the proper parameters" do
        subject.should_receive(:menu).once.with(Adhearsion.config[:voicemail].mailbox.menu_greeting,
            {:timeout => Adhearsion.config[:voicemail].menu_timeout,
              :tries => Adhearsion.config[:voicemail].menu_tries}, Proc)
        controller.main_menu
      end
    end


    describe "#set_greeting" do
      it "invokes MailboxSetGreetingController" do
        subject.should_receive(:invoke).once.with(MailboxSetGreetingController, {:mailbox => mailbox[:id]})
        controller.set_greeting
      end
    end

    describe "#set_pin" do
      it "invokes MailboxSetGreetingController" do
        subject.should_receive(:invoke).once.with(MailboxSetPinController, {:mailbox => mailbox[:id]})
        controller.set_pin
      end
    end

  end
end
