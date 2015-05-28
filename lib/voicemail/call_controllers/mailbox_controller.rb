module Voicemail
  class MailboxController < ApplicationController

    attr_accessor :new_or_saved

    def run
      if mailbox
        play_number_of_messages :new
        play_number_of_messages :saved
        main_menu
      else
        mailbox_not_found
      end
    end

    def play_number_of_messages(new_or_saved)
      @new_or_saved = new_or_saved
      get_count

      if @number > 0
        play_message_count
      else
        play config.messages["no_#{new_or_saved}_messages".to_sym]
      end
    end

    def play_message_count
      case config.numeric_method
      when :i18n_string
        play build_message_count_message(@number)
      when :play_numeric
        play config.mailbox.number_before
        play_numeric @number
        play config.mailbox["number_after_#{new_or_saved}".to_sym]
      when :ahn_say
        play config.mailbox.number_before
        play *sounds_for_number(@number)
        play config.mailbox["number_after_#{new_or_saved}".to_sym]
      end
    end

    def get_count
      @number = storage.send "count_#{new_or_saved}_messages", mailbox[:id]
    end

    def build_message_count_message(count)
      pluralized_message_key = count == 1 ? "message" : "messages"
      [Voicemail::Plugin.config.i18n_provider.t("voicemail.mailbox.message_count_prefix"),
       count,
       Voicemail::Plugin.config.i18n_provider.t("voicemail.mailbox.#{new_or_saved}_#{pluralized_message_key}")]
    end
  end
end
