module Voicemail
  class StorageGeneric
    def initialize
    end

    #
    # Get the mailbox with the specified ID
    #
    # @param mailbox_id The ID of the mailbox to fetch
    #
    def get_mailbox(mailbox_id)
    end

    #
    # Count the specified mailbox's messages of the specified type
    #
    # @param mailbox_id The mailbox's ID
    # @param type[Symbol] The type of message to count (defaults to :new and :saved)
    #
    # @return [Fixnum] the number of messages
    #
    def count_messages(mailbox_id, type)
    end

    #
    # Gets the specified mailbox's next message of the specified type
    #
    # @param mailbox_id The mailbox's ID
    # @param type[Symbol] The type of message to get (see #count_messages)
    #
    # @return [Hash] The message hash
    #
    def next_message(mailbox_id, type)
    end

    #
    # Change a message's type, e.g. from :new to :saved or vice versa
    #
    # @param mailbox_id The mailbox's ID
    # @param message_id The message's ID
    # @param from[Symbol] the current type of the message
    # @param to[Symbol] the desired type of the message
    #
    def change_message_type(mailbox_id, message_id, from, to)
    end

    #
    # Deletes the specified message
    #
    # @param mailbox_id The mailbox's ID
    # @param message_id The message's ID
    # @param type[Symbol] The message's type
    #
    def delete_message(mailbox_id, message_id, type)
    end

    #
    # Changes the mailbox's greeting to the one specified
    #
    # @param mailbox_id The mailbox's ID
    # @param recording_uri[String] Where to find the recording of the greeting
    #
    def save_greeting_for_mailbox(mailbox_id, recording_uri)
    end

    #
    # Removes any custom greeting set for the mailbox
    #
    # @param mailbox_id The mailbox's ID
    #
    def delete_greeting_from_mailbox(mailbox_id)
    end

    #
    # Changes the PIN for the mailbox
    #
    # @param mailbox_id The mailbox's ID
    # @param new_pin[String] The new PIN for the mailbox
    #
    def change_pin_for_mailbox(mailbox_id, new_pin)
    end

    #
    # Saves a recorded voicemail message to the mailbox
    #
    # @param mailbox_id The mailbox's ID
    # @param type[Symbol] The type of message to be created (e.g. :new or :saved)
    # @param from[String] The phone number of the message's sender
    # @param recording_object[Punchblock::Component::Record] The recording result from Adhearsion
    #
    def save_recording(mailbox_id, type, from, recording_object)
    end

    def create_mailbox
    end

    private

    #
    # Initializes the mailbox system schema if there isn't one already.
    # If implemented in a custom storage class, this method should not overwrite existing any existing schema.
    #
    def setup_schema
    end

    def config
      Voicemail::Plugin.config
    end
  end
end
