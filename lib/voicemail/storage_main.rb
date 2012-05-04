require 'pstore'

module Voicemail
  class StorageMain
    attr_accessor :store
    def initialize()
      @store = PStore.new(Adhearsion.config[:voicemail].storage.pstore_location)
      @store.transaction do
        @store[:mailboxes] ||= {}
      end
    end

    def get_mailbox(mailbox_id)
      @store.transaction(true) do
        @store[:mailboxes][mailbox_id]
      end
    end
    
    def count_new_messages(mailbox_id)
    end

    def next_new_message(mailbox_id)
    end

    def archive_message(message_id)
    end

    def delete_message(message_id)
    end

    def save_greeting_for_mailbox(mailbox_id, recording_uri)
    end
    
    def change_pin_for_mailbox(mailbox_id, new_pin)
    end

    def save_recording(mailbox_id, from, recording_uri)
    end

    def create_mailbox
    end

  end
end
