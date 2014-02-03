module Voicemail
  class MailboxMainMenuController < ApplicationController
    def run
      main_menu
    end

    def main_menu
      menu config.mailbox.menu_greeting,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { listen_to_new_messages }
        match(2) { listen_to_saved_messages }
        match(3) { set_greeting }
        match(4) { set_pin }
        match(7) { clear_new_messages }
        match(9) { clear_saved_messages }

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
      invoke MailboxSetGreetingController, mailbox: mailbox[:id]
    end

    def set_pin
      invoke MailboxSetPinController, mailbox: mailbox[:id]
    end

    def listen_to_new_messages
      invoke MailboxMessagesController, mailbox: mailbox[:id]
    end

    def listen_to_saved_messages
      invoke MailboxMessagesController, mailbox: mailbox[:id], new_or_saved: :saved
    end

    def clear_new_messages
      invoke MailboxCleanerController, mailbox: mailbox[:id], new_or_saved: :new
    end

    def clear_saved_messages
      invoke MailboxCleanerController, mailbox: mailbox[:id], new_or_saved: :saved
    end
  end
end
