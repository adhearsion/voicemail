module Voicemail
  class ApplicationController < ::Adhearsion::CallController
    def main_menu
      pass config.main_menu_class, mailbox: mailbox[:id], storage: storage
    end

    private

    def storage
      metadata[:storage] || Storage.instance
    end

    def config
      Voicemail::Plugin.config
    end

    def mailbox
      @mailbox ||= fetch_mailbox
    end

    def fetch_mailbox
      mailbox_id = metadata[:mailbox] || nil
      raise ArgumentError, "Voicemail needs a mailbox specified in metadata" unless mailbox_id
      storage.get_mailbox mailbox_id
    end

    def record_options
      if config.use_mailbox_opts_for_recording
        config.recording.to_hash.merge mailbox[:record_options]
      else
        config.recording.to_hash
      end
    end

    def mailbox_not_found
      play config.mailbox_not_found
      hangup
    end
  end
end
