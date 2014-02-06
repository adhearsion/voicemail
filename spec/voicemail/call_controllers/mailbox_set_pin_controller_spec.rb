require 'spec_helper'

describe Voicemail::MailboxSetPinController do
  include VoicemailControllerSpecHelper

  describe "#section_menu" do
    it "calls #menu with the proper parameters" do
      subject.should_receive(:menu).once.with(config.set_pin.menu,
          { timeout: config.menu_timeout,
            tries: config.menu_tries }, Proc)
      controller.section_menu
    end
  end

  describe "#set_pin" do
    let(:pin)               { "4321" }
    let(:not_matching_pin)  { "1234" }
    let(:short_pin)         { "9" }

    it "makes the user enter a PIN and repeat it" do
      should_ask(config.set_pin.prompt, terminator: "#", timeout: 5).and_return(pin).ordered
      should_ask(config.set_pin.repeat_prompt, terminator: "#", timeout: 5).and_return(pin).ordered
      should_play(config.set_pin.change_ok).ordered
      storage_instance.should_receive(:change_pin_for_mailbox).with(mailbox[:id], pin).once.ordered
      subject.should_receive(:main_menu).once
      controller.set_pin
    end

    it "makes the user start over if the PIN is too short" do
      should_ask(config.set_pin.prompt, terminator: "#", timeout: 5).and_return(short_pin).ordered
      should_ask(config.set_pin.repeat_prompt, terminator: "#", timeout: 5).and_return(short_pin).ordered
      should_play(config.set_pin.pin_error).ordered
      should_ask(config.set_pin.prompt, terminator: "#", timeout: 5).and_return(pin).ordered
      should_ask(config.set_pin.repeat_prompt, terminator: "#", timeout: 5).and_return(pin).ordered
      should_play(config.set_pin.change_ok).ordered
      storage_instance.should_receive(:change_pin_for_mailbox).with(mailbox[:id], pin).once.ordered
      subject.should_receive(:main_menu).once
      controller.set_pin
    end

    it "makes the user start over if the PIN does not match confirmation" do
      should_ask(config.set_pin.prompt, terminator: "#", timeout: 5).and_return(pin).ordered
      should_ask(config.set_pin.repeat_prompt, terminator: "#", timeout: 5).and_return(not_matching_pin).ordered
      should_play(config.set_pin.match_error).ordered
      should_ask(config.set_pin.prompt, terminator: "#", timeout: 5).and_return(pin).ordered
      should_ask(config.set_pin.repeat_prompt, terminator: "#", timeout: 5).and_return(pin).ordered
      should_play(config.set_pin.change_ok).ordered
      storage_instance.should_receive(:change_pin_for_mailbox).with(mailbox[:id], pin).once.ordered
      subject.should_receive(:main_menu).once
      controller.set_pin
    end
  end
end
