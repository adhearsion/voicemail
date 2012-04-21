module Voicemail
  class VoicemailController < ::Adhearsion::CallController
    def init_mailbox()
      mailbox_id = metadata[:mailbox] || nil
      raise ArgumentError, "Voicemail needs a mailbox specified in metadata" unless mailbox_id
      @mailbox = storage.get_mailbox mailbox_id
    end

    def run
      init_mailbox
      if @mailbox
        play_greeting
        handle_recording
      else
        mailbox_not_found
      end
    end

    def play_greeting
      play @mailbox[:greeting_message] || config[:voicemail].default_greeting
    end

    def handle_recording
      record config[:voicemail].recording.to_hash do |event|
        save_recording(event.recording.uri)
      end
    end

    def mailbox_not_found
      play config[:voicemail].mailbox_not_found
      hangup
    end

    def save_recording(uri)
      storage.save_recording(@mailbox[:id], call.from, uri)
    end

    def storage
      Storage.instance
    end

    def config
      Adhearsion.config
    end

  end
end
