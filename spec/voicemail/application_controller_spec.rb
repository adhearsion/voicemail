require 'spec_helper'

describe Voicemail::ApplicationController do
  include VoicemailControllerSpecHelper

  describe "#main_menu" do
    context "with the defaults" do
      it "passes to MainMenuController" do
        subject.should_receive(:pass).once.with Voicemail::MailboxMainMenuController, mailbox: mailbox[:id]
        controller.main_menu
      end
    end

    context "with a custom class" do

      class Foo; end

      before do
        @saved_option = config.main_menu_class
        config.main_menu_class = Foo
      end

      after { config.main_menu_class = @saved_option }

      it "passes to custom controller class" do
        subject.should_receive(:pass).once.with Foo, mailbox: mailbox[:id]
        controller.main_menu
      end
    end
  end
end
