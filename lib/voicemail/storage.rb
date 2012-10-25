module Voicemail
  class Storage
    def self.instance
      @instance ||= Adhearsion.config[:voicemail].storage.storage_class.new
    end
  end
end
