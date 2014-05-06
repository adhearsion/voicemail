# encoding: utf-8

module Voicemail 
  class MailboxCleanerController < ApplicationController
    def run
      menu_prompt = [t("voicemail.mailbox.clear_#{metadata[:new_or_saved]}_messages"), t('voicemail.press_one_to_confirm'), t('voicemail.mailbox.any_key_to_cancel')]
      menu menu_prompt, timeout: config.menu_timeout, tries: config.menu_tries do
        match(1) { erase_all metadata[:new_or_saved] }
   
        invalid { confirm_no_action_taken }
        timeout { confirm_no_action_taken }
        failure { confirm_no_action_taken }
      end
    end
   
    def confirm_no_action_taken
      play config.mailbox.no_messages_deleted
      main_menu
    end
   
    def erase_all(type)
      method = "next_#{type}_message"

      messages_count = storage.send "count_#{type}_messages", mailbox[:id]   

      deleting_all_messages = [t('voicemail.mailbox.all_of_your'), t("voicemail.#{metadata[:new_or_saved]}_messages"), t('voicemail.mailbox.are_being_deleted')]
      play deleting_all_messages

      messages_count.times do
        message = storage.send(method, mailbox[:id])
        storage.delete_message mailbox[:id], message[:id]
      end
        
      all_messages_deleted = [t('voicemail.mailbox.all_of_your'), t("voicemail.#{metadata[:new_or_saved]}_messages"), t('voicemail.mailbox.successfully_deleted')]
      play all_messages_deleted

      main_menu
    end
  end
end
