module Voicemail
  class MailboxSetPinController < ApplicationController
    def run
      section_menu
    end

    def section_menu
      menu t('voicemail.set_pin.menu.change_pin'), t('voicemail.return_to_main_menu'),
         timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { set_pin }
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

    def set_pin
      pin = ask t('voicemail.set_pin.enter_new_pin'), terminator: '#', timeout: 5
      repeat_pin = ask t('voicemail.set_pin.repeat_pin'), terminator: '#', timeout: 5

      if pin.to_s.nil? || pin.to_s.size < config.set_pin.pin_minimum_digits
        play t('voicemail.set_pin.pin_error')
        set_pin
      elsif pin.to_s != repeat_pin.to_s
        play t('voicemail.set_pin.match_error')
        set_pin
      else
        play t('voicemail.set_pin.pin_successfully_changed')
        storage.change_pin_for_mailbox mailbox[:id], pin.to_s
        main_menu
      end
    end
  end
end
