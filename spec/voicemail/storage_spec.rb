require 'spec_helper'

module Voicemail
  describe Storage do
    describe "#instance" do
      it "returns a StorageMain object" do
        Storage.instance.should be_a StorageMain
      end

      it "returns the same instance every time" do
        instance_a = Storage.instance
        instance_b = Storage.instance
        instance_a.object_id.should == instance_b.object_id
      end
    end
  end
end
