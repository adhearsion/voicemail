require 'spec_helper'

describe Voicemail::MailboxPlayMessageIntroController do
  include VoicemailControllerSpecHelper

  let(:some_time) { Time.local 2012, 5, 1, 9, 0, 0 }
  let(:message) do
    {
      id:       123,
      from:     "+39-335135335",
      received: some_time,
      uri:      "file:///path/to/file.mp3"
    }
  end

  describe "#intro_message" do

    before { subject.should_receive(:current_message).and_return message }

    context "with the default mode" do
      it "plays the message introduction" do
        should_play config.messages.message_received_on
        subject.should_receive(:play_time).with some_time, format: config.datetime_format

        should_play config.messages.from
        subject.should_receive(:say_characters).with "39335135335"

        controller.intro_message
      end
    end

    context "with ahnsay" do
      before { config.numeric_method = :ahn_say      }
      after  { config.numeric_method = :play_numeric }

      it "plays the message introduction" do
        should_play config.messages.message_received_on
        subject.should_receive(:sounds_for_time).with(some_time, {}).and_return ["timesounds", ".wav"]
        should_play "timesounds", ".wav"

        should_play config.messages.from
        subject.should_receive(:sounds_for_digits).with("39335135335").and_return ["digit1.wav", "digit2.wav"]
        should_play "digit1.wav", "digit2.wav"

        controller.intro_message
      end
    end
  end
end
