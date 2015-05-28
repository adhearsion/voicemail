require "spec_helper"

describe Voicemail::LocalizationLoader do

  before { @old_config = Voicemail::Plugin.config.default_greeting }
  after  { Voicemail::Plugin.config.default_greeting = @old_config }

  describe ".replace_config" do
    let(:mock_hash) { {'en' => {'voicemail' => {'default_greeting' => 'foo'}}} }

    context "with the standard I18n provider" do
      before do
        flexmock(YAML).should_receive(:load).and_return mock_hash
        flexmock(I18n).should_receive(:t).and_return "bar"
      end

      it "changes the values to i18n" do
        subject.replace_config
        Voicemail::Plugin.config.default_greeting.should == "bar"
      end
    end

    context "with a custom I18n provider" do
      let(:custom_i18n_provider) { flexmock('custom_i18n_provider') }
      let(:mock_hash) { {'en' => {'voicemail' => {'i18n_provider' => custom_i18n_provider, 'default_greeting' => 'foo'}}} }

      before do
        flexmock(YAML).should_receive(:load).and_return mock_hash
        flexmock(custom_i18n_provider).should_receive(:t).and_return "custom value"
      end

      it "uses values from the custom I18n provider" do
        subject.replace_config
        Voicemail::Plugin.config.default_greeting.should == "custom value"
      end
    end
  end
end
