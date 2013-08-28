module Voicemail
  class MailboxMessagesController < ApplicationController
    def run
      message_loop
    end

    def message_loop
      number = storage.count_new_messages(mailbox[:id])
      if number > 0
        next_message
      else
        bail_out
      end
    end

    def next_message
      current_message = storage.next_new_message(mailbox[:id])
      handle_message current_message
      message_loop
    end

    def handle_message(message)
      invoke MailboxPlayMessageController, message: message
    end

    private

    def bail_out
      play config.messages.no_new_messages
      main_menu
    end

    def section_menu
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
  end
end
