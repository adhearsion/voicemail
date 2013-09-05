module Voicemail
  class AuthenticationController < ApplicationController

    attr_accessor :tries, :auth_ok, :input

    def initialize(call, metadata={})
      @tries   = 0
      @auth_ok = false

      super call, metadata
    end

    def run
      if mailbox
        play_greeting
        authenticate
        fail_auth unless auth_ok
        pass MailboxController, mailbox: mailbox[:id]
      else
        mailbox_not_found
      end
    end

    def authenticate
      while still_going?
        @tries += 1
        get_input
        if matches?
          @auth_ok = true
        else
          play config.mailbox.pin_wrong
        end
      end
    end

    private

    def still_going?
      return false if auth_ok
      config.mailbox.pin_tries == 0 || tries < config.mailbox.pin_tries
    end

    def matches?
      config.matcher_class.new(input, mailbox[:pin]).matches?
    end

    def get_input
      @input = ask config.mailbox.please_enter_pin, terminator: "#", timeout: config.prompt_timeout
    end

    def play_greeting
      play config.mailbox.greeting_message
    end

    def fail_auth
      play config.mailbox.could_not_auth
      hangup
    end
  end
end
