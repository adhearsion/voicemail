require 'spec_helper'

describe Voicemail::IntroMessageCreator do

  context 'included in a CallController' do
    let(:config)  { Voicemail::Plugin.config }
    let(:message) do
      {
        from:     '1234',
        received: Time.local(2012, 5, 1, 9, 0, 0)
      }
    end
    let(:call) { double Adhearsion::Call, from: 'sip:user@server.com' }
    let(:metadata) { Hash.new }
    let(:call_controller_class) do
      class MyCallController < Adhearsion::CallController
        include Voicemail::IntroMessageCreator
      end
    end

    subject { call_controller_class.new call, metadata }

    describe '#intro_message' do
      context 'in :i18n_string mode' do
        before do
          config.numeric_method = :i18n_string
          expect(I18n).to receive('localize').with(message[:received]).and_return '9pm'
          expect(subject).to receive(:t).with('voicemail.messages.message_received_on_x', received_on: '9pm').and_return 'Message received at 9pm'
        end

        it 'returns the translation' do
          expect(subject).to receive(:t).with('voicemail.messages.message_received_from_x', from: message[:from]).and_return 'Message received from 1234'
          expect(subject.intro_message(message)).to eq ['Message received at 9pm', 'Message received from 1234']
        end

        it 'handles an unknown caller' do
          unk_caller_msg = message.dup
          unk_caller_msg[:from] = ''
          expect(subject).to receive(:t).with('voicemail.unknown_caller').and_return 'an unknown caller'
          expect(subject).to receive(:t).with('voicemail.messages.message_received_from_x', from: 'an unknown caller').and_return 'Message received from an unknown caller'
          expect(subject.intro_message(unk_caller_msg)).to eq ['Message received at 9pm', 'Message received from an unknown caller']
        end

        it 'handles stringified keys' do
          message = { 'from' => '1234', 'received' => Time.local(2012, 5, 1, 9, 0, 0) }
          expect(subject).to receive(:t).with('voicemail.messages.message_received_from_x', from: message['from']).and_return 'Message received from 1234'
          expect(subject.intro_message(message)).to eq ['Message received at 9pm', 'Message received from 1234']
        end
      end

      context 'in :ahn_say mode' do

        before do
          Adhearsion.config.ahnsay.sounds_dir = '/'
          config.numeric_method  = :ahn_say
          config.datetime_format = 'hmp'
        end

        it 'returns a nice array full of ahn_say sound files' do
          expect(subject).to receive(:t).with('voicemail.messages.message_received_on').and_return 'Message received on '
          expect(subject).to receive(:t).with('from').and_return ' from '
          expect(subject.intro_message(message)).to eq [
            'Message received on ',
            ['file:///9.ul', 'file:///oclock.ul', 'file:///a-m.ul'],
            ' from ',
            ['file:///1.ul', 'file:///2.ul', 'file:///3.ul', 'file:///4.ul']
          ]
        end
      end

      context 'in :play_numeric mode' do
        let(:formatter)  { double Adhearsion::CallController::Output::Formatter  }
        before do
          config.numeric_method = :play_numeric
        end

        it 'returns speech and ssml in an array' do
          pending "Get rid of these mocks"
          expect(formatter).to receive(:ssml_for_time).with(Time.local(2012, 5, 1, 9, 0, 0), any_args).and_return :time
          expect(formatter).to receive(:ssml_for_characters).with('1234').and_return :number
          expect(subject).to receive(:t).with('voicemail.messages.message_received_on').and_return 'Message received on '
          expect(subject).to receive(:t).with('from').and_return ' from '
          expect(subject.intro_message(message)).to eq ['Message received on ', :time, ' from ', :number]
        end
      end
    end
  end
end
