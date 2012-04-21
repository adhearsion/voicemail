require 'spec_helper'

module Voicemail
  describe VoicemailController do
    
    let(:from) { "sip:user@server.com" }
    let(:call) { flexmock('Call', :from => from) }
    let(:config) { Voicemail::Plugin.config }
    let(:metadata) do 
      { :mailbox => '100' }
    end
    let(:greeting_message) { nil }
    let(:mailbox) do
      {
        :id => 100,
        :pin => 1234,
        :greeting_message => greeting_message
      }
    end
    let(:storage_instance) { flexmock('StorageInstance') }

    let(:controller){ Voicemail::VoicemailController.new call, metadata }
    subject { flexmock controller }

    before(:each) do
      storage_instance.should_receive(:get_mailbox).with(metadata[:mailbox]).and_return(mailbox)
      flexmock(Storage).should_receive(:instance).and_return(storage_instance)
    end

    describe "#init_mailbox" do
      context "with a missing mailbox parameter in metadata" do
        let(:metadata) { Hash.new }
        it "should raise an error if there is no mailbox in the metadata" do
          expect { controller.init_mailbox }.to raise_error ArgumentError
        end
      end
    end

    describe "#run" do
      context "with a present mailbox parameter in metadata" do
        context "with an invalid mailbox" do
          let(:mailbox) { nil }
          it "plays the mailbox not found message and hangs up" do
            subject.should_receive(:play).once.with(Adhearsion.config[:voicemail].mailbox_not_found)
            subject.should_receive(:hangup).once
            controller.run
          end
        end
        
        context "without a greeting message" do
          it "plays the default greeting if one is not specified" do
            subject.should_receive(:play).once.with(Adhearsion.config[:voicemail].default_greeting)
            subject.should_receive(:handle_recording).and_return(true)
            controller.run 
          end
        end

        context "with a specified greeting message" do
          let(:greeting_message) { "Howdy!" }
          it "plays the specific greeting message" do
            subject.should_receive(:play).once.with(greeting_message)
            subject.should_receive(:handle_recording).and_return(true)
            controller.run
          end
        end
      end
    end

    describe "#save_recording" do
      let(:uri) { "/path/to/file.wav" }
      it "saves a recording passing the correct parameters" do
        storage_instance.should_receive(:save_recording).with(mailbox[:id], call.from, uri)
        controller.init_mailbox()
        controller.save_recording(uri)
      end
    end

  end#describe VoicemailController
end
