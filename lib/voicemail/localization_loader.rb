module Voicemail::LocalizationLoader

  def self.replace_config
    translation_keys.each { |key, value| override_config key, value }
  end

  #
  #This method scans the keys in the template en.yml - it doesn't use any values,
  #it just sets up methods to call i18n.translate later
  #
  def self.override_config(key, value)
    i18n = Voicemail::Plugin.config.i18n_provider
    if value.class == String
      Voicemail::Plugin.config[key.to_sym] = Proc.new { i18n.t "voicemail.#{key}" }
    elsif value.respond_to?(:keys)
      value.keys.each do |k, v|
        Voicemail::Plugin.config[key.to_sym][k.to_sym] = Proc.new { i18n.t("voicemail.#{key}.#{k}") }
      end
    else
      Voicemail::Plugin.config[key.to_sym] = value
    end
  end

  def self.translation_keys
    YAML.load(File.open("#{current_path}/../../templates/en.yml"))['en']['voicemail']
  end

  def self.current_path
    File.expand_path File.dirname(__FILE__)
  end
end
