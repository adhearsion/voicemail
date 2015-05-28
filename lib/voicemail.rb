require 'adhearsion'

module Voicemail; end
require "voicemail/version"
require "voicemail/storage_pstore"
require "voicemail/storage"
require "voicemail/matcher"
require "voicemail/localization_loader"
require "voicemail/call_controllers/application_controller"
require "voicemail/call_controllers/voicemail_controller"
require "voicemail/call_controllers/mailbox_controller"
require "voicemail/call_controllers/authentication_controller"
require "voicemail/call_controllers/mailbox_main_menu_controller"
require "voicemail/call_controllers/mailbox_messages_controller"
require "voicemail/call_controllers/mailbox_play_message_intro_controller"
require "voicemail/call_controllers/mailbox_play_message_controller"
require "voicemail/call_controllers/mailbox_set_greeting_controller"
require "voicemail/call_controllers/mailbox_set_pin_controller"
require "voicemail/call_controllers/mailbox_cleaner_controller"


require "voicemail/plugin"
