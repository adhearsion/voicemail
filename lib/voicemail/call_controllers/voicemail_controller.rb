module Voicemail
  class VoicemailController < ApplicationController
    def run
      answer if config.when_to_answer == :before_greeting
      if mailbox
        play_greeting
        answer if config.when_to_answer == :after_greeting
        handle_recording
        hangup
      else
        mailbox_not_found
      end
    end

    def play_greeting
      play mailbox[:greeting_message] || config.default_greeting
    end

    def handle_recording
      @from = call.from
      record_comp = record config.recording.to_hash
      save_recording record_comp.complete_event.recording
    end

    def save_recording(recording_object)
      storage.save_recording mailbox[:id], @from, recording_object
    end
  end
end
