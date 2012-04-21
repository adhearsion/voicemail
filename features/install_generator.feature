@announce
Feature: Voicemail Installer Generator
  In order to do development on new Adhearsion apps with the Voicemail plugin
  As an Adhearsion developer
  I want to install the required files from the Voicemail plugin

  Scenario: Generate a valid controller and its spec
    When I run `ahn create path/somewhere`
    And I cd to "path/somewhere"
    And this gem is installed in that application
    And I run `ahn generate voicemail:install`
    Then the following files should exist:
      | lib/models/mailbox.rb  |
      | lib/models/message.rb  |

