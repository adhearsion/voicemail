require 'spec_helper'

describe Voicemail::MailboxCleanerController do
  include VoicemailControllerSpecHelper
  describe "#run" do
    context "new messages" do
      subject { flexmock(Voicemail::MailboxCleanerController.new call, {new_or_saved: :new}) }
      it 'should call #menu with the proper arguments' do
        subject.should_receive(:t).with('voicemail.mailbox.clear_new_messages').and_return 'clear_new'
        subject.should_receive(:t).with('voicemail.press_one_to_confirm').and_return 'press_one_to_confirm'
        subject.should_receive(:t).with('voicemail.mailbox.any_key_to_cancel').and_return 'any_key_to_cancel'
        subject.should_receive(:menu).with(['clear_new', 'press_one_to_confirm', 'any_key_to_cancel'],
          { timeout: config.menu_timeout, tries: config.menu_tries }, Proc)
        subject.run
      end
    end

    context "saved messages" do
      subject { flexmock(Voicemail::MailboxCleanerController.new call, {new_or_saved: :saved}) }
      it 'should call #menu with the proper arguments' do
        subject.should_receive(:t).with('voicemail.mailbox.clear_saved_messages').and_return 'clear_saved'
        subject.should_receive(:t).with('voicemail.press_one_to_confirm').and_return 'press_one_to_confirm'
        subject.should_receive(:t).with('voicemail.mailbox.any_key_to_cancel').and_return 'any_key_to_cancel'
        subject.should_receive(:menu).with(['clear_saved', 'press_one_to_confirm', 'any_key_to_cancel'],
          { timeout: config.menu_timeout, tries: config.menu_tries }, Proc)
        subject.run
      end
    end
  end
end
