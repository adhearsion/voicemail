require 'pstore'

module Voicemail
  class StorageMain
    attr_accessor :store
    def initialize()
      @store = PStore.new(Adhearsion.config[:voicemail].storage.pstore_location)
      @store.transaction do
        @store[:mailboxes] ||= {}
        @store[:recordings] ||= {}
        @store[:recordings][100] ||= []
        @store[:archived] ||= {}
        @store[:archived][100] ||= []
        @store[:mailboxes][100] = {
        :id => 100,
        :pin => 1234,
        :greeting_message => nil
      }
      end
    end

    def get_mailbox(mailbox_id)
      @store.transaction(true) do
        @store[:mailboxes][mailbox_id]
      end
    end
    
    def count_new_messages(mailbox_id)
      @store.transaction(true) do
        @store[:recordings][mailbox_id].size
      end
    end

    def next_new_message(mailbox_id)
      @store.transaction(true) do
        @store[:recordings][mailbox_id].first
      end
    end

    def archive_message(mailbox_id, message_id)
      @store.transaction do
        item = @store[:recordings][mailbox_id].select {|i| i[:id] == message_id }
        rec = item.first
        if rec
          @store[:archived][mailbox_id] << rec
          @store[:recordings][mailbox_id].delete(rec)
        end
      end
    end

    def delete_message(mailbox_id, message_id)
      File.unlink(rec[:uri]) if File.exists?(rec[:uri])
      @store[:recordings][mailbox_id].delete(rec)
    end

    def save_greeting_for_mailbox(mailbox_id, recording_uri)
    end
    
    def change_pin_for_mailbox(mailbox_id, new_pin)
    end

    def save_recording(mailbox_id, from, recording_uri)
      uuid = UUID.new
      @store.transaction do
        @store[:recordings][mailbox_id] << {
          :id => uuid.generate,
          :from => from,
          :received => Time.now,
          :uri => recording_uri.gsub(/file:\/\//, '')
        }
        logger.info @store[:recordings][mailbox_id].last.inspect 
      end
    end

    def create_mailbox
    end

  end
end
