module Voicemail
  class MailboxSetGreetingController < ApplicationController
    attr_accessor :temp_recording
    def run
      section_menu
    end

    def section_menu
      menu config[:voicemail].set_greeting.prompt, 
         :timeout => config[:voicemail].menu_timeout, :tries => config[:voicemail].menu_tries do
        match 1 do 
          record_greeting
        end
        match 2 do 
          listen_to_current_greeting
        end
        match 9 do
          main_menu
        end
   
        timeout do
          play config[:voicemail].mailbox.menu_timeout_message
        end 
        invalid do
          play config[:voicemail].mailbox.menu_invalid_message
        end
   
        failure do
          play config[:voicemail].mailbox.menu_failure_message
          hangup
        end
      end
    end

    def listen_to_current_greeting
      play mailbox[:greeting_message] || config[:voicemail].set_greeting.no_personal_greeting
      section_menu
    end

    def record_greeting
      play config[:voicemail].set_greeting.before_record
      record_comp = record config[:voicemail].set_greeting.recording.to_hash
      temp_recording = record_comp.complete_event.recording.uri
      play temp_recording

      menu config[:voicemail].set_greeting.after_record, 
         :timeout => config[:voicemail].menu_timeout, :tries => config[:voicemail].menu_tries do
        match 1 do 
          save_greeting
        end
        match 2 do 
          temp_recording = nil
          record_greeting
        end
        match 9 do
          temp_recording = nil
          section_menu
        end
   
        timeout do
          play config[:voicemail].mailbox.menu_timeout_message
        end 
        invalid do
          play config[:voicemail].mailbox.menu_invalid_message
        end
   
        failure do
          play config[:voicemail].mailbox.menu_failure_message
          hangup
        end
      end
    end

    def save_greeting
      storage.save_greeting_for_mailbox(mailbox[:id], temp_recording)
      main_menu
    end

  end
end
