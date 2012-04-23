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
      prompt_timeout 5, :desc => "Timeout for the various prompts, in seconds"
      desc "Voicemail recording options"
      recording {
        max_duration 5_000, :desc => "Maximum duration for recording in milliseconds"
        start_beep true, :desc => "Play a beep before recording"
      }
      desc "Configuration for registered users"
      mailbox {
        greeting_message "Welcome to the mailbox system.", :desc => "Message to greet voicemail users"
        please_enter_pin "Please enter your PIN.", :desc => "Message asking to enter PIN."
        pin_tries 3, :desc => "Number of tries to authenticate before failure"
        pin_wrong "The PIN you entered does not match. Please try again.", :desc => "Message for an user that enters the wrong PIN"
        could_not_auth "We are sorry, the system could not authenticate you", :desc => "Message for authentication final failure."
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
