module Voicemail
  class MailboxSetPinController < ApplicationController
    def run
      section_menu
    end

    def section_menu
      menu config.set_pin.menu,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { set_pin }
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

    def set_pin
      pin = ask config.set_pin.prompt, terminator: "#", timeout: 5
      repeat_pin = ask config.set_pin.repeat_prompt, terminator: "#", timeout: 5

      if pin.to_s.nil? || pin.to_s.size < config.set_pin.pin_minimum_digits
        play config.set_pin.pin_error
        set_pin
      elsif pin.to_s != repeat_pin.to_s
        play config.set_pin.match_error
        set_pin
      else
        play config.set_pin.change_ok
        storage.change_pin_for_mailbox mailbox[:id], pin.to_s
        main_menu
      end
    end
  end
end
