require 'spec_helper'

describe Voicemail::MailboxPlayMessageController do
  include VoicemailControllerSpecHelper

  let(:message) do
    {
      id:       123,
      from:     "+39-335135335",
      received: Time.local(2012, 5, 1, 9, 0, 0),
      uri:      "/path/to/file"
    }
  end

  describe "#archive_message" do
    it "archives the message" do
      subject.should_receive(:current_message).once.and_return(message)
      storage_instance.should_receive(:archive_message).once.with(mailbox[:id], message[:id])
      controller.archive_message
    end
  end

  describe "#delete_message" do
    it "deletes the message" do
      subject.should_receive(:current_message).once.and_return(message)
      storage_instance.should_receive(:delete_message).once.with(mailbox[:id], message[:id])
      controller.delete_message
    end
  end

  describe "#intro_message" do
    it "plays the message introduction" do
      subject.should_receive(:current_message).and_return(message)
      should_play config.messages.message_received_on
      subject.should_receive(:play_time).once.with(message[:received], format: config.datetime_format)
      should_play config.messages.from
      subject.should_receive(:execute).once.with("SayDigits", "39335135335")
      controller.intro_message
    end
  end

  describe "#play_message" do
    it "plays the message, followed by the menu" do
      subject.should_receive(:current_message).once.and_return(message)
      subject.should_receive(:menu).once.with(message[:uri], config.messages.menu,
        { timeout: config.menu_timeout, tries: config.menu_tries }, Proc)
      subject.play_message
    end
  end

  describe "#load_message" do

    context "with a message" do
      let(:metadata) { {message: "foo"} }

      it "loads the messge" do
        subject.load_message
        subject.current_message.should == "foo"
      end
    end

    context "with no message passed" do
      let(:metadata) { {message: nil} }

      it "raises an error" do
        expect { subject.load_message }.to raise_error ArgumentError
      end
    end
  end
end
