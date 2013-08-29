module Voicemail
  class VoicemailController < ApplicationController
    def run
      answer
      if mailbox
        play_greeting
        handle_recording
      else
        mailbox_not_found
      end
    end

    def play_greeting
      play mailbox[:greeting_message] || config.default_greeting
    end

    def handle_recording
      @from = call.from
      record_comp = record config.recording.to_hash.merge(interruptible: true, direction: :recv)
      save_recording record_comp.complete_event.recording.uri
    end

    def mailbox_not_found
      play config.mailbox_not_found
      hangup
    end

    def save_recording(uri)
      storage.save_recording mailbox[:id], @from, uri
    end
  end
end
