require 'spec_helper'

describe Voicemail::MailboxController do
  include VoicemailControllerSpecHelper

  describe "#run" do
    context "with a missing mailbox parameter in metadata" do
      let(:metadata) { Hash.new }

      it "should raise an error if there is no mailbox in the metadata" do
        expect { controller.run }.to raise_error ArgumentError
      end
    end

    context "with a present mailbox parameter in metadata" do
      context "with an invalid mailbox" do
        let(:mailbox) { nil }

        it "plays the mailbox not found message and hangs up" do
          subject.should_receive(:t).with('voicemail.mailbox_not_found').and_return 'not_found'
          should_play 'not_found'
          subject.should_receive(:hangup).once
          controller.run
        end
      end

      context "with an existing mailbox" do
        it "plays the mailbox greeting message" do
          subject.should_receive(:play_number_of_messages).and_return(true)
          subject.should_receive(:main_menu).and_return(true)
          controller.run
        end
      end
    end
  end

  describe "#play_number_of_messages" do
    before { config.numeric_method = :play_numeric }
    after do
      controller.play_number_of_messages type
    end

    context ":new" do
      let(:type) { :new }

      context "with at least one new message" do
        before { storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return 3 }

        it "plays the number of new messages" do
          subject.should_receive(:t).with('voicemail.mailbox.you_have').and_return 'you_have'
          subject.should_receive(:t).with('voicemail.new_messages').and_return 'new_messages'
          should_play('you_have').ordered
          subject.should_receive(:play_numeric).ordered.with(3)
          should_play('new_messages').ordered
        end

        context "when it's set to use ahnsay" do
          before { config.numeric_method = :ahn_say }

          it "plays the number of messages using ahn say" do
            subject.should_receive(:t).with('voicemail.mailbox.you_have').and_return 'you_have'
            subject.should_receive(:t).with('voicemail.new_messages').and_return 'new_messages'
            should_play('you_have').ordered
            subject.should_receive(:sounds_for_number).with(3).and_return "3.ul"
            subject.should_receive(:play).ordered.with "3.ul"
            should_play('new_messages').ordered
          end
        end

        context "when it's set to use I18n" do
          before { config.numeric_method = :i18n_string }

          it "plays the number of messages using i18n's pluralization" do
            subject.should_receive(:t).with('voicemail.mailbox.x_new_messages', count: 3).and_return 'You have 3 new messages'
            should_play "You have 3 new messages"
          end
        end
      end

      context "with no new message" do
        before { storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return 0 }

        it "plays the no new messages audio" do
          subject.should_receive(:t).with('voicemail.messages.there_are_no').and_return 'there_are_no'
          subject.should_receive(:t).with('voicemail.new_messages').and_return 'new_messages'
          should_play(['there_are_no', 'new_messages']).ordered
        end
      end
    end

    context ":saved" do
      let(:type) { :saved }

      it "plays the number of saved messages if there is at least one" do
        subject.should_receive(:t).with('voicemail.mailbox.you_have').and_return 'you_have'
        subject.should_receive(:t).with('voicemail.saved_messages').and_return 'saved_messages'
        storage_instance.should_receive(:count_saved_messages).once.with(mailbox[:id]).and_return(3)
        should_play('you_have').ordered
        subject.should_receive(:play_numeric).ordered.with(3)
        should_play('saved_messages').ordered
      end

      it "does play the no saved messages audio if there are none" do
        subject.should_receive(:t).with('voicemail.messages.there_are_no').and_return 'there_are_no'
        subject.should_receive(:t).with('voicemail.saved_messages').and_return 'saved_messages'
        storage_instance.should_receive(:count_saved_messages).once.with(mailbox[:id]).and_return(0)
        should_play(['there_are_no', 'saved_messages']).ordered
      end
    end
  end

  describe "#main_menu" do
    it "passes to MainMenuController" do
      subject.should_receive(:pass).once.with Voicemail::MailboxMainMenuController, mailbox: mailbox[:id], storage: storage_instance
      controller.main_menu
    end
  end
end
