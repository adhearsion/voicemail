module Voicemail
  class MailboxPlayMessageController < ApplicationController
    def run
      load_message
      intro_message
      play_message
    end

    def play_message
      menu current_message[:uri], config.messages.menu,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match 1 do
          archive_message
        end

        match 5 do
          delete_message
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
      if Adhearsion.config.punchblock.platform == :asterisk
        play_time current_message[:received_at], format: config.datetime_format
      else
        datetime = DateTime.parse(current_message[:received_at]).to_time
        play *sounds_for_time(datetime, {})
      end
      
      play config.messages.from
      from_digits = current_message[:from].scan(/\d{10,18}/).first
      #from_digits = current_message[:from].scan(/\d/).join

      if Adhearsion.config.punchblock.platform == :asterisk
        execute "SayDigits", from_digits unless from_digits.empty?
      else
        play *sounds_for_digits(from_digits) unless from_digits.empty?
      end
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

    def current_message
      @message
    end

    def load_message
      @message = metadata[:message] || nil
      logger.info "MESSAGE: #{@message}"
      raise ArgumentError, "MailboxPlayMessageController needs a valid message passed to it" unless @message
    end
  end
end
