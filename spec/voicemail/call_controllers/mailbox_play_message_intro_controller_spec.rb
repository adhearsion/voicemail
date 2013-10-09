require 'spec_helper'

describe Voicemail::MailboxPlayMessageIntroController do
  include VoicemailControllerSpecHelper

  let(:some_time) { Time.local 2012, 5, 1, 9, 0, 0 }
  let(:message) do
    {
      id:       123,
      from:     "+123",
      received: some_time,
      uri:      "file:///path/to/file.mp3"
    }
  end

  before do
    config.numeric_method = numeric_method
    subject.should_receive(:current_message).and_return message
  end

  describe "#intro_message" do

    after  { subject.intro_message }

    context "with the default mode" do
      let(:numeric_method) { :play_numeric}

      it "plays the message introduction" do
        should_play config.messages.message_received_on
        subject.should_receive(:play_time).with some_time, format: config.datetime_format

        should_play config.messages.from
        subject.should_receive(:say_characters).with "123"
      end
    end

    context "with ahnsay" do
      let(:numeric_method) { :ahn_say }

      it "plays the message introduction" do
        should_play config.messages.message_received_on
        subject.should_receive(:sounds_for_time).with(some_time, {}).and_return ["timesounds", ".wav"]
        should_play "timesounds", ".wav"

        should_play config.messages.from
        subject.should_receive(:sounds_for_digits).with("123").and_return ["digit1.wav", "digit2.wav"]
        should_play "digit1.wav", "digit2.wav"
      end
    end

    context "with i18n_string" do
      let(:numeric_method) { :i18n_string }

      it "plays the message introduction" do
        flexmock(I18n).should_receive(:localize).with(some_time).and_return "some time"
        flexmock(I18n).should_receive(:t).with("voicemail.messages.message_received_on_x", received_on: "some time").and_return "Message received on some time. "
        flexmock(I18n).should_receive(:t).with("numbers.1").and_return "one "
        flexmock(I18n).should_receive(:t).with("numbers.2").and_return "two "
        flexmock(I18n).should_receive(:t).with("numbers.3").and_return "three"
        flexmock(I18n).should_receive(:t).with("voicemail.messages.message_received_from_x", from: "one two three").and_return "Message received from one two three"

        should_play "Message received on some time. "
        should_play "Message received from one two three"
      end
    end
  end

  describe "#play_from_message with i18n_string and missing digit translations" do
    let(:numeric_method) { :i18n_string }

    after { subject.play_from_message }

    it "falls back sanely" do
      flexmock(I18n).should_receive(:t).with("numbers.1").and_return "translation missing"
      flexmock(I18n).should_receive(:t).with("numbers.2").and_return "translation missing"
      flexmock(I18n).should_receive(:t).with("numbers.3").and_return "translation missing"
      flexmock(I18n).should_receive(:t).with("voicemail.messages.message_received_from_x", from: "123").and_return "Message received from 123."
      should_play "Message received from 123."
    end
  end
end
