require 'spec_helper'

module Voicemail
  describe StoragePstore do
    let(:mailbox) do
      {
        id:            100,
        pin:           1234,
        greeting:      nil,
        send_email:    true,
        email_address: 'lpradovera@mojolingo.com'
      }
    end

    let(:config) { Voicemail::Plugin.config }

    let(:message_1) { {id: :foo} }
    let(:message_2) { {id: :bar} }
    let(:message_3) { {id: :biz} }

    subject :storage do
      basedir = File.expand_path("../../../tmp/", __FILE__)
      pstore_path = File.join(basedir, 'voicemail.pstore')
      File.unlink(pstore_path) if File.exists?(pstore_path)
      config.storage.pstore_location = pstore_path
      StoragePstore.new.tap do |storage|
        storage.store.transaction do |store|
          store[:new][100]       = [message_1]
          store[:saved][100]     = [message_2, message_3]
          store[:mailboxes][100] = mailbox
        end
        flexmock storage
      end
    end

    it "is a PStore" do
      storage.store.should be_a PStore
    end

    describe "#get_mailbox" do
      it "returns the mailbox if it exists" do
        storage.get_mailbox(100).should == mailbox
      end

      it "returns nil if the mailbox does not exist" do
        storage.get_mailbox(400).should be_nil
      end
    end

    describe "#save_recording" do
      let(:recording_object) { flexmock 'recording_object', uri: "file://somewav.wav" }

      it "saves the recording" do
        storage.save_recording(100, :new, "foo", recording_object)
        storage.store.transaction do |store|
          store[:new][100].last[:uri].should  == "file://somewav.wav"
          store[:new][100].last[:from].should == "foo"
          store[:new][100].last[:id].should_not be_nil
        end
      end
    end

    describe "#count_messages" do
      it "returns the new message count" do
        storage.count_messages(100, :new).should == 1
      end

      it "returns the saved message count" do
        storage.count_messages(100, :saved).should == 2
      end
    end

    describe '#get_messages' do
      it 'returns all new messages' do
        storage.get_messages(100, :new).should == [{ id: :foo }]
      end

      it 'returns all saved messages' do
        storage.get_messages(100, :saved).should == [{ id: :bar }, { id: :biz }]
      end
    end

    describe "#change_message_type" do
      it "changes the message type to :saved" do
        storage.change_message_type 100, :foo, :new, :saved
        storage.store.transaction do |store|
          store[:new][100].should   == []
          store[:saved][100].should == [message_2, message_3, message_1]
        end
      end

      it "changes the message type to :new" do
        storage.change_message_type 100, :bar, :saved, :new
        storage.store.transaction do |store|
          store[:new][100].should   == [message_1, message_2]
          store[:saved][100].should == [message_3]
        end
      end
    end

    describe "#delete_greeting_from_mailbox" do
      before do
        storage.store.transaction do |store|
          store[:mailboxes][100][:greeting] = "/some/path"
        end
      end

      it "deletes the greeting message" do
        storage.delete_greeting_from_mailbox 100
        storage.store.transaction do |store|
          store[:mailboxes][100][:greeting].should be_nil
        end
      end
    end
  end
end
