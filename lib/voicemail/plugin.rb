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
      default_greeting "You have reached voicemail", :desc => "What to use to greet users"
      mailbox_not_found "Mailbox not found", :desc => "Message to use for a missing mailbox"
      desc "Voicemail recording options"
      recording {
        max_duration 5_000, :desc => "Maximum duration for recording in milliseconds"
        start_beep true, :desc => "Play a beep before recording"
      }
    end

    # Defining a Rake task is easy
    # The following can be invoked with:
    #   rake plugin_demo:info
    #
    tasks do
      namespace :voicemail do
        desc "Prints the Voicemail information"
        task :info do
          STDOUT.puts "Voicemail plugin v. #{VERSION}"
        end
      end
    end

    generators :"voicemail:install" => Voicemail::InstallGenerator

  end
end
