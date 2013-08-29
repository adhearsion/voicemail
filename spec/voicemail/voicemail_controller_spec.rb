require 'spec_helper'

describe Voicemail::VoicemailController do
  include VoicemailControllerSpecHelper

  before do
    subject.should_receive(:answer).once
  end

  describe "#run" do
    context "with a missing mailbox parameter in metadata" do
      let(:metadata) { Hash.new }

      it "should raise an error if there is no mailbox in the metadata" do
        expect { controller.run }.to raise_error ArgumentError
      end
    end

    context "with a present mailbox parameter in metadata" do
      context "with an invalid mailbox" do
        let(:mailbox) { nil }

        it "plays the mailbox not found message and hangs up" do
          should_play config.mailbox_not_found
          subject.should_receive(:hangup).once
          controller.run
        end
      end

      context "with an existing mailbox" do
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
          let(:file_path)           { "/path/to/file" }

          it "saves the recording" do
            recording_component.should_receive("complete_event.recording.uri").and_return(file_path)
            subject.should_receive(:record).with(config.recording.to_hash.merge(interruptible: true, direction: :recv)).and_return(recording_component)
            storage_instance.should_receive(:save_recording).with(mailbox[:id], call.from, file_path)
            should_play
            controller.run
          end
        end
      end

    end
  end
end
