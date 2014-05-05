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
        play [t('voicemail.messages.there_are_no'), t("voicemail.#{new_or_saved}_messages")]
      end
    end

    def play_message_count
      case config.numeric_method
      when :i18n_string
        play t("voicemail.mailbox.x_#{new_or_saved}_messages", count: @number)
      when :play_numeric
        play t('voicemail.mailbox.you_have')
        play_numeric @number
        play t("voicemail.#{new_or_saved}_messages")
      when :ahn_say
        play t('voicemail.mailbox.you_have')
        play *sounds_for_number(@number)
        play t("voicemail.#{new_or_saved}_messages")
      end
    end

    def get_count
      @number = storage.count_messages mailbox[:id], new_or_saved
    end
  end
end
