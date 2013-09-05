module Voicemail
  class MailboxController < ApplicationController
    def run
      if mailbox
        play_number_of_messages :new
        play_number_of_messages :saved
        main_menu
      else
        mailbox_not_found
      end
    end

    def play_number_of_messages(new_or_saved)
      get_count(new_or_saved)

      if @number > 0
        play config.mailbox.number_before
        play_numeric @number
        play config.mailbox["number_after_#{new_or_saved}".to_sym]
      else
        play config.messages["no_#{new_or_saved}_messages".to_sym]
      end
    end

    def get_count(new_or_saved)
      @number = storage.send "count_#{new_or_saved}_messages", mailbox[:id]
    end
  end
end
