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

    def count_messages(mailbox_id, type)
      store.transaction true do
        store[type][mailbox_id].size
      end
    end

    def next_message(mailbox_id, type)
      store.transaction true do
        store[type][mailbox_id].first
      end
    end

    def change_message_type(mailbox_id, message_id, from, to)
      store.transaction do
        item = store[from][mailbox_id].select { |i| i[:id] == message_id }
        recording = item.first
        if recording
          store[to][mailbox_id] << recording
          store[from][mailbox_id].delete recording
        end
      end
    end

    def delete_message(mailbox_id, message_id, type)
      store.transaction do
        item = store[type][mailbox_id].select { |i| i[:id] == message_id }
        recording = item.first
        if recording
          File.unlink recording[:uri] if File.exists? recording[:uri]
          store[type][mailbox_id].delete recording
        end
      end
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

    def save_recording(mailbox_id, type, from, recording_object)
      store.transaction do
        recording = {
          id:       SecureRandom.uuid,
          from:     from,
          received: Time.now,
          uri:      recording_object.uri
        }
        store[type][mailbox_id] << recording
        logger.info "Saving recording: #{recording.inspect}"
      end
    end

    def create_mailbox
    end

    private

    def setup_schema
      store.transaction do
        store[:mailboxes] ||= {}
        store[:new]       ||= {}
        store[:saved]     ||= {}
      end
    end

    def config
      Voicemail::Plugin.config
    end
  end
end
