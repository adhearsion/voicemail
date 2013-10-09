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

  before { config.numeric_method = numeric_method }

  let(:numeric_method) { :play_numeric}

  describe "#intro_message" do

    before { subject.should_receive(:current_message).and_return message }
    after  { subject.intro_message }

    context "with the default mode" do
      it "plays the message introduction" do
        should_play config.messages.message_received_on
        subject.should_receive(:play_time).with some_time, format: config.datetime_format

        should_play config.messages.from
        subject.should_receive(:say_characters).with "39335135335"
      end
    end

    context "with ahnsay" do
      let(:numeric_method) {:ahn_say }

      it "plays the message introduction" do
        should_play config.messages.message_received_on
        subject.should_receive(:sounds_for_time).with(some_time, {}).and_return ["timesounds", ".wav"]
        should_play "timesounds", ".wav"

        should_play config.messages.from
        subject.should_receive(:sounds_for_digits).with("39335135335").and_return ["digit1.wav", "digit2.wav"]
        should_play "digit1.wav", "digit2.wav"
      end
    end

    context "with i18n_string" do
      let(:numeric_method) {:i18n_string }

      it "plays the message introduction" do
        flexmock(I18n).should_receive(:localize).with(some_time).and_return "some time"
        flexmock(I18n).should_receive(:t).with("voicemail.messages.message_received_on_x", received_on: "some time").and_return "Message received on some time. "
        flexmock(I18n).should_receive(:t).with("voicemail.messages.message_received_from_x", from: "39335135335").and_return "Message received from 39335135335. "

        should_play "Message received on some time. "
        should_play "Message received from 39335135335. "
      end
    end
  end
end
