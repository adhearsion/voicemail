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

    after { controller.play_number_of_messages type }

    context ":new" do
      let(:type) { :new }

      it "plays the number of new messages if there is at least one" do
        storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return(3)
        should_play(config.mailbox.number_before).ordered
        subject.should_receive(:play_numeric).ordered.with(3)
        should_play(config.mailbox.number_after_new).ordered
      end

      it "does play the no new messages audio if there are none" do
        storage_instance.should_receive(:count_new_messages).once.with(mailbox[:id]).and_return(0)
        should_play(config.messages.no_new_messages).ordered
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
