module Voicemail
  class ApplicationController < ::Adhearsion::CallController
    def main_menu
      pass MailboxMainMenuController, mailbox: mailbox[:id]
    end

    private

    def storage
      Storage.instance
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
      
  end
end
