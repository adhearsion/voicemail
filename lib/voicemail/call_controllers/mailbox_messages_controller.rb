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
      invoke MailboxPlayMessageController, message: message, mailbox: mailbox[:id]
    end

    private

    def bail_out
      play config.messages.no_new_messages
      main_menu
    end
  end
end
