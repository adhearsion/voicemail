module Voicemail
  class Storage
    def self.instance
      @instance ||= Voicemail::Plugin.config.storage.storage_class.new
    end
  end
end
