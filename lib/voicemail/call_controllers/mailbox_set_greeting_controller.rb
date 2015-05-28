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
        match(3) { delete_greeting_menu }
        match(9) { main_menu }

        timeout do
          play config.mailbox.menu_timeout_message
        end

        invalid do
          play config.mailbox.menu_invalid_message
        end

        failure do
          play config.mailbox.menu_failure_message
          main_menu
        end
      end
    end

    def listen_to_current_greeting
      play mailbox[:greeting_message] || config.set_greeting.no_personal_greeting
      section_menu
    end

    def record_greeting
      play config.set_greeting.before_record
      record_comp = record record_options
      @temp_recording = record_comp.complete_event.recording.uri
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
          section_menu
        end
      end
    end

    def delete_greeting_menu
      menu config.set_greeting.delete_confirmation,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { delete_greeting }
        match(9) { section_menu }
        timeout do
          play config.mailbox.menu_timeout_message
        end

        invalid do
          play config.mailbox.menu_invalid_message
        end

        failure do
          play config.mailbox.menu_failure_message
          section_menu
        end
      end
    end

    def delete_greeting
      storage.delete_greeting_from_mailbox mailbox[:id]
      play config.set_greeting.greeting_deleted
      main_menu
    end

    def save_greeting
      storage.save_greeting_for_mailbox mailbox[:id], temp_recording
      main_menu
    end
  end
end
