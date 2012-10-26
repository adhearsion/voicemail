require 'spec_helper'

module Voicemail
  describe StoragePstore do
    let(:mailbox) do
      {
        id:               100,
        pin:              1234,
        greeting_message: nil,
        send_email:       true,
        email_address:    'lpradovera@mojolingo.com'
      }
    end

    let(:config) { Voicemail::Plugin.config }

    subject :storage do
      basedir = File.expand_path("../../../tmp/", __FILE__)
      pstore_path = File.join(basedir, 'voicemail.pstore')
      File.unlink(pstore_path) if File.exists?(pstore_path)
      config.storage.pstore_location = pstore_path
      StoragePstore.new.tap do |storage|
        storage.store.transaction do
          storage.store[:mailboxes][100] = mailbox
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

  end
end
