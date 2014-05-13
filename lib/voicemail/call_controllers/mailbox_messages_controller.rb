module Voicemail
  class MailboxMessagesController < ApplicationController

    attr_accessor :new_or_saved

    def initialize(call, metadata={})
      @new_or_saved = metadata[:new_or_saved] || :new

      super call, metadata
      @messages = storage.get_messages mailbox[:id], new_or_saved
    end

    def run
      message_loop
    end

    def message_loop
      if messages_remaining > 0
        next_message
      else
        bail_out
      end
    end

    def next_message
      handle_message current_message
      message_loop
    end

    def handle_message(message)
      invoke MailboxPlayMessageController, message: message, mailbox: mailbox[:id], new_or_saved: new_or_saved, storage: storage
    end

    private

    def messages_remaining
      @messages.size
    end

    def current_message
      @messages.shift
    end

    def bail_out
      play [t('voicemail.messages.there_are_no'), t("voicemail.#{new_or_saved}_messages")]
      main_menu
    end
  end
end
