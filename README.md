[![Build Status](https://secure.travis-ci.org/adhearsion/voicemail.png?branch=develop)](http://travis-ci.org/adhearsion/voicemail)

# Voicemail

This plugin aims to provide a basic voicemail implementation, complete with a voicemail system that allows user to listen to messages and manage them. It is currently only compatible with Asterisk, and you will need to provide the audio files and their path in the configuration. The configuration also contains many other options.

## Usage

Every mailbox has an id and PIN that can be provisioned using a pry console.

To send a call to a mailbox use:
```ruby
  # inside a CallController method
  invoke Voicemail::VoicemailController, mailbox: mailbox_id
```

To allow access by users to the mailboxes, `invoke MailboxController`. You will have to provide the mailbox ID to load.
```ruby
  # inside a CallController method
  invoke Voicemail::MailboxController, mailbox: mailbox_id
```

If you want the users to go through pin-based authentication first, pass to the `AuthenticationController` instead:
```ruby
  # inside a CallController method
  invoke Voicemail::AuthenticationController, mailbox: mailbox_id
```

## Storage

Mailbox metadata is stored in a PStore hash on disk for easy drop-in functionality.
To implement your owm storage layer, look at the StorageMain class for method signatures.

You can set the storage layer globally in configuration.
```ruby
  config.voicemail.storage.storage_class = StorageWidget
```

Alternatively, you can pass in a storage layer dynamically when invoking the controller.
```ruby
  if customer.voicemail_version == VERSION_ONE
    invoke Voicemail::VoicemailController, mailbox: customer.mailbox_id, storage: VersionOneStorage.new
  elsif customer.voicemail_version == VERSION_TWO
    invoke Voicemail::VoicemailController, mailbox: customer.mailbox_id, storage: VersionTwoStorage.new
  # etc.
```

## Method Overrides

If you prefer to use your own main menu instead of the [one provided](https://github.com/adhearsion/voicemail/blob/develop/lib/voicemail/call_controllers/mailbox_main_menu_controller.rb#L10-L13), you can set the class to use like so:
```ruby
config.voicemail.main_menu_class = MyMenuController
```

Another override provided is the [pin matcher](https://github.com/adhearsion/voicemail/blob/develop/lib/voicemail/call_controllers/authentication_controller.rb#L43-L45) used to verify authentication - if you want to use your own match-checker (to check against an API or some use), you can also override it:
```ruby
config.voicemail.matcher_class = MyMatcher
```

## Numeric Methods

When you have something like `You have -x- new messages` or `message received on -x-` you can either use the default setting, which will fill the x with TTS, or to use [ahnsay](https://www.github.com/polysics/ahnsay) to use audio files for each digit.
```ruby
config.voicemail.numeric_method = :play_numeric #default
"You have two new messages"

config.voicemail.numeric_method = :ahn_say
"You have" + "file://...two.ul" + "new messages"
```

## Authors

* Original author: [Luca Pradovera](https://github.com/polysics)
* Also contributed: [Justin Aiken](https://github.com/JustinAiken)

## Links

* [Source](https://github.com/adhearsion/voicemail)
* [Bug Tracker](https://github.com/adhearsion/voicemail/issues)

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  * If you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2012 Adhearsion Foundation Inc. MIT license (see LICENSE for details).
