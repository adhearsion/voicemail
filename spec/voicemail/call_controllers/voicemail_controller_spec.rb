require 'spec_helper'

describe Voicemail::VoicemailController do
  include VoicemailControllerSpecHelper

  describe '#run' do
    context 'with a missing mailbox parameter in metadata' do
      let(:metadata) { Hash.new }

      it 'should raise an error if there is no mailbox in the metadata' do
        subject.should_receive(:answer).once
        expect { controller.run }.to raise_error ArgumentError
      end
    end

    context 'When when_to_answer is :after_greeting and there is no mailbox' do
      let(:mailbox) { nil }

      before { config.when_to_answer = :after_greeting  }
      after  { config.when_to_answer = :before_greeting }

      it 'should not answer' do
        subject.should_receive(:t).with('voicemail.mailbox_not_found').and_return 'Mailbox not found'
        should_play 'Mailbox not found'
        subject.should_receive(:hangup).once
        controller.run
      end
    end

    context 'with a present mailbox parameter in metadata' do
      before { subject.should_receive(:answer).once }

      context 'with an invalid mailbox' do
        let(:mailbox) { nil }

        it 'plays the mailbox not found message and hangs up' do
          subject.should_receive(:t).with('voicemail.mailbox_not_found').and_return 'Mailbox not found'
          should_play 'Mailbox not found'
          subject.should_receive(:hangup).once
          controller.run
        end
      end

      context 'with an existing mailbox' do
        let(:ask_result) { flexmock 'Result', status: :noinput, response: nil }

        def default_output_expectations
          subject.should_receive(:t).with('voicemail.default_greeting').and_return 'Hiyas!'
          subject.should_receive(:t).with('voicemail.recording_confirmation').and_return 'Recording saved'
          should_ask('Hiyas!', limit: 1, timeout: config.go_to_menu_timeout).and_return ask_result
          subject.should_receive :record_message
          should_play 'Recording saved'
        end

        context 'with a message that is not interrupted' do
          before { subject.should_receive(:hangup).once }

          context 'without a greeting message' do
            it 'plays the default greeting if one is not specified' do
              default_output_expectations
              controller.run
            end
          end

          context 'with a specified greeting message' do
            let(:greeting) { 'Howdy!' }

            it 'plays the specific greeting message' do
              subject.should_receive(:t).with('voicemail.recording_confirmation').and_return 'Recording saved'
              should_ask(greeting, limit: 1, timeout: config.go_to_menu_timeout).and_return ask_result
              subject.should_receive :record_message
              should_play 'Recording saved'
              controller.run
            end
          end
        end

        context 'when the greeting message is interrupted' do
          context 'with the correct digit' do
            let(:ask_result) { flexmock 'Result', status: :match, response: '#' }
            it 'should pass control to the AuthenticationController' do
              subject.should_receive(:t).with('voicemail.default_greeting').and_return 'Hiyas!'
              should_ask('Hiyas!', limit: 1, timeout: config.go_to_menu_timeout).and_return ask_result
              subject.should_receive(:pass).with(Voicemail::AuthenticationController, { mailbox: mailbox[:id], storage: storage_instance })
              controller.run
            end
          end
          context 'with an incorrect digit' do
            let(:ask_result) { flexmock 'Result', status: :match, response: '1' }
            it 'executes the normal output, recording and hangup' do
              default_output_expectations
              subject.should_receive(:hangup).once
              controller.run
            end
          end
        end
      end
    end
  end

  describe '#record_message' do
    context 'handling a recording' do
      let(:recording_component) { flexmock 'Record' }
      let(:recording_object)    { flexmock 'complete_event.recording', uri: 'http://some_file.wav' }

      after { subject.record_message }

      context 'without allow_rerecording' do
        before { config.allow_rerecording = false }

        it "saves the recording" do
          call.should_receive :on_end
          recording_component.should_receive("complete_event.recording").and_return recording_object
          subject.should_receive(:record).with(config.recording.to_hash).and_return recording_component
          storage_instance.should_receive(:save_recording).with mailbox[:id], :new, call.from, recording_object
        end
      end

      context 'with allow_rerecording' do
        before { config.allow_rerecording = true }

        it 'sets up a callback, plays a menu, and eventually saves the message' do
          call.should_receive :on_end
          recording_object.should_receive :uri
          subject.should_receive(:t).with('voicemail.after_record').and_return 'after_record'
          subject.should_receive(:menu)
          recording_component.should_receive('complete_event.recording').and_return recording_object
          subject.should_receive(:record).with(config.recording.to_hash).and_return recording_component
          storage_instance.should_receive(:save_recording).with mailbox[:id], :new, call.from, recording_object
        end
      end
    end
  end
end
