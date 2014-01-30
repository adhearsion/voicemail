require 'pstore'

module Voicemail
  class StoragePstore
    attr_accessor :store

    def initialize
      @store = PStore.new config.storage.pstore_location
      setup_schema
    end

    def get_mailbox(mailbox_id)
      store.transaction true do
        store[:mailboxes][mailbox_id]
      end
    end

    def count_new_messages(mailbox_id)
      store.transaction true do
        store[:recordings][mailbox_id].size
      end
    end

    def count_saved_messages(mailbox_id)
      store.transaction true do
        store[:archived][mailbox_id].size
      end
    end

    def next_new_message(mailbox_id)
      store.transaction true do
        store[:recordings][mailbox_id].first
      end
    end

    def next_saved_message(mailbox_id)
      store.transaction true do
        store[:archived][mailbox_id].first
      end
    end

    def archive_message(mailbox_id, message_id)
      store.transaction do
        item = store[:recordings][mailbox_id].select { |i| i[:id] == message_id }
        rec = item.first
        if rec
          store[:archived][mailbox_id] << rec
          store[:recordings][mailbox_id].delete(rec)
        end
      end
    end

    def unarchive_message(mailbox_id, message_id)
      store.transaction do
        item = store[:archived][mailbox_id].select { |i| i[:id] == message_id }
        rec  = item.first
        if rec
          store[:recordings][mailbox_id] << rec
          store[:archived][mailbox_id].delete(rec)
        end
      end
    end

    def delete_message(mailbox_id, message_id)
      File.unlink(rec[:uri]) if File.exists?(rec[:uri])
      store[:recordings][mailbox_id].delete(rec)
    end

    def save_greeting_for_mailbox(mailbox_id, recording_uri)
      store.transaction do
        store[:mailboxes][mailbox_id][:greeting_message] = recording_uri
      end
    end

    def delete_greeting_from_mailbox(mailbox_id)
      store.transaction do
        rec = store[:mailboxes][mailbox_id][:greeting_message]
        File.unlink rec if File.exists? rec
        store[:mailboxes][mailbox_id][:greeting_message] = nil
      end
    end

    def change_pin_for_mailbox(mailbox_id, new_pin)
      store.transaction do
        store[:mailboxes][mailbox_id][:pin] = new_pin
      end
    end

    def save_recording(mailbox_id, from, recording_object)
      store.transaction do
        recording = {
          id:       SecureRandom.uuid,
          from:     from,
          received: Time.now,
          uri:      recording_object.uri
        }
        store[:recordings][mailbox_id] << recording
        logger.info "Saving recording: #{recording.inspect}"
      end
    end

    def create_mailbox
    end

    private

    def setup_schema
      store.transaction do
        store[:mailboxes]   ||= {}
        store[:recordings]  ||= {}
        store[:archived]    ||= {}
      end
    end

    def config
      Voicemail::Plugin.config
    end
  end
end
