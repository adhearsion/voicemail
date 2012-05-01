require 'spec_helper'

module Voicemail
  describe MailboxMessagesController do
    
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
    let(:message) do
      {
        :id => 123,
        :from => "+39335135335",
        :received => Time.local(2012, 5, 1, 9, 0, 0),
        :uri => "/path/to/file"
      }
    end

    let(:storage_instance) { flexmock('StorageInstance') }

    let(:controller){ Voicemail::MailboxMessagesController.new call, metadata }
    subject { flexmock controller }
    
    before(:each) do
      storage_instance.should_receive(:get_mailbox).with(metadata[:mailbox]).and_return(mailbox)
      flexmock(Storage).should_receive(:instance).and_return(storage_instance)
    end

    describe "#message_loop" do
      it "calls #next_message if there are new messages" do
        storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return(3)
        subject.should_receive(:next_message).once
        controller.message_loop
      end

      it "plays a message and goes to the main menu if there are no new messages" do
        storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return(0)
        subject.should_receive(:play).with(config.messages.no_new_messages).once
        subject.should_receive(:main_menu).once
        controller.message_loop
      end
    end

    describe "#next_message" do
      it "gets the next message and calls #handle_message" do
        storage_instance.should_receive(:next_new_message).once.with(mailbox[:id]).and_return(message)
        subject.should_receive(:handle_message).once
        controller.next_message
      end
    end

    describe "#handle_message" do
      it "calls #intro_message and #play_message" do
        subject.should_receive(:intro_message).once
        subject.should_receive(:play_message).once
        controller.handle_message
      end
    end

    describe "#intro_message" do
      it "plays the message introduction" do
        subject.should_receive(:current_message).and_return(message)
        subject.should_receive(:play).once.with(config.messages.message_received_on)
        subject.should_receive(:play).once.with(message[:received])
        subject.should_receive(:play).once.with(config.messages.from)
        subject.should_receive(:play).once.with(message[:from])
        controller.intro_message
      end
    end

    describe "#play_message" do
      it "plays the message, followed by the menu" do
        subject.should_receive(:current_message).once.and_return(message)
        subject.should_receive(:menu).once.with(message[:uri], config.messages.menu,
          {:timeout => config.menu_timeout, :tries => config.menu_tries}, Proc) 
        subject.play_message
      end
    end

  end
end
