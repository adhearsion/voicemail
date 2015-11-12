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
      let(:recording_object) { double 'recording_object', uri: "file://somewav.wav" }

      it "saves the recording" do
        storage.save_recording(100, :new, "foo", recording_object)
        storage.store.transaction do |store|
          expect(store[:new][100].last[:uri]).to  eq "file://somewav.wav"
          expect(store[:new][100].last[:from]).to eq "foo"
          expect(store[:new][100].last[:id]).to_not be_nil
        end
      end
    end

    describe "#count_messages" do
      it "returns the new message count" do
        expect(storage.count_messages(100, :new)).to eq 1
      end

      it "returns the saved message count" do
        expect(storage.count_messages(100, :saved)).to eq 2
      end
    end

    describe '#get_messages' do
      it 'returns all new messages' do
        expect(storage.get_messages(100, :new)).to eq [{ id: :foo }]
      end

      it 'returns all saved messages' do
        expect(storage.get_messages(100, :saved)).to eq [{ id: :bar }, { id: :biz }]
      end
    end

    describe "#change_message_type" do
      it "changes the message type to :saved" do
        storage.change_message_type 100, :foo, :new, :saved
        storage.store.transaction do |store|
          expect(store[:new][100]).to eq []
          expect(store[:saved][100]).to eq [message_2, message_3, message_1]
        end
      end

      it "changes the message type to :new" do
        storage.change_message_type 100, :bar, :saved, :new
        storage.store.transaction do |store|
          expect(store[:new][100]).to   eq [message_1, message_2]
          expect(store[:saved][100]).to eq [message_3]
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
          expect(store[:mailboxes][100][:greeting]).to be_nil
        end
      end
    end
  end
end
