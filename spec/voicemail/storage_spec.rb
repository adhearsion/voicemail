require 'spec_helper'

describe Voicemail::Storage do
  describe "#instance" do
    it "returns a StorageMain object" do
      Voicemail::Storage.instance.should be_a Voicemail::StoragePstore
    end

    it "returns the same instance every time" do
      Voicemail::Storage.instance.should be Voicemail::Storage.instance
    end
  end
end
