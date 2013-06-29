module Voicemail
  class MailboxMainMenuController < ApplicationController
    def run
      main_menu
    end

    def main_menu
      menu config.mailbox.menu_greeting,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { listen_to_messages }
        match(2) { set_greeting }
        match(3) { set_pin }

        timeout do
          play config.mailbox.menu_timeout_message
        end

        invalid do
          play config.mailbox.menu_invalid_message
        end

        failure do
          play config.mailbox.menu_failure_message
          hangup
        end
      end
    end

    def set_greeting
      invoke MailboxSetGreetingController, mailbox: mailbox[:id], storage: storage
    end

    def set_pin
      invoke MailboxSetPinController, mailbox: mailbox[:id], storage: storage
    end

    def listen_to_messages
      invoke MailboxMessagesController, mailbox: mailbox[:id], storage: storage
    end
  end
end
