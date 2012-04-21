module Voicemail
  class Storage
    include Singleton
    # mailbox: id, pin, away, away_message, greeting_message 
    def get_mailbox(mailbox)
      {
        :id => 100,
        :pin => 1234,
        :greeting_message => nil
      }
    end
  end
end
