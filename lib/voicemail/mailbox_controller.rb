module Voicemail
  class MailboxController < ApplicationController
    def run 
      if mailbox
        play_greeting
        fail_auth unless authenticate
        play_number_of_messages
        main_menu
      else
        mailbox_not_found
      end
    end
    
    def play_greeting
      play @mailbox[:greeting_message] || config[:voicemail].mailbox.greeting_message
    end

    def authenticate
      current_tries = 0
      auth_ok = false
      while current_tries < config[:voicemail].mailbox.pin_tries
        input = ask config[:voicemail].mailbox.please_enter_pin, :terminator => "#", :timeout => config[:voicemail].prompt_timeout
        auth_ok = true if input.to_s == mailbox[:pin].to_s
        break if auth_ok
        play config[:voicemail].mailbox.pin_wrong
        current_tries += 1
      end
      auth_ok 
    end
    
    def play_number_of_messages
      number = storage.count_new_messages(mailbox[:id])
      if number > 0
        play config[:voicemail].mailbox.number_before
        play_numeric number
        play config[:voicemail].mailbox.number_after
      else
        play config[:voicemail].messages.no_new_messages
      end
    end

    def mailbox_not_found
      play config[:voicemail].mailbox_not_found
      hangup
    end

    def fail_auth
      play config[:voicemail].mailbox.could_not_auth
      hangup
    end
  end
end
