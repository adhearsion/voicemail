module Voicemail
  class MailboxPlayMessageController < ApplicationController
    include IntroMessageCreator

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
      menu intro_message(current_message), message_uri, play_message_menu, timeout: config.menu_timeout, tries: config.menu_tries do
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
          play t('voicemail.mailbox.menu.timeout')
        end

        invalid do
          play t('voicemail.mailbox.menu.invalid')
        end

        failure do
          play t('voicemail.mailbox.menu.failure')
          main_menu
        end
      end
    end

    def play_message_menu
      [
        t("voicemail.messages.menu.archive_#{new_or_saved}"),
        t('voicemail.messages.menu.delete'),
        t('voicemail.messages.menu.replay'),
        t('voicemail.messages.menu.skip'),
        t('voicemail.return_to_main_menu')
      ]
    end

    def rewind_message
      play_message
    end

    def skip_message
      # This method intentionally left blank
    end

    def archive_or_unarchive_message
      if new_or_saved == :new
        storage.change_message_type mailbox[:id], current_message[:id], :new, :saved
      else
        storage.change_message_type mailbox[:id], current_message[:id], :saved, :new
      end
    end

    def delete_message
      storage.delete_message mailbox[:id], current_message[:id], new_or_saved
      play t('voicemail.messages.message_deleted')
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
