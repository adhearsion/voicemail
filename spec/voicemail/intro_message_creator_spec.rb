require 'spec_helper'

describe Voicemail::IntroMessageCreator do
  include FlexMock::ArgumentTypes

  context 'included in a CallController' do
    let(:config)  { Voicemail::Plugin.config }
    let(:message) do
      {
        from:     '1234',
        received: Time.local(2012, 5, 1, 9, 0, 0)
      }
    end
    let(:call) { flexmock 'Call', from: 'sip:user@server.com' }
    let(:metadata) { Hash.new }
    let(:call_controller_class) do
      class MyCallController < Adhearsion::CallController
        include Voicemail::IntroMessageCreator
      end
    end

    subject { flexmock call_controller_class.new call, metadata }

    describe '#intro_message' do
      context 'in :i18n_string mode' do
        before { config.numeric_method = :i18n_string }

        it 'returns the translation' do
          flexmock(I18n).should_receive('localize').with(Time.local(2012, 5, 1, 9, 0, 0)).and_return '9pm'
          subject.should_receive(:t).with('voicemail.messages.message_received_on_x', received_on: '9pm').and_return 'Message received at 9pm'
          subject.should_receive(:t).with('voicemail.messages.message_received_from_x', from: '1234').and_return 'Message received from 1234'
          subject.intro_message(message).should == ['Message received at 9pm', 'Message received from 1234']
        end
      end

      context 'in :ahn_say mode' do
        let!(:ahn_config) { flexmock(Adhearsion.config, punchblock: OpenStruct.new, ahnsay: OpenStruct.new(sounds_dir: '/')) }

        before do
          config.numeric_method  = :ahn_say
          config.datetime_format = 'hmp'
        end

        it 'returns a nice array full of ahn_say sound files' do
          subject.should_receive(:t).with('voicemail.messages.message_received_on').and_return 'Message received on '
          subject.should_receive(:t).with('from').and_return ' from '
          subject.intro_message(message).should == [
            'Message received on ',
            ['/9.ul', '/oclock.ul', '/a-m.ul'],
            ' from ',
            ['/1.ul', '/2.ul', '/3.ul', '/4.ul']
          ]
        end
      end

      context 'in :play_numeric mode' do
        let(:formatter)  { flexmock Adhearsion::CallController::Output::Formatter  }
        before do
          flexmock Adhearsion::CallController::Output::Formatter, new: formatter
          config.numeric_method = :play_numeric
        end

        it 'returns speech and ssml in an array' do
          formatter.should_receive(:ssml_for_time).with(Time.local(2012, 5, 1, 9, 0, 0), any).and_return :time
          formatter.should_receive(:ssml_for_characters).with('1234').and_return :number
          subject.should_receive(:t).with('voicemail.messages.message_received_on').and_return 'Message received on '
          subject.should_receive(:t).with('from').and_return ' from '
          subject.intro_message(message).should == ['Message received on ', :time, ' from ', :number]
        end
      end
    end
  end
end
