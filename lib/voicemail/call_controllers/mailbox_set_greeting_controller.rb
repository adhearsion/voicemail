module Voicemail
  class MailboxSetGreetingController < ApplicationController
    attr_accessor :temp_recording

    def run
      section_menu
    end

    def section_menu
      menu_prompt = [
        t('voicemail.set_greeting.greeting_menu.listen_to_current'),
        t('voicemail.set_greeting.greeting_menu.record_new'),
        t('voicemail.set_greeting.greeting_menu.delete_greeting'),
        t('voicemail.return_to_main_menu')
      ]
      menu menu_prompt,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { listen_to_current_greeting }
        match(2) { record_greeting }
        match(3) { delete_greeting_menu }
        match(9) { main_menu }

        timeout do
          play t('voicemail.mailbox.menu.timeout')
        end

        invalid do
          play t('voicemail.mailbox.menu.invalid')
        end

        failure do
          play t('voicemail.mailbox.menu.failure')
          main_menu
        end
      end
    end

    def listen_to_current_greeting
      play mailbox[:greeting_message] || t('voicemail.set_greeting.no_personal_greeting')
      section_menu
    end

    def record_greeting
      play t('voicemail.set_greeting.recording_instructions')
      record_comp = record record_options
      @temp_recording = record_comp.complete_event.recording.uri
      play_audio @temp_recording

      menu_prompt = [
        t('voicemail.set_greeting.recording_menu.save_greeting'),
        t('voicemail.set_greeting.recording_menu.discard_greeting'),
        t('voicemail.return_to_main_menu')
      ]
      menu menu_prompt,
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
          play t('voicemail.mailbox.menu.timeout')
        end

        invalid do
          play t('voicemail.mailbox.menu.invalid')
        end

        failure do
          play t('voicemail.mailbox.menu.failure')
          section_menu
        end
      end
    end

    def delete_greeting_menu
      menu_prompt = [
        t('voicemail.set_greeting.delete_confirmation'),
        t('voicemail.press_one_to_confirm'),
        t('voicemail.return_to_main_menu')
      ]
      menu menu_prompt,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { delete_greeting }
        match(9) { section_menu }
        timeout do
          play t('voicemail.mailbox.menu.timeout')
        end

        invalid do
          play t('voicemail.mailbox.menu.invalid')
        end

        failure do
          play t('voicemail.mailbox.menu.failure')
          section_menu
        end
      end
    end

    def delete_greeting
      storage.delete_greeting_from_mailbox mailbox[:id]
      play t('voicemail.set_greeting.greeting_deleted')
      main_menu
    end

    def save_greeting
      storage.save_greeting_for_mailbox mailbox[:id], temp_recording
      main_menu
    end
  end
end
