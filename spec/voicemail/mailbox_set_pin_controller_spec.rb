require 'spec_helper'

module Voicemail
  describe MailboxSetPinController do
    
    let(:call) { flexmock('Call') }
    let(:config) { Voicemail::Plugin.config }
    let(:metadata) do 
      { :mailbox => '100' }
    end
    let(:mailbox) do
      {
        :id => 100,
        :pin => 1234,
        :greeting_message => nil,
        :send_email => true,
        :email_address => "lpradovera@mojolingo.com"
      }
    end
    let(:storage_instance) { flexmock('StorageInstance') }

    let(:controller){ Voicemail::MailboxSetPinController.new call, metadata }
    subject { flexmock controller }
    
    before(:each) do
      storage_instance.should_receive(:get_mailbox).with(metadata[:mailbox]).and_return(mailbox)
      flexmock(Storage).should_receive(:instance).and_return(storage_instance)
    end


    describe "#section_menu" do
      it "calls #menu with the proper parameters" do
        subject.should_receive(:menu).once.with(config.set_pin.menu,
            {:timeout => config.menu_timeout,
              :tries => config.menu_tries}, Proc)
        controller.section_menu
      end
    end

    describe "#set_pin" do
      let(:pin) { "4321" }
      let(:not_matching_pin) { "1234" }
      let(:short_pin) { "9" }
      it "makes the user enter a PIN and repeat it" do
        subject.should_receive(:ask).with(config.set_pin.prompt, {:terminator => "#"}).and_return(pin).once.ordered
        subject.should_receive(:ask).with(config.set_pin.repeat_prompt, {:terminator => "#"}).and_return(pin).once.ordered
        subject.should_receive(:play).with(config.set_pin.change_ok).once.ordered
        storage_instance.should_receive(:change_pin_for_mailbox).with(mailbox[:id], pin).once.ordered
        subject.should_receive(:main_menu).once
        controller.set_pin
      end

      it "makes the user start over if the PIN is too short" do
        subject.should_receive(:ask).with(config.set_pin.prompt, {:terminator => "#"}).and_return(short_pin).once.ordered
        subject.should_receive(:ask).with(config.set_pin.repeat_prompt, {:terminator => "#"}).and_return(short_pin).once.ordered
        subject.should_receive(:play).with(config.set_pin.pin_error).once.ordered
        subject.should_receive(:ask).with(config.set_pin.prompt, {:terminator => "#"}).and_return(pin).once.ordered
        subject.should_receive(:ask).with(config.set_pin.repeat_prompt, {:terminator => "#"}).and_return(pin).once.ordered
        subject.should_receive(:play).with(config.set_pin.change_ok).once.ordered
        storage_instance.should_receive(:change_pin_for_mailbox).with(mailbox[:id], pin).once.ordered
        subject.should_receive(:main_menu).once
        controller.set_pin
      end

      it "makes the user start over if the PIN does not match confirmation" do
        subject.should_receive(:ask).with(config.set_pin.prompt, {:terminator => "#"}).and_return(pin).once.ordered
        subject.should_receive(:ask).with(config.set_pin.repeat_prompt, {:terminator => "#"}).and_return(not_matching_pin).once.ordered
        subject.should_receive(:play).with(config.set_pin.match_error).once.ordered
        subject.should_receive(:ask).with(config.set_pin.prompt, {:terminator => "#"}).and_return(pin).once.ordered
        subject.should_receive(:ask).with(config.set_pin.repeat_prompt, {:terminator => "#"}).and_return(pin).once.ordered
        subject.should_receive(:play).with(config.set_pin.change_ok).once.ordered
        storage_instance.should_receive(:change_pin_for_mailbox).with(mailbox[:id], pin).once.ordered
        subject.should_receive(:main_menu).once
        controller.set_pin
      end
    end

  end
end
