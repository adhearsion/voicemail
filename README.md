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

## Customizing Voicemail

The easiest way to customize the main menu is by subclassing (MailboxMainMenuController](https://github.com/adhearsion/voicemail/blob/develop/lib/voicemail/call_controllers/mailbox_main_menu_controller.rb) and replacing the `#main_menu` method with one of your own.

Within `#main_menu` you have several options that can be invoked, each by simply calling the method:

* listen_to_new_messages - self-explanatory
* listen_to_saved_messages - self-explanatory
* set_greeting - prompt to set the mailbox greeting
* set_pin - prompt to set the mailbox PIN
* empty_mailbox(:new or :saved or :all) - removes all (new or saved) messages from a given mailbox. Includes confirmation for safety

Then tell Adhearsion to use your new voicemail menu class:
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

## Internationalization

This plugin also provides support for internationalization:

```ruby
# Enable I18n support in the plugin
config.voicemail.use_i18n = true

# Tell your application where your local files are, and set a default
I18n.load_path += Dir[File.join(config.platform.root, 'config', 'locales', '*.{rb,yml}').to_s]
I18n.default_locale = :en
```

Either run `rake voicemail:i18n_init` to copy a starting `en.yml` file from the plugin into your application (default location is `#{ahn_root}/config/locales/en.yml`), or [look at the template](https://github.com/adhearsion/voicemail/blob/develop/templates/en.yml) to get an idea of what translation keys to add to your app's existing localization files.

You can also use I18n to handle the numeric methods:

```ruby
config.voicemail.numeric_method = :i18n_string
"You have two new messages"
"You have one new message"
```

Using I18n for the numeric method will nicely handle pluralizing message counts and formating the datetime messages were received on.

## Authors

Original author: [Luca Pradovera](https://github.com/polysics)

Contributors:
* [Luca Pradovera](https://github.com/polysics)
* [Justin Aiken](https://github.com/JustinAiken)
* [Ben Klang](https://github.com/bklang)
* [Evan McGee](https://github.com/emcgee)
* [Will Drexler](https://github.com/wdrexler)

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

Copyright (c) 2012-2014 Adhearsion Foundation Inc. MIT license (see LICENSE for details).
