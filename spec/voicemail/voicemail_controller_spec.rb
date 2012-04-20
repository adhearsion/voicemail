require 'spec_helper'

module Voicemail
  describe VoicemailController do

    let(:storage) { flexmock('Storage') }
    let(:call) { flexmock('Call') }
    let(:config) { Voicemail::Plugin.config }
    let(:metadata) do 
      { :mailbox => '100' }
    end

    let(:controller){ Voicemail::VoicemailController.new call, metadata }
    subject { flexmock controller }

    context "with a missing mailbox parameter in metadata" do
      let(:metadata) { Hash.new }
      it "should raise an error if there is no mailbox in the metadata" do
        expect { controller.run }.to raise_error ArgumentError
      end
    end

    context "with a present mailbox parameter in metadata" do
      let(:mailbox) do
        {
          :id => 100,
          :pin => 1234,
          :greeting_message => greeting_message
        }
      end
      
      context "without a greeting message" do
        let(:greeting_message) { nil }
        it "plays the default greeting if one is not specified" do
          storage.should_receive(:get_mailbox).with(metadata[:mailbox]).and_return(mailbox)
          subject.should_receive(:storage).and_return(storage)
          subject.should_receive(:play).once
          controller.run 
        end
      end
    end

  end
end
