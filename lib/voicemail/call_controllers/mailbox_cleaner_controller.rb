# encoding: utf-8

module Voicemail 
  class MailboxCleanerController < ApplicationController
    def run
      menu_prompt = metadata[:new_or_saved].to_s == "new" ? config.mailbox.clear_new_messages : config.mailbox.clear_saved_messages
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

      deleting_all_messages = metadata[:new_or_saved].to_s == "new" ? config.mailbox.deleting_all_new_messages : config.mailbox.deleting_all_saved_messages
      play deleting_all_messages

      messages_count.times do
        message = storage.send(method, mailbox[:id])
        storage.delete_message mailbox[:id], message[:id]
      end
        
      all_messages_deleted = metadata[:new_or_saved].to_s == "new" ? config.mailbox.all_new_messages_deleted : config.mailbox.all_saved_messages_deleted
      play all_messages_deleted

      main_menu
    end
  end
end
