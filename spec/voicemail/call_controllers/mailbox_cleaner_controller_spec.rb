require 'spec_helper'

describe Voicemail::MailboxCleanerController do
  include VoicemailControllerSpecHelper
  describe "#run" do
    context "new messages" do
      subject { flexmock(Voicemail::MailboxCleanerController.new call, {new_or_saved: :new}) }
      it 'should call #menu with the proper arguments' do
        subject.should_receive(:menu).with(config.mailbox.clear_new_messages, 
          { timeout: config.menu_timeout, tries: config.menu_tries }, Proc)
        subject.run
      end
    end

    context "saved messages" do
      subject { flexmock(Voicemail::MailboxCleanerController.new call, {new_or_saved: :saved}) }
      it 'should call #menu with the proper arguments' do
        subject.should_receive(:menu).with(config.mailbox.clear_saved_messages, 
          { timeout: config.menu_timeout, tries: config.menu_tries }, Proc)
        subject.run
      end
    end
  end
end