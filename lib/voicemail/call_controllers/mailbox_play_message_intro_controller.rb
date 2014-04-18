module Voicemail
  class MailboxPlayMessageIntroController < ApplicationController

    def run
      load_message
      intro_message
    end

    def intro_message
      play_time_message
      play_from_message
    end

    def play_time_message
      case config.numeric_method
      when :i18n_string
        play [Voicemail::Plugin.config.i18n_provider.t("voicemail.messages.message_received_on"),
              I18n.localize(current_message[:received])]
      when :play_numeric
        play config.messages.message_received_on
        play_time current_message[:received], format: config.datetime_format
      when :ahn_say
        play config.messages.message_received_on
        play *sounds_for_time(current_message[:received], format: config.datetime_format)
      end
    end

    def play_from_message
      case config.numeric_method
      when :i18n_string
        play [Voicemail::Plugin.config.i18n_provider.t("voicemail.messages.message_received_from"), from_words].flatten
      when :play_numeric
        play config.messages.from
        say_characters from_digits unless from_digits.empty?
      when :ahn_say
        play config.messages.from
        play *sounds_for_digits(from_digits)
      end
    end

private

    def from_digits
      current_message[:from].scan(/\d/).join
    end

    def from_words
      from_digits.scan(/./).map do |digit|
        i18n_digit = Voicemail::Plugin.config.i18n_provider.t "numbers.#{digit}"
        i18n_digit =~ /missing/ ? digit : i18n_digit
      end
    end

    def current_message
      @message
    end

    def load_message
      @message = metadata[:message] || nil
      raise ArgumentError, "MailboxPlayMessageIntroController needs a valid message passed to it" unless @message
    end

    def message_uri
      current_message[:uri]
    end
  end
end
