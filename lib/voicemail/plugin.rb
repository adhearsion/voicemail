module Voicemail
  class Plugin < Adhearsion::Plugin

    init :voicemail do
      logger.info "Voicemail has been loaded"
    end

    config :voicemail do
      default_greeting "You have reached voicemail", desc: "What to use to greet users"
      mailbox_not_found "Mailbox not found", desc: "Message to use for a missing mailbox"
      prompt_timeout 5, desc: "Timeout for the various prompts, in seconds"
      menu_timeout 15.seconds, desc: "Timeout for all menus"
      menu_tries 3, desc: "Tries to get matching input for all menus"
      datetime_format "Q 'digits/at' IMp", desc: "Fromat to use for message date and time TTS"

      desc "Voicemail recording options"
      recording {
        final_timeout 2, desc: "Maximum duration to run after recording in seconds"
        max_duration 30, desc: "Maximum duration for recording in seconds"
        start_beep true, desc: "Play a beep before recording"
        stop_beep false, desc: "Play a beep after recording"
      }

      desc "Configuration for registered users"
      mailbox {
        greeting_message "Welcome to the mailbox system.", desc: "Message to greet voicemail users"
        please_enter_pin "Please enter your PIN.", desc: "Message asking to enter PIN."
        pin_tries 3, desc: "Number of tries to authenticate before failure"
        pin_wrong "The PIN you entered does not match. Please try again.", desc: "Message for an user that enters the wrong PIN"
        could_not_auth "We are sorry, the system could not authenticate you", desc: "Message for authentication final failure."
        number_before "You have ", desc: "What to play before the number of new messages"
        number_after " new messages", desc: "What to play after the number of new messages"
        menu_greeting "Press 1 to listen to new messages, 2 to change your greeting, 3 to change your PIN", desc: "What to say before the main menu"
        menu_timeout_message "Please enter a digit for the menu", desc: "Message to play on main menu timeout"
        menu_invalid_message "Please enter valid input", desc: "Message to play on main menu invalid"
        menu_failure_message "Sorry, unable to understand your input.", desc: "Message to play on main menu failure"
      }

      desc "Set greeting configuration"
      set_greeting {
        prompt "Press 1 to listen to your current greeting, 2 to record a new greeting, 9 to return to the main menu", desc: "Main prompt for setting greeting"
        before_record "Please speak after the beep. The prompt will be played back after.", desc: "Recording instructions"
        after_record "Press 1 to save your new greeting, 2 to discard it, 9 to go back to the menu", desc: "Menu to use after recording"
        no_personal_greeting "You do not currently have a personalized greeting.", desc: "What to play if there is no specific greeting"
        recording {
          max_duration 5_000, desc: "Maximum duration for recording in milliseconds"
          start_beep true, desc: "Play a beep before recording"
        }
      }

      desc "Set PIN configuration"
      set_pin {
        menu "Press 1 to change your current PIN, or 9 to go back to the main menu", desc: "Prompt for the change PIN menu"
        prompt "Enter your new PIN of at least four digits followed by the pound sign", desc: "What the user hears before entering the new PIN"
        repeat_prompt "Please enter your new PIN again, followed by the pound sign", desc: "Message to ask the user to repeat his PIN"
        pin_error "Please enter at least four digits followed by the pound sign.", desc: "Message in case the entered PIN is too short"
        match_error "The two entered PINs don't match, please try again.", desc: "Message telling the user his new PINs don't match."
        change_ok "Your PIN has been successfully changed", desc: "Message to tell the user his PIN has been changed"
        pin_minimum_digits 4, desc: "Minimum number of digits for a PIN"
      }

      desc "Listen to messages menu configuration"
      messages {
        menu "Press 1 to archive the message and go to the next, press 5 to delete the message and go to the next, press 7 to hear the message again, press 9 for the main menu", desc: "Menu to use inside messages"
        no_new_messages "There are no new messages", desc: "Message to inform the user he has no new messages"
        message_received_on "Message received on ", desc: "Prefix to menu intro"
        from " from ", desc: "Used in message intro"
      }

      desc "Storage configuration"
      storage {
        storage_class Voicemail::StoragePstore, desc: "Class that implements the Storage specification. An instance will be created."
        pstore_location "voicemail.pstore", desc: "Where to store the voicemail data"
        file_location "file_dir", desc: "Where to store the voicemail files"
      }
    end

    tasks do
      namespace :voicemail do
        desc "Prints the Voicemail information"
        task :info do
          STDOUT.puts "Voicemail plugin v. #{VERSION}"
        end
      end
    end

  end
end
