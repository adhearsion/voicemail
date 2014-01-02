require 'spec_helper'

describe Voicemail::AuthenticationController do
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
          should_play config.mailbox.greeting_message
          subject.should_receive(:authenticate)
          subject.should_receive(:auth_ok).and_return true
          subject.should_receive(:pass).with Voicemail::MailboxController, mailbox: 100
          controller.run
        end
      end
    end
  end

  describe "#authenticate" do
    it "authenticates an user that enters the correct pin" do
      should_ask(config.mailbox.please_enter_pin, terminator: "#", timeout: config.prompt_timeout).once.and_return(1234)
      controller.authenticate
      controller.auth_ok.should == true
    end

    it "tell a user his pin is wrong and retries" do
      subject.should_receive(:ask).times(2).and_return(1111, 1234)
      should_play config.mailbox.pin_wrong
      controller.authenticate
      controller.auth_ok.should == true
    end

    it "fails with a message if the user enters a wrong PIN the set number of times" do
      subject.should_receive(:ask).times(3).and_return(1111, 2222, 3333)
      subject.should_receive(:play).with(config.mailbox.pin_wrong).times(3)
      controller.authenticate
      controller.auth_ok.should == false
    end
  end
end
