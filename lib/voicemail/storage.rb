module Voicemail
  class Storage
    include Singleton
    # mailbox: id, pin, away, away_message, greeting_message 
    def get_mailbox(mailbox_id)
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

  end
end
