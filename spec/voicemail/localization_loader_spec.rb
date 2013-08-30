require "spec_helper"

describe Voicemail::LocalizationLoader do

  before { @old_config = Voicemail::Plugin.config.default_greeting }
  after  { Voicemail::Plugin.config.default_greeting = @old_config }

  describe ".replace_config" do
    let(:mock_hash) { {'en' => {'voicemail' => {'default_greeting' => 'foo'}}} }

    before do
      flexmock(YAML).should_receive(:load).and_return mock_hash
      flexmock(I18n).should_receive(:t).and_return "bar"
    end

    it "changes the values to i18n" do
      subject.replace_config
      Voicemail::Plugin.config.default_greeting.should == "bar"
    end
  end
end
