module Voicemail
  class MailboxController < ApplicationController
    def run
      if mailbox
        play_number_of_messages
        main_menu
      else
        mailbox_not_found
      end
    end

    def play_number_of_messages
      number = storage.count_new_messages(mailbox[:id])
      if number > 0
        play config.mailbox.number_before
        play_numeric number
        play config.mailbox.number_after
      else
        play config.messages.no_new_messages
      end
    end
  end
end
