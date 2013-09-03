# develop
  * FEATURE - Seperate weclome/authentication from `MailboxController`, for those that wish to use their own.
  * CS - Rename config option for when to answer
  * CS - DRY up duplicated `#mailbox_not_found` method
  * BUGFIX - Don't strip extensions or `file://'` - punchblock will do that if needed

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
