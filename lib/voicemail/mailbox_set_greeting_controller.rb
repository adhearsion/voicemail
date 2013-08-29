module Voicemail
  class MailboxSetGreetingController < ApplicationController
    attr_accessor :temp_recording

    def run
      section_menu
    end

    def section_menu
      menu config.set_greeting.prompt,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { listen_to_current_greeting }
        match(2) { record_greeting }
        match(9) { main_menu }

        timeout do
          play config.mailbox.menu_timeout_message
        end

        invalid do
          play config.mailbox.menu_invalid_message
        end

        failure do
          play config.mailbox.menu_failure_message
          hangup
        end
      end
    end

    def listen_to_current_greeting
      play mailbox[:greeting_message] || config.set_greeting.no_personal_greeting
      section_menu
    end

    def record_greeting
      play config.set_greeting.before_record
      record_comp = record config.set_greeting.recording.to_hash.merge(interruptible: true)
      @temp_recording = record_comp.complete_event.recording.uri.gsub(/file:\/\//, '').gsub(/\.wav/, '')
      play_audio @temp_recording

      menu config.set_greeting.after_record,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { save_greeting }
        match 2 do
          @temp_recording = nil
          record_greeting
        end

        match 9 do
          @temp_recording = nil
          section_menu
        end

        timeout do
          play config.mailbox.menu_timeout_message
        end

        invalid do
          play config.mailbox.menu_invalid_message
        end

        failure do
          play config.mailbox.menu_failure_message
          hangup
        end
      end
    end

    def save_greeting
      storage.save_greeting_for_mailbox mailbox[:id], temp_recording
      main_menu
    end
  end
end
