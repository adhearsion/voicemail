module Voicemail
  class MailboxMainMenuController < ApplicationController
    def run
      main_menu
    end

    def main_menu
      menu config[:voicemail].mailbox.menu_greeting,
         :timeout => config[:voicemail].menu_timeout, :tries => config[:voicemail].menu_tries do
        match 1 do 
          listen_to_messages
        end
        match 2 do 
          set_greeting
        end
        match 3 do 
          set_pin
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

    def set_greeting
        invoke MailboxSetGreetingController, :mailbox => mailbox[:id]
    end

    def set_pin
        invoke MailboxSetPinController, :mailbox => mailbox[:id]
    end

  end
end
