require 'spec_helper'

describe Voicemail::IntroMessageCreator do
  include FlexMock::ArgumentTypes

  let(:config)  { Voicemail::Plugin.config }
  let(:message) do
    {
      from:     "1234",
      received: Time.local(2012, 5, 1, 9, 0, 0)
    }
  end

  subject { flexmock described_class.new(message) }

  describe "#intro_message" do
    context "in :i18n_string mode" do
      before { config.numeric_method = :i18n_string }

      it "returns the translation" do
        flexmock(I18n).should_receive('localize').with(Time.local(2012, 5, 1, 9, 0, 0)).and_return "9pm"
        I18n.backend.store_translations :en, voicemail: {
          messages: {
            message_received_on_x: "Message received on %{received_on}",
            message_received_from_x: "Message received from %{from}"
          }
        }, numbers: {'1' => "one ", '2' => "two ", '3' => 'three ', '4' => 'four '}

        subject.intro_message.should == ["Message received on 9pm", "Message received from one two three four "]
      end
    end

    context "in :ahn_say mode" do
      let!(:ahn_config) { flexmock(Adhearsion.config, punchblock: OpenStruct.new, ahnsay: OpenStruct.new(sounds_dir: "/")) }

      before do
        config.numeric_method  = :ahn_say
        config.datetime_format = "hmp"
      end

      it "returns a nice array full of ahn_say sound files" do
        subject.intro_message.should == [
          "Message received on ",
          ["/9.ul", "/oclock.ul", "/a-m.ul"],
          " from ",
          ["/1.ul", "/2.ul", "/3.ul", "/4.ul"]
        ]
      end
    end

    context "in :play_numeric mode" do
      let(:formatter)  { flexmock Adhearsion::CallController::Output::Formatter  }
      before do
        flexmock Adhearsion::CallController::Output::Formatter, new: formatter
        config.numeric_method = :play_numeric
      end

      it "returns speech and ssml in an array" do
        formatter.should_receive(:ssml_for_time).with(Time.local(2012, 5, 1, 9, 0, 0), any).and_return :time
        formatter.should_receive(:ssml_for_characters).with('1234').and_return :number
        subject.intro_message.should == ["Message received on ", :time, " from ", :number]
      end
    end
  end
end
