require 'spec_helper'

describe Voicemail::MailboxMainMenuController do
  include VoicemailControllerSpecHelper

  describe "#main_menu" do
    it "calls #menu with the proper parameters" do
      subject.should_receive(:menu).once.with(config.mailbox.menu_greeting,
          { timeout: config.menu_timeout,
            tries: config.menu_tries }, Proc)
      controller.main_menu
    end
  end

  describe "#set_greeting" do
    it "invokes MailboxSetGreetingController" do
      should_invoke Voicemail::MailboxSetGreetingController, mailbox: mailbox[:id]
      controller.set_greeting
    end
  end

  describe "#set_pin" do
    it "invokes MailboxSetGreetingController" do
      should_invoke Voicemail::MailboxSetPinController, mailbox: mailbox[:id]
      controller.set_pin
    end
  end

  describe "#listen_to_new_messages" do
    it "invokes MailboxMessagesController" do
      should_invoke Voicemail::MailboxMessagesController, mailbox: mailbox[:id]
      controller.listen_to_new_messages
    end
  end

  describe "#listen_to_saved_messages" do
    it "invokes MailboxMessagesController" do
      should_invoke Voicemail::MailboxMessagesController, mailbox: mailbox[:id], new_or_saved: :saved
      controller.listen_to_saved_messages
    end
  end
end
