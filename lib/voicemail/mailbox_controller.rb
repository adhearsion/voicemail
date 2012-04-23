module Voicemail
  class MailboxController < ApplicationController
    def run 
      if mailbox
        play_greeting
        fail_auth unless authenticate
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
        break if auth_ok = input == mailbox[:pin]
        play config[:voicemail].mailbox.pin_wrong
        current_tries += 1
      end
      auth_ok
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
