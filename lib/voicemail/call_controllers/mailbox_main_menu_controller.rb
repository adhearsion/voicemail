module Voicemail
  class MailboxMainMenuController < ApplicationController
    def run
      main_menu
    end

    def main_menu
      menu_prompt = [
        t('voicemail.mailbox.menu.listen_to_new'),
        t('voicemail.mailbox.menu.listen_to_saved'),
        t('voicemail.mailbox.menu.change_greeting'),
        t('voicemail.mailbox.menu.change_pin'),
        t('voicemail.mailbox.menu.delete_all_new'),
        t('voicemail.mailbox.menu.delete_all_saved')
      ]
      menu menu_prompt,
         timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { listen_to_new_messages }
        match(2) { listen_to_saved_messages }
        match(3) { set_greeting }
        match(4) { set_pin }
        match(7) { clear_new_messages }
        match(9) { clear_saved_messages }

        timeout do
          play t('voicemail.mailbox.menu.timeout')
        end

        invalid do
          play t('voicemail.mailbox.menu.invalid')
        end

        failure do
          play t('voicemail.mailbox.menu.failure')
          hangup
        end
      end
    end

    def set_greeting
      invoke MailboxSetGreetingController, metadata
    end

    def set_pin
      invoke MailboxSetPinController, metadata
    end

    def listen_to_new_messages
      invoke MailboxMessagesController, metadata
    end

    def listen_to_saved_messages
      invoke MailboxMessagesController, metadata.merge(new_or_saved: :saved)
    end

    def clear_new_messages
      invoke MailboxCleanerController, metadata.merge(new_or_saved: :new)
    end

    def clear_saved_messages
      invoke MailboxCleanerController, metadata.merge(new_or_saved: :saved)
    end
  end
end
