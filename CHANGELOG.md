#v1.0.0..
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
