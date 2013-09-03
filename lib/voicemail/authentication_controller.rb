module Voicemail
  class AuthenticationController < ApplicationController

    def run
      if mailbox
        play_greeting
        fail_auth unless authenticate
        pass MailboxController, mailbox: mailbox[:id]
      else
        mailbox_not_found
      end
    end

    def authenticate
      current_tries = 0
      auth_ok = false
      while current_tries < config.mailbox.pin_tries
        input = ask config.mailbox.please_enter_pin, terminator: "#", timeout: config.prompt_timeout
        logger.info input.to_s
        logger.info mailbox[:pin].to_s
        auth_ok = true if input.to_s == mailbox[:pin].to_s
        break if auth_ok
        play config.mailbox.pin_wrong
        current_tries += 1
      end
      auth_ok
    end

    private

    def play_greeting
      play config.mailbox.greeting_message
    end

    def fail_auth
      play config.mailbox.could_not_auth
      hangup
    end
  end
end
