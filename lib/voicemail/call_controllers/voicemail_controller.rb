module Voicemail
  class VoicemailController < ApplicationController

    attr_accessor :recording, :recording_saved

    def run
      answer if config.when_to_answer == :before_greeting
      if mailbox
        result = play_greeting
        answer if config.when_to_answer == :after_greeting

        if result.status == :match
          response = if result.respond_to? :utterance
            # Using the adhearsion-asr plugin
            result.utterance
          else
            # Using the built-in Adhearsion #ask
            result.response
          end
        end

        if result.status == :match && response == config.go_to_menu_digit
          pass Voicemail::AuthenticationController, metadata
        else
          record_message
          play_recording_confirmation
          hangup
        end
      else
        mailbox_not_found
      end
    end

    def play_greeting
      ask (mailbox[:greeting] || t('voicemail.default_greeting')), limit: 1, timeout: config.go_to_menu_timeout
    end

    def play_recording_confirmation
      play t('voicemail.recording_confirmation')
    end

    def record_message
      ensure_message_saved_on_hangup

      @recording = record record_options

      config.allow_rerecording ? recording_menu : save_recording
    end

    def recording_menu
      menu recording_url, t('voicemail.after_record'), tries: 3, timeout: 10 do
        match('1') { save_recording }
        match('2') { record_message }

        invalid {  }
        timeout {  }
        failure {  }
      end
    end

  private

    def ensure_message_saved_on_hangup
      call.on_end do
        save_recording if recording && !recording_saved
      end
    end

    def save_recording
      storage.save_recording mailbox[:id], :new, call.from, recording.complete_event.recording
      @recording_saved = true
    end

    def recording_url
      recording.complete_event.recording.uri
    end
  end
end
