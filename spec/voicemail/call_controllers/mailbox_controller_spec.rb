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
          should_play config.mailbox_not_found
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
          should_play(config.mailbox.number_before).ordered
          subject.should_receive(:play_numeric).ordered.with(3)
          should_play(config.mailbox.number_after_new).ordered
        end

        context "when it's set to use ahnsay" do
          before { config.numeric_method = :ahn_say }

          it "plays the number of messages using ahn say" do
            should_play(config.mailbox.number_before).ordered
            subject.should_receive(:sounds_for_number).with(3).and_return "3.ul"
            subject.should_receive(:play).ordered.with "3.ul"
            should_play(config.mailbox.number_after_new).ordered
          end
        end

        context "when it's set to use I18n" do
          before { config.numeric_method = :i18n_string }

          it "plays the number of messages" do
            flexmock(I18n).should_receive(:t).with("voicemail.mailbox.message_count_prefix").and_return "You have "
            flexmock(I18n).should_receive(:t).with("voicemail.mailbox.new_messages").and_return "new messages. "
            should_play ["You have ", 3, "new messages. "]
          end
        end
      end

      context "with exactly one new message" do
        before { storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return 1 }

        context "when it's set to use I18n" do
          before { config.numeric_method = :i18n_string }

          it "plays a message saying there is one message" do
            flexmock(I18n).should_receive(:t).with("voicemail.mailbox.message_count_prefix").and_return "You have "
            flexmock(I18n).should_receive(:t).with("voicemail.mailbox.new_message").and_return "new message. "
            should_play ["You have ", 1, "new message. "]
          end
        end
      end

      context "with no new message" do
        before { storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return 0 }

        it "plays the no new messages audio" do
          should_play(config.messages.no_new_messages).ordered
        end
      end
    end

    context ":saved" do
      let(:type) { :saved }

      it "plays the number of saved messages if there is at least one" do
        storage_instance.should_receive(:count_saved_messages).once.with(mailbox[:id]).and_return(3)
        should_play(config.mailbox.number_before).ordered
        subject.should_receive(:play_numeric).ordered.with(3)
        should_play(config.mailbox.number_after_saved).ordered
      end

      it "does play the no saved messages audio if there are none" do
        storage_instance.should_receive(:count_saved_messages).once.with(mailbox[:id]).and_return(0)
        should_play(config.messages.no_saved_messages).ordered
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
