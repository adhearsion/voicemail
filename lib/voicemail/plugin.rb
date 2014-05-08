module Voicemail
  class Plugin < Adhearsion::Plugin

    init :voicemail, after: :i18n do
      ::I18n.load_path.insert(1, File.expand_path('../../../templates/en.yml', __FILE__))
      logger.info 'Voicemail has been loaded'
    end

    config :voicemail do
      prompt_timeout 5, desc: "Timeout for the various prompts, in seconds"
      menu_timeout 15.seconds, desc: "Timeout for all menus"
      menu_tries 3, desc: "Tries to get matching input for all menus"
      datetime_format "Q 'digits/at' IMp", desc: "Format to use for message date and time formatting"

      when_to_answer :before_greeting, desc: "#answer :before_greeting or :after_greeting"
      numeric_method :play_numeric, desc: "Whether to use #play_numeric type methods, AhnSay, or a single I18n string"

      matcher_class   Voicemail::Matcher, desc: "Class that checks for a match in pin authentication"
      main_menu_class Voicemail::MailboxMainMenuController, desc: "Class runs the main menu prompts"

      allow_rerecording true, desc: "Allow caller to rerecord their voicemail"

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
        pin_tries 3, desc: "Number of tries to authenticate before failure - set to 0 for infinite"
      }

      desc "Set PIN configuration"
      set_pin {
        pin_minimum_digits 4, desc: "Minimum number of digits for a PIN"
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
