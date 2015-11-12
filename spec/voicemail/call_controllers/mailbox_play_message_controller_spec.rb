require 'spec_helper'

describe Voicemail::MailboxPlayMessageController do
  include VoicemailControllerSpecHelper

  let(:message) do
    {
      id:       123,
      from:     '+39-335135335',
      received: Time.local(2012, 5, 1, 9, 0, 0),
      uri:      'file:///path/to/file.mp3'
    }
  end

  describe '#archive_or_unarchive_message' do

    after { controller.archive_or_unarchive_message }

    context 'with a new message' do
      before { subject.new_or_saved = :new }

      it 'archives the message' do
        subject.should_receive(:current_message).once.and_return message
        storage_instance.should_receive(:change_message_type).once.with mailbox[:id], message[:id], :new, :saved
      end
    end

    context 'with a saved message' do
      before { subject.new_or_saved = :saved }

      it 'unarchives the message' do
        subject.should_receive(:current_message).once.and_return message
        storage_instance.should_receive(:change_message_type).once.with mailbox[:id], message[:id], :saved, :new
      end
    end
  end

  describe '#delete_message' do
    it 'deletes the message' do
      subject.should_receive(:t).with('voicemail.messages.message_deleted').and_return 'message_deleted'
      subject.should_receive(:current_message).once.and_return(message)
      storage_instance.should_receive(:delete_message).once.with(mailbox[:id], message[:id], :new)
      subject.should_receive(:play).once.with('message_deleted')
      controller.delete_message
    end
  end

  describe '#play_message' do
    before do
      ['delete', 'replay', 'skip'].each do |prompt|
        subject.should_receive(:t).with("voicemail.messages.menu.#{prompt}").and_return prompt
      end
      subject.should_receive(:t).with('voicemail.return_to_main_menu').and_return 'main_menu'
      subject.should_receive(:intro_message).and_return 'intro'
    end
    after { subject.play_message }

    context 'with a new message' do
      before { subject.new_or_saved = :new }

      it 'plays the message, followed by the new message menu' do
        subject.should_receive(:t).with('voicemail.messages.menu.archive_new').and_return 'archive_new'
        subject.should_receive(:current_message).and_return message
        subject.should_receive(:menu).once.with any, message[:uri], ['archive_new', 'delete', 'replay', 'skip', 'main_menu'],
          { timeout: config.menu_timeout, tries: config.menu_tries }, Proc
      end
    end

    context 'with a saved message' do
      before { subject.new_or_saved = :saved }

      it 'plays the message, followed by the saved message menu' do
        subject.should_receive(:t).with('voicemail.messages.menu.archive_saved').and_return 'archive_saved'
        subject.should_receive(:current_message).and_return message
        subject.should_receive(:menu).once.with any, message[:uri], ['archive_saved', 'delete', 'replay', 'skip', 'main_menu'],
          { timeout: config.menu_timeout, tries: config.menu_tries }, Proc
      end
    end
  end

  describe '#load_message' do

    context 'with a message' do
      let(:metadata) { { message: 'foo' } }

      it 'loads the messge' do
        subject.load_message
        subject.current_message.should == 'foo'
      end
    end

    context 'with no message passed' do
      let(:metadata) { { message: nil } }

      it 'raises an error' do
        expect { subject.load_message }.to raise_error ArgumentError
      end
    end
  end
end
