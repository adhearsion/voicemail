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
      menu_timeout 15.seconds, :desc => "Timeout for all menus"
      menu_tries 3, :desc => "Tries to get matching input for all menus"
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
        number_before "You have ", :desc => "What to play before the number of new messages"
        number_after " new messages", :desc => "What to play after the number of new messages"
        menu_greeting "Main menu", :desc => "What to say before the main menu"
        menu_timeout_message "Please enter a digit for the menu", :desc => "Message to play on main menu timeout"
        menu_invalid_message "Please enter valid input", :desc => "Message to play on main menu invalid"
        menu_failure_message "Sorry, unable to understand your input.", :desc => "Message to play on main menu failure"
      }
      desc "Set greeting configuration"
      set_greeting {
        prompt "Press 1 to listen to your current greeting, 2 to record a new greeting, 9 to return to the main menu", :desc => "Main prompt for setting greeting"
        before_record "Please speak after the beep. The prompt will be played back after.", :desc => "Recording instructions"
        after_record "Press 1 to save your new greeting, 2 to discard it, 9 to go back to the menu", :desc => "Menu to use after recording"
        no_personal_greeting "You do not currently have a personalized greeting.", :desc => "What to play if there is no specific greeting"
        recording {
          max_duration 15_000, :desc => "Maximum duration for recording in milliseconds"
          start_beep true, :desc => "Play a beep before recording"
          final_timeout 2_000, :desc => "Duration of silence to conclude user has finished speaking."
        }
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
