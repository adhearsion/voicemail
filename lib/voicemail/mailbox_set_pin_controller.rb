module Voicemail
  class MailboxSetPinController < ApplicationController
    def run
      section_menu 
    end

    def section_menu
      menu config[:voicemail].set_pin.menu, 
         :timeout => config[:voicemail].menu_timeout, :tries => config[:voicemail].menu_tries do
        match 1 do 
          set_pin
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

    def set_pin
      pin = ask config[:voicemail].set_pin.prompt, :terminator => "#"
      repeat_pin = ask config[:voicemail].set_pin.repeat_prompt, :terminator => "#"

      if pin.to_s.size < config[:voicemail].set_pin.pin_minimum_digits
        play config[:voicemail].set_pin.pin_error
        set_pin
      elsif pin.to_s != repeat_pin.to_s
        play config[:voicemail].set_pin.match_error
        set_pin
      else
        play config[:voicemail].set_pin.change_ok
        storage.change_pin_for_mailbox(mailbox[:id], pin.to_s)
        main_menu
      end

    end

  end
end
