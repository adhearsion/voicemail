require 'spec_helper'

describe Voicemail::VoicemailController do
  include VoicemailControllerSpecHelper

  describe "#run" do
    context "with a missing mailbox parameter in metadata" do
      let(:metadata) { Hash.new }

      it "should raise an error if there is no mailbox in the metadata" do
        subject.should_receive(:answer).once
        expect { controller.run }.to raise_error ArgumentError
      end
    end

    context "When when_to_answer is :after_greeting and there's no mailbox" do
      let(:mailbox) { nil }

      before { config.when_to_answer = :after_greeting  }
      after  { config.when_to_answer = :before_greeting }

      it "should not answer" do
        should_play config.mailbox_not_found
        subject.should_receive(:hangup).once
        controller.run
      end
    end

    context "with a present mailbox parameter in metadata" do
      before { subject.should_receive(:answer).once }

      context "with an invalid mailbox" do
        let(:mailbox) { nil }

        it "plays the mailbox not found message and hangs up" do
          should_play config.mailbox_not_found
          subject.should_receive(:hangup).once
          controller.run
        end
      end

      context "with an existing mailbox" do
        before { subject.should_receive(:hangup).once }

        context "without a greeting message" do
          it "plays the default greeting if one is not specified" do
            should_play config.default_greeting
            subject.should_receive(:handle_recording).and_return(true)
            controller.run
          end
        end

        context "with a specified greeting message" do
          let(:greeting_message) { "Howdy!" }

          it "plays the specific greeting message" do
            should_play greeting_message
            subject.should_receive(:handle_recording).and_return(true)
            controller.run
          end
        end

        context "handling a recording" do
          let(:recording_component) { flexmock 'Record' }
          let(:recording_object)    { flexmock 'complete_event.recording' }

          it "saves the recording" do
            recording_component.should_receive("complete_event.recording").and_return recording_object
            subject.should_receive(:record).with(config.recording.to_hash.merge(interruptible: true, direction: :recv)).and_return(recording_component)
            storage_instance.should_receive(:save_recording).with mailbox[:id], call.from, recording_object
            should_play
            controller.run
          end
        end
      end
    end
  end
end
