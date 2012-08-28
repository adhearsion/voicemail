require 'spec_helper'

module Voicemail
  describe MailboxSetGreetingController do
    
    let(:call) { flexmock('Call') }
    let(:config) { Voicemail::Plugin.config }
    let(:metadata) do 
      { :mailbox => '100' }
    end
    let(:greeting_message) { nil }
    let(:mailbox) do
      {
        :id => 100,
        :pin => 1234,
        :greeting_message => greeting_message,
        :send_email => true,
        :email_address => "lpradovera@mojolingo.com"
      }
    end
    let(:storage_instance) { flexmock('StorageInstance') }

    let(:controller){ Voicemail::MailboxSetGreetingController.new call, metadata }
    subject { flexmock controller }

    before(:each) do
      storage_instance.should_receive(:get_mailbox).with(metadata[:mailbox]).and_return(mailbox)
      flexmock(Storage).should_receive(:instance).and_return(storage_instance)
    end

    describe "#section_menu" do
      it "calls #menu with the proper parameters" do
        subject.should_receive(:menu).once.with(Adhearsion.config[:voicemail].set_greeting.prompt,
            {:timeout => Adhearsion.config[:voicemail].menu_timeout,
              :tries => Adhearsion.config[:voicemail].menu_tries}, Proc)
        controller.section_menu
      end
    end

    describe "#listen_to_current_greeting" do
      context "without a greeting message" do
        it "plays the default greeting if one is not specified" do
          subject.should_receive(:play).once.with(Adhearsion.config[:voicemail].set_greeting.no_personal_greeting)
          subject.should_receive(:section_menu).once.and_return(true)
          controller.listen_to_current_greeting 
        end
      end

      context "with a specified greeting message" do
        let(:greeting_message) { "Howdy!" }
        it "plays the specific greeting message" do
          subject.should_receive(:play).once.with(greeting_message)
          subject.should_receive(:section_menu).once.and_return(true)
          controller.listen_to_current_greeting
        end
      end
    end

    describe "#record_greeting" do
      let(:recording_component) { flexmock('Record') }
      let(:file_path) { "/path/to/file" }
      it "plays the appropriate sounds, records, plays back recording, and calls the recording menu" do
        subject.should_receive(:play).once.with(Adhearsion.config[:voicemail].set_greeting.before_record)
        recording_component.should_receive("complete_event.recording.uri").and_return(file_path)
        subject.should_receive(:record).once.with(Adhearsion.config[:voicemail].set_greeting.recording.to_hash.merge(:interruptible => true, :max_duration => 30_000)).and_return(recording_component)
        subject.should_receive(:play).once.with(file_path)
        subject.should_receive(:menu).once.with(Adhearsion.config[:voicemail].set_greeting.after_record,
            {:timeout => Adhearsion.config[:voicemail].menu_timeout,
              :tries => Adhearsion.config[:voicemail].menu_tries}, Proc)
        controller.record_greeting
      end
    end

    describe "#save_greeting" do
      let(:file_path) { "/path/to/file" }
      it "saves the greeting and goes to the main menu" do
        subject.should_receive(:temp_recording).once.and_return(file_path)
        storage_instance.should_receive(:save_greeting_for_mailbox).with(mailbox[:id], file_path)
        subject.should_receive(:main_menu)
        controller.save_greeting
      end
    end

  end
end
