require 'spec_helper'

describe Voicemail::MailboxSetPinController do
  include VoicemailControllerSpecHelper

  describe "#section_menu" do
    it "calls #menu with the proper parameters" do
      subject.should_receive(:t).with('voicemail.set_pin.menu.change_pin').and_return 'Press one to change PIN'
      subject.should_receive(:t).with('voicemail.return_to_main_menu').and_return 'or nine to return'
      subject.should_receive(:menu).once.with('Press one to change PIN', 'or nine to return',
          { timeout: config.menu_timeout,
            tries: config.menu_tries }, Proc)
      controller.section_menu
    end
  end

  describe "#set_pin" do
    let(:pin)               { "4321" }
    let(:not_matching_pin)  { "1234" }
    let(:short_pin)         { "9" }

    before :each do
      subject.should_receive(:t).with('voicemail.set_pin.enter_new_pin').and_return 'Enter new PIN'
      subject.should_receive(:t).with('voicemail.set_pin.repeat_pin').and_return 'Repeat PIN'
      subject.should_receive(:t).with('voicemail.set_pin.pin_successfully_changed').and_return 'PIN changed'
    end

    it "makes the user enter a PIN and repeat it" do 
      should_ask('Enter new PIN', terminator: "#", timeout: 5).and_return(pin).ordered
      should_ask('Repeat PIN', terminator: "#", timeout: 5).and_return(pin).ordered
      should_play('PIN changed').ordered
      storage_instance.should_receive(:change_pin_for_mailbox).with(mailbox[:id], pin).once.ordered
      subject.should_receive(:main_menu).once
      controller.set_pin
    end

    it "makes the user start over if the PIN is too short" do
      subject.should_receive(:t).with('voicemail.set_pin.pin_error').and_return 'PIN error'
      should_ask('Enter new PIN', terminator: "#", timeout: 5).and_return(short_pin).ordered
      should_ask('Repeat PIN', terminator: "#", timeout: 5).and_return(short_pin).ordered
      should_play('PIN error').ordered
      should_ask('Enter new PIN', terminator: "#", timeout: 5).and_return(pin).ordered
      should_ask('Repeat PIN', terminator: "#", timeout: 5).and_return(pin).ordered
      should_play('PIN changed').ordered
      storage_instance.should_receive(:change_pin_for_mailbox).with(mailbox[:id], pin).once.ordered
      subject.should_receive(:main_menu).once
      controller.set_pin
    end

    it "makes the user start over if the PIN does not match confirmation" do
      subject.should_receive(:t).with('voicemail.set_pin.match_error').and_return 'match error'
      should_ask('Enter new PIN', terminator: "#", timeout: 5).and_return(pin).ordered
      should_ask('Repeat PIN', terminator: "#", timeout: 5).and_return(not_matching_pin).ordered
      should_play('match error').ordered
      should_ask('Enter new PIN', terminator: "#", timeout: 5).and_return(pin).ordered
      should_ask('Repeat PIN', terminator: "#", timeout: 5).and_return(pin).ordered
      should_play('PIN changed').ordered
      storage_instance.should_receive(:change_pin_for_mailbox).with(mailbox[:id], pin).once.ordered
      subject.should_receive(:main_menu).once
      controller.set_pin
    end
  end
end
