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
          play t('voicemail.mailbox.invalid_pin')
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
      @input = ask t('voicemail.mailbox.enter_pin'), terminator: '#', timeout: config.prompt_timeout
    end

    def play_greeting
      play t('voicemail.mailbox.greeting_message')
    end

    def fail_auth
      play t('voicemail.mailbox.auth_failed')
      hangup
    end
  end
end
