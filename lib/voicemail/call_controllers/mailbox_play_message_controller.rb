module Voicemail
  class MailboxPlayMessageController < ApplicationController

    attr_accessor :new_or_saved

    def initialize(call, metadata={})
      @new_or_saved = metadata[:new_or_saved] || :new
      super call, metadata
    end

    def run
      load_message
      play_message
    end

    def play_message
      menu intro_message, message_uri, play_message_menu, timeout: config.menu_timeout, tries: config.menu_tries do
        match 1 do
          archive_or_unarchive_message
        end

        match 5 do
          delete_message
        end

        match(7) { rewind_message }
        match(8) { skip_message }
        match(9) { main_menu }

        timeout do
          play config.mailbox.menu_timeout_message
        end

        invalid do
          play config.mailbox.menu_invalid_message
        end

        failure do
          play config.mailbox.menu_failure_message
          main_menu
        end
      end
    end

    def intro_message
      IntroMessageCreator.new(current_message).intro_message
    end

    def play_message_menu
      if new_or_saved == :new
        config.messages.menu_new
      else
        config.messages.menu_saved
      end
    end

    def rewind_message
      play_message
    end

    def skip_message
      # This method intentionally left blank
    end

    def archive_or_unarchive_message
      if new_or_saved == :new
        storage.archive_message mailbox[:id], current_message[:id]
      else
        storage.unarchive_message mailbox[:id], current_message[:id]
      end
    end

    def delete_message
      storage.delete_message mailbox[:id], current_message[:id]
      play config.messages.message_deleted
    end

    def current_message
      @message
    end

    def load_message
      @message = metadata[:message] || nil
      raise ArgumentError, "MailboxPlayMessageController needs a valid message passed to it" unless @message
    end

    def message_uri
      current_message[:uri]
    end
  end
end
