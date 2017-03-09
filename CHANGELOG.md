# develop
  * BUG - Listening to new messages needs to set the `new_or_saved` metadata. Otherwise, after visiting saved messages, the status is always `:saved`
  * FEATURE - Refactor voicemail storage (backward incompatible change)
    * Pass storage instance in metadata to all controllers
    * Move message status tags from method names to arguments
      * `#count_new_messages(mailbox_id)` becomes `#count_messages(mailbox_id, :new)`
      * `#count_saved_messages(mailbox_id)` becomes `#count_messages(mailbox_id, :saved)`
      * `#archive_message(mailbox_id, message_id)` becomes `#change_message_type(mailbox_id, message_id, :new, :saved)
      * `#unarchive_message(mailbox_id, message_id)` becomes `#change_message_type(mailbox_id, message_id, :saved, :new)
    * `#save_recording(mailbox_id, from, recording_object)` becomes `save_recording(mailbox_id, :new, from, recording_object)`. Can add a recording directly as saved, bypassing the `:new` stage.
    * `#next_saved_message` and `#next_new_message` are removed
    * Mailbox `:greeting_message` property becomes `:greeting`.
  * FEATURE - It is now possible to interrupt the mailbox greeting using a digit. If the configured digit is used, the user is taken to the AuthenticationController.
  * FEATURE - It is now possible to set a separate timeout for the above interruption

# v1.1.2 - 2014-06-23
  * BUG - Re-arrange on_end callback so that recordings are saved if hangup occurs during a recording

# v1.1.1 - 2014-06-10
  * BUG - Remove implicit dependency on loading activesupport

# v1.1.0 - 2014-05-07
  * CHANGE - Menu intros are one message, making them skippable.
  * FEATURE - Personalized voicemail greetings can be deleted
  * FEATURE - Add message to play after recording a voicemail is complete
  * FEATURE - Add an option to erase all messages from a mailbox
  * FEATURE - Put a timeout on waiting for a PIN
  * FEATURE - Allow messages to be skipped
  * BUG - Resolve issue where caller presses the pound key twice in succession

# v1.0.0 - 2014-01-02
  * FEATURE - Optional per-mailbox override of default recording hash
  * FEATURE - Optional rerecording of voicemail messages
  * FEATURE - I18n numeric methods
  * FEATURE - I18n support for keys
  * FEATURE - Seperate pin_checking into seperate matcher class, so that it can be overriden if desired
  * FEATURE - Allow `pin_tries` to be set to 0 for infinite loop
  * FEATURE - Pass the complete recording complete object to `#save_recording`, giving the storage more information; `PStore` only uses the uri, but now you have access to more information (such as duration) if desired for your own storage adapter
  * FEATURE - Seperate weclome/authentication from `MailboxController`, for those that wish to use their own.
  * FEATURE - Add saved count to `MailboxController`
  * FEATURE - Allow overriding `MailboxMainMenuController` with your own custom menu class
  * FEATURE - Ability to listen to new OR saved messages, and archive/unarchive at will.
  * FEATURE - Improved passing of a storage mechanism between controllers
  * FEATURE - Customizable method for using TTS/ahn_say for things like "You have #{x} new messages"
  * CS - Rename config option for when to answer
  * CS - DRY up duplicated `#mailbox_not_found` method
  * CS - Move all the call controllers to their own call_controller directory, to avoid clutter
  * CS - Remove unused `#section_menu` in `MailboxMessagesController`
  * CS - Remove specs for `#main_menu` in `AuthenticationController` since that controller never calls it
  * BUGFIX - Calls passed to `VoicemailController` were never formally hungup
  * BUGFIX - Don't strip extensions or `file://'` - punchblock will do that if needed
  * BUGFIX - Apply datetime formatting to ahnsaid dates
  * DOC - Add Justin Aiken to authors

# v0.2.0 - 2012-08-30
  ## Require adhearsion 2.4 or higher
  * FEATURE - Put more `#record` options into the config instead of hardcoded
  * FEATURE - Freeswitch support
  * FEATURE - Add MIT license to gemspec
  * FEATURE - Add optional location setting for `#answer`
  * CS - Refactoring


# v0.1.0 - 2013-08-28
  * BUGFIX - typo in `#load_message`
  * BUGFIX - `#load_message` not actually called
  * BUGFIX - Pass mailbox id to `MailboxPlayMessageController`
  * BUGFIX - Remove calls to nonexistant `#message_loop`
  * FEATURE - Allow passing in storage adapter
  * FEATURE - Only record one end of voicemail - save 50% of storage costs!
  * FEATURE - TravisCI status added to README

# v0.0.1
  * First release!
