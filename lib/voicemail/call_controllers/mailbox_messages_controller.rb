module Voicemail
  class MailboxMessagesController < ApplicationController

    attr_accessor :new_or_saved

    def initialize(call, metadata={})
      @new_or_saved = metadata[:new_or_saved] || :new

      super call, metadata
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
      storage.send "count_#{new_or_saved}_messages", mailbox[:id]
    end

    def current_message
      storage.send "next_#{new_or_saved}_message", mailbox[:id]
    end

    def bail_out
      play config.messages["no_#{new_or_saved}_messages"]
      main_menu
    end
  end
end
