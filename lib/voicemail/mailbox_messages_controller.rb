module Voicemail
  class MailboxMessagesController < ApplicationController
    attr_accessor :current_message

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
      logger.info current_message
      handle_message
    end

    def handle_message
      intro_message
      play_message
    end

    def play_message
      menu current_message[:uri].gsub(/\.wav/, ''), config.messages.menu,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match 1 do
          archive_message
          message_loop
        end

        match 5 do
          delete_message
          message_loop
        end

        match(7) { rewind_message }
        match(9) { main_menu }

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

    def intro_message
      play config.messages.message_received_on
      play_time current_message[:received], format: config.datetime_format
      play config.messages.from
      from_digits = current_message[:from].scan(/\d/).join
      execute "SayDigits", from_digits unless from_digits.empty?
    end

    def rewind_message
      play_message
    end

    def archive_message
      storage.archive_message mailbox[:id], current_message[:id]
    end

    def delete_message
      storage.delete_message mailbox[:id], current_message[:id]
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
