module Voicemail
  class Plugin < Adhearsion::Plugin
    # Actions to perform when the plugin is loaded
    #
    init :voicemail do
      logger.warn "Voicemail has been loaded"
    end

    # Basic configuration for the plugin
    #
    config :voicemail do
      greeting "Hello", :desc => "What to use to greet users"
    end

    # Defining a Rake task is easy
    # The following can be invoked with:
    #   rake plugin_demo:info
    #
    tasks do
      namespace :voicemail do
        desc "Prints the PluginTemplate information"
        task :info do
          STDOUT.puts "Voicemail plugin v. #{VERSION}"
        end
      end
    end

  end
end
