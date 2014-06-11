module Voicemail
  class Plugin < Adhearsion::Plugin

    init :voicemail do
      if config.use_i18n
        LocalizationLoader.replace_config
        logger.info "Voicemail has been loaded with i18n support"
      else
        logger.info "Voicemail has been loaded"
      end
    end

    config :voicemail do
      use_i18n false, desc: "Whether to use i18n for voice prompts"
      prompt_timeout 5, desc: "Timeout for the various prompts, in seconds"
      menu_timeout 15, desc: "Timeout for all menus"
      menu_tries 3, desc: "Tries to get matching input for all menus"
      datetime_format "Q 'digits/at' IMp", desc: "Format to use for message date and time formatting"

      when_to_answer :before_greeting, desc: "#answer :before_greeting or :after_greeting"
      numeric_method :play_numeric, desc: "Whether to use #play_numeric type methods, AhnSay, or a single I18n string"

      matcher_class   Voicemail::Matcher, desc: "Class that checks for a match in pin authentication"
      main_menu_class Voicemail::MailboxMainMenuController, desc: "Class runs the main menu prompts"

      default_greeting "You have reached voicemail", desc: "What to use to greet users"
      mailbox_not_found "Mailbox not found", desc: "Message to use for a missing mailbox"

      allow_rerecording true, desc: "Allow caller to rerecord their voicemail"
      after_record "Press 1 to save your voicemail.  Press 2 to rerecord.", desc: "Message to play if allow_rerecording is set"
      recording_confirmation "Your message has been saved. Thank you.", desc: "Message to play after the voicemail has been saved"

      desc "Default recording options"
      recording {
        interruptible true, desc: "Whether you can stop the recording with a DTMF input"
        direction :send, desc: "The direction to record; you probably want :send"
        final_timeout 2, desc: "Maximum duration to run after recording in seconds"
        max_duration 30, desc: "Maximum duration for recording in seconds"
        start_beep true, desc: "Play a beep before recording"
        stop_beep false, desc: "Play a beep after recording"
      }
      use_mailbox_opts_for_recording false, desc: "Whether per-mailbox settings can override defaults"

      desc "Configuration for registered users"
      mailbox {
        greeting_message "Welcome to the mailbox system.", desc: "Message to greet voicemail users"
        please_enter_pin "Please enter your PIN.", desc: "Message asking to enter PIN."
        pin_tries 3, desc: "Number of tries to authenticate before failure - set to 0 for infinite"
        pin_wrong "The PIN you entered does not match. Please try again.", desc: "Message for an user that enters the wrong PIN"
        could_not_auth "We are sorry, the system could not authenticate you", desc: "Message for authentication final failure."
        number_before "You have ", desc: "What to play before the number of new messages"
        number_after_new " new messages", desc: "What to play after the number of new messages"
        number_after_saved " saved messages", desc: "What to play after the number of saved messages"
        menu_greeting "Press 1 to listen to new messages, 2 to listen to saved messages, 3 to change your greeting, 4 to change your PIN, 7 to delete all new messages, 9 to delete all saved messages", desc: "What to say before the main menu"
        menu_timeout_message "Please enter a digit for the menu", desc: "Message to play on main menu timeout"
        menu_invalid_message "Please enter valid input", desc: "Message to play on main menu invalid"
        menu_failure_message "Sorry, unable to understand your input.", desc: "Message to play on main menu failure"
        clear_new_messages "Are you sure you want to permanently erase all new messages? Press 1 to delete, or any other key to cancel", desc: "New message clearing confirmation"
        clear_saved_messages "Are you sure you want to permanently erase all saved messages? Press 1 to delete, or any other key to cancel", desc: "Saved message clearing confirmation"
        no_messages_deleted "Your messages will not be deleted. Returning to main menu."
        deleting_all_new_messages "All of your new messages are being deleted. Please wait."
        deleting_all_saved_messages "All of your saved messages are being deleted. Please wait."
        all_new_messages_deleted "All new messages have been successfully deleted."
        all_saved_messages_deleted "All saved messages have been successfully deleted."
      }

      desc "Set greeting configuration"
      set_greeting {
        prompt "Press 1 to listen to your current greeting, 2 to record a new greeting, 3 to delete your personalized greeting, 9 to return to the main menu", desc: "Main prompt for setting greeting"
        before_record "Please speak after the beep. The prompt will be played back after.", desc: "Recording instructions"
        after_record "Press 1 to save your new greeting, 2 to discard it, 9 to go back to the menu", desc: "Menu to use after recording"
        no_personal_greeting "You do not currently have a personalized greeting.", desc: "What to play if there is no specific greeting"
        delete_confirmation "Your personlized greeting will be deleted. Press 1 to confirm, 9 to return to the main menu.", desc: "Ask the user to confirm removal of personalized greeting"
        greeting_deleted "Your personalized greeting was deleted.", desc: "What to play after a greeting has been deleted"
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
        menu_new "Press 1 to archive the message and go to the next, press 5 to delete the message and go to the next, press 7 to hear the message again, press 8 to skip the message, press 9 for the main menu", desc: "Menu to use inside new messages"
        menu_saved "Press 1 to unarchive the message and go to the next, press 5 to delete the message and go to the next, press 7 to hear the message again, press 8 to skip the message, press 9 for the main menu", desc: "Menu to use inside saved messages"
        no_new_messages "There are no new messages", desc: "Message to inform the user he has no new messages"
        no_saved_messages "There are no saved messages", desc: "Message to inform the user he has no saved messages"
        message_received_on "Message received on ", desc: "Prefix to menu intro"
        from " from ", desc: "Used in message intro"
        message_deleted "Message deleted.", desc: "Confirmation that a message has been deleted"
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

        desc "Copy an initial translation file (en) to your adhearsion project (ahn_root/config/locales/en.yml)"
        task :i18n_init do
          current_path  = File.expand_path(File.dirname(__FILE__))
          template_file = "#{current_path}/../../templates/en.yml"
          new_location  = "#{Dir.pwd}/config/locales/"

          FileUtils.mkdir_p(new_location) unless File.directory?(new_location)
          FileUtils.copy template_file, "#{new_location}en.yml"
        end
      end
    end
  end
end
