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
          subject.should_receive(:t).with('voicemail.mailbox_not_found').and_return 'not_found'
          should_play 'not_found'
          subject.should_receive(:hangup).once
          controller.run
        end
      end

      context "with an existing mailbox" do
        it "plays the mailbox greeting message" do
          subject.should_receive(:t).with('voicemail.mailbox.greeting_message').and_return 'greeting'
          should_play 'greeting'
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
      subject.should_receive(:t).with('voicemail.mailbox.enter_pin').and_return 'enter_pin'
      should_ask('enter_pin', terminator: '#', timeout: config.prompt_timeout).once.and_return(1234)
      controller.authenticate
      controller.auth_ok.should == true
    end

    it "tell a user his pin is wrong and retries" do
      subject.should_receive(:t).with('voicemail.mailbox.enter_pin').and_return 'enter_pin'
      subject.should_receive(:t).with('voicemail.mailbox.invalid_pin').and_return 'invalid_pin'
      subject.should_receive(:ask).times(2).and_return(1111, 1234)
      should_play 'invalid_pin'
      controller.authenticate
      controller.auth_ok.should == true
    end

    it "fails with a message if the user enters a wrong PIN the set number of times" do
      subject.should_receive(:t).with('voicemail.mailbox.enter_pin').and_return 'enter_pin'
      subject.should_receive(:t).with('voicemail.mailbox.invalid_pin').and_return 'invalid_pin'
      subject.should_receive(:ask).times(3).and_return(1111, 2222, 3333)
      subject.should_receive(:play).with('invalid_pin').times(3)
      controller.authenticate
      controller.auth_ok.should == false
    end
  end
end
