require "simple_translation_engine/version"

#refactor these includes at some point, if possible
#require 'tasks/database_tasks'
require 'tasks/install'
require 'tasks/load'

module SimpleTranslationEngine

  class Engine < ::Rails::Engine

    engine_name 'simple_translation_engine'
    
  end

  def self.translate(locale_param, key_param, options={})
    locale = Locale.find_by(name: locale_param)
    unless locale
      return "missing locale #{locale_param}"
    end
    key = TranslationKey.find_by(name: key_param)
    unless key
      return "missing key #{key_param}"
    end

    translation = Translation.find_by(locale: locale, translation_key: key)
    return translation.nil? ? 'missing translation #{locale.name}:#{key.name}' : translation.value 
  end

  def self.set_translation(locale_param, key_param, value)
    locale = Locale.find_by(name: locale_param)
    unless locale
      return false
    end 
    key = TranslationKey.first_or_create!(name: key_param)
    translation = Translation.first_or_create!(locale: locale, translation_key: key)
    translation.value = value
    return translation.save 
  end
  
end
