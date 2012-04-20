module Voicemail
  class VoicemailController < ::Adhearsion::CallController

    def run
      mailbox_id = metadata[:mailbox] || nil
      raise ArgumentError, "Voicemail needs a mailbox specified in metadata" unless mailbox_id
      
      @mailbox = storage.get_mailbox mailbox_id
      if @mailbox
        play_greeting
      else
        mailbox_not_found
      end
    end

    def play_greeting

    end

    def mailbox_not_found

    end

    def storage
    end

  end

end
