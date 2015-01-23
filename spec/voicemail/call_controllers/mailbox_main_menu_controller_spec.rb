require 'spec_helper'

describe Voicemail::MailboxMainMenuController do
  include VoicemailControllerSpecHelper

  describe "#main_menu" do
    it "calls #menu with the proper parameters" do
      prompts = ['listen_to_new', 'listen_to_saved', 'change_greeting', 'change_pin', 'delete_all_new', 'delete_all_saved']
      prompts.each do |prompt|
        subject.should_receive(:t).with("voicemail.mailbox.menu.#{prompt}").and_return prompt
      end
      subject.should_receive(:menu).once.with(prompts,
          { timeout: config.menu_timeout,
            tries: config.menu_tries }, Proc)
      controller.main_menu
    end
  end

  describe "#set_greeting" do
    it "invokes MailboxSetGreetingController" do
      should_invoke Voicemail::MailboxSetGreetingController, mailbox: mailbox[:id], storage: storage_instance
      controller.set_greeting
    end
  end

  describe "#set_pin" do
    it "invokes MailboxSetGreetingController" do
      should_invoke Voicemail::MailboxSetPinController, mailbox: mailbox[:id], storage: storage_instance
      controller.set_pin
    end
  end

  describe "#listen_to_new_messages" do
    it "invokes MailboxMessagesController" do
      should_invoke Voicemail::MailboxMessagesController, mailbox: mailbox[:id], storage: storage_instance
      controller.listen_to_new_messages
    end
  end

  describe "#listen_to_saved_messages" do
    it "invokes MailboxMessagesController" do
      should_invoke Voicemail::MailboxMessagesController, mailbox: mailbox[:id], new_or_saved: :saved, storage: storage_instance
      controller.listen_to_saved_messages
    end
  end
end
