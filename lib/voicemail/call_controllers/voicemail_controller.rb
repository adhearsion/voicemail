module Voicemail
  class VoicemailController < ApplicationController

    attr_accessor :recording

    def run
      answer if config.when_to_answer == :before_greeting
      if mailbox
        play_greeting
        answer if config.when_to_answer == :after_greeting
        record_message
        play_recording_confirmation
        hangup
      else
        mailbox_not_found
      end
    end

    def play_greeting
      play mailbox[:greeting_message] || config.default_greeting
    end

    def play_recording_confirmation
      play config.recording_confirmation
    end

    def record_message
      @recording = record record_options

      config.allow_rerecording ? recording_menu : save_recording
    end

    def recording_menu
      ensure_message_saved_if_hangup
      menu recording_url, config.after_record, tries: 3, timeout: 10 do
        match('1') { save_recording }
        match('2') { record_message }

        invalid {  }
        timeout { save_recording }
        failure { save_recording }
      end
    end

  private

    def ensure_message_saved_if_hangup
      call.on_end do
        save_recording unless @saved
      end
    end

    def save_recording
      storage.save_recording mailbox[:id], call.from, recording.complete_event.recording
      @saved = true
    end

    def recording_url
      recording.complete_event.recording.uri
    end
  end
end
