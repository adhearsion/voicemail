require 'spec_helper'

module Voicemail
  describe MailboxMessagesController do
    include VoicemailControllerSpecHelper

    let(:config)   { Voicemail::Plugin.config }
    let(:message) do
      {
        id: 123,
        from: '+39-335135335',
        received: Time.local(2012, 5, 1, 9, 0, 0),
        uri: 'file:///path/to/file.mp3'
      }
    end

    let(:messages) { [] }

    let(:metadata) { { mailbox: 100, new_or_saved: message_type, storage: storage_instance } }

    before(:each) do
      storage_instance.should_receive(:get_messages).and_return messages
    end


    context 'with new messages' do
      let(:message_type) { :new }

      describe '#message_loop' do
        after { controller.run }

        context 'messages present' do
          let(:messages) { [message, message, message] }
          it 'calls #next_message' do
            subject.should_receive(:next_message).once
          end
        end

        context 'messages absent' do
          it 'plays a message and goes to the main menu' do
            subject.should_receive(:t).with('voicemail.messages.there_are_no').and_return 'there_are_no'
            subject.should_receive(:t).with('voicemail.new_messages').and_return 'new_messages'
            subject.should_receive(:play).with(['there_are_no', 'new_messages']).once
            subject.should_receive(:main_menu).once
          end
        end
      end

      describe '#next_message' do
        let(:messages) { [message] }
        it 'gets the next message and calls #handle_message' do
          subject.should_receive(:handle_message).once.with(message)
          subject.should_receive(:message_loop).once
          controller.next_message
        end
      end

      describe '#handle_message' do
        it 'invokes MailboxPlayMessageController' do
          should_invoke Voicemail::MailboxPlayMessageController, message: message, mailbox: mailbox[:id], new_or_saved: :new, storage: storage_instance
          controller.handle_message message
        end
      end
    end

    context 'with saved messages' do
      let(:message_type) { :saved }

      describe '#message_loop' do
        after { controller.run }

        context 'messages present' do
          let(:messages) { [message, message, message] }
          it 'calls #next_message' do
            subject.should_receive(:next_message).once
          end
        end

        context 'messages absent' do
          it 'plays a message and goes to the main menu if there are no saved messages' do
            subject.should_receive(:t).with('voicemail.messages.there_are_no').and_return 'there_are_no'
            subject.should_receive(:t).with('voicemail.saved_messages').and_return 'saved_messages'
            subject.should_receive(:play).with(['there_are_no', 'saved_messages']).once
            subject.should_receive(:main_menu).once
          end
        end
      end

      describe '#next_message' do
        let(:messages) { [message] }
        it 'gets the next message and calls #handle_message' do
          subject.should_receive(:handle_message).once.with(message)
          subject.should_receive(:message_loop).once
          controller.next_message
        end
      end

      describe '#handle_message' do
        it 'invokes MailboxPlayMessageController' do
          should_invoke Voicemail::MailboxPlayMessageController, message: message, mailbox: mailbox[:id], new_or_saved: :saved, storage: storage_instance
          controller.handle_message message
        end
      end
    end
  end
end
