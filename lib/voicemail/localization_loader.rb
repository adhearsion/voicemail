module Voicemail::LocalizationLoader

  def self.replace_config
    translation_keys.each { |key, value| override_config key, value }
  end

  #
  #This method scans the keys in the template en.yml - it doesn't use any values,
  #it just sets up methods to call i18n.translate later
  #
  def self.override_config(key, value)
    if value.class == String
      Voicemail::Plugin.config[key.to_sym] = Proc.new { I18n.t "voicemail.#{key}" }
    else
      value.keys.each do |k, v|
        Voicemail::Plugin.config[key.to_sym][k.to_sym] = Proc.new { I18n.t("voicemail.#{key}.#{k}") }
      end
    end
  end

  def self.translation_keys
    YAML.load(File.open("#{current_path}/../../templates/en.yml"))['en']['voicemail']
  end

  def self.current_path
    File.expand_path File.dirname(__FILE__)
  end
end
