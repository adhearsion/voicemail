module Voicemail
  class InstallGenerator < Adhearsion::Generators::Generator


    def install_model
      raise Exception, "Generator commands need to be run in an Adhearsion app directory" unless Adhearsion::ScriptAhnLoader.in_ahn_application?('.')
      self.destination_root = '.'
      template 'lib/controller.rb', "lib/#{@controller_name.underscore}.rb"
      template 'spec/controller_spec.rb', "spec/#{@controller_name.underscore}_spec.rb"
    end

  end
end
