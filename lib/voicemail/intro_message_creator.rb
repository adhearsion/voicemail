module Voicemail
  module IntroMessageCreator

    begin
      require 'ahnsay'
    rescue LoadError
    end

    def intro_message(message)
      fail ArgumentError, 'Must supply a valid message!' unless message
      @current_message = HashWithIndifferentAccess.new message
      Array(time_message) + Array(from_message)
    end

    def time_message
      case config.numeric_method
      when :i18n_string
        t 'voicemail.messages.message_received_on_x', received_on: I18n.localize(message_timestamp)
      when :play_numeric
        [t('voicemail.messages.message_received_on'), time_ssml]
      when :ahn_say
        [
          t('voicemail.messages.message_received_on'),
          Ahnsay.sounds_for_time(message_timestamp, format: config.datetime_format)
        ]
      end
    end

    def from_message
      case config.numeric_method
      when :i18n_string
        t 'voicemail.messages.message_received_from_x', from: from_string
      when :play_numeric
        [t('from'), from_ssml]
      when :ahn_say
        [t('from'), Ahnsay.sounds_for_digits(from_digits)]
      end
    end

private

    def from_digits
      @current_message[:from].scan(/\d/).join
    end

    def from_string
      if @current_message[:from].nil? || @current_message[:from].empty?
        t 'voicemail.unknown_caller'
      else
        "".tap do |string|
          from_digits.each_char do |char|
            digit_word = I18n.t "digits.#{char}.text"
            if digit_word =~ /missing/
              string << char
            else
              string << digit_word
            end
          end
        end
      end
    end

    def time_ssml
      output_formatter.ssml_for_time message_timestamp, format: config.datetime_format
    end

    def message_timestamp
      DateTime.parse @current_message[:received]
    end

    def from_ssml
      if from_digits != ""
        output_formatter.ssml_for_characters from_digits
      else
        "unknown caller"
      end
    end

    def output_formatter
      @output_formatter ||= Adhearsion::CallController::Output::Formatter.new
    end

    def config
      Voicemail::Plugin.config
    end
  end
end
