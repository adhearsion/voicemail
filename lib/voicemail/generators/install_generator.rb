module Voicemail
  class InstallGenerator < Adhearsion::Generators::Generator

    def self.source_root()
      File.expand_path("install/", File.dirname(__FILE__))
    end

    def install_model
      raise Exception, "Generator commands need to be run in an Adhearsion app directory" unless Adhearsion::ScriptAhnLoader.in_ahn_application?('.')
      self.destination_root = '.'
      template 'lib/models/mailbox.rb', "lib/models/mailbox.rb"
      template 'lib/models/message.rb', "lib/models/message.rb"
    end

  end
end
