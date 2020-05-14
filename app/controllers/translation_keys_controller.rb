class TranslationKeysController < ApplicationController

  before_action :set_translation_key

  def destroy
    @translation_key.destroy
    flash[:success] = "Translation Removed"
    redirect_to simple_translation_engine.translations_path
  end

  def edit

    google_api_key = ENV['GOOGLE_API_KEY']

    translator = (google_api_key ? GoogleTranslator.new(google_api_key) : DummyTranslator.new).from(I18n.default_locale)
    source_locale = Locale.of(I18n.default_locale)

    @google_translations = {}

    Locale.where(name: I18n.available_locales.sort).where.not(name: I18n.default_locale).each do |locale|
      unless @translation_key.translation(locale)
        @translation_key.translations.build(locale: locale)
      end

      unless @translation_key.name.blank?
        translator = translator.to(locale.name)
        source_translation = SimpleTranslationEngine.translate(source_locale, @translation_key.name).to_s
        target_translation = translator.translate(source_translation)
        @google_translations[locale.id] = target_translation
      end
    end
  end

  def update

    Rails.logger.info "Saving translation.  Params = "
    Rails.logger.info params

    if @translation_key.update(translation_key_params)
      flash[:success] = "Translation Successfully Updated"
      redirect_to simple_translation_engine.translations_path
    else
      begin
        @translation_key.update!(translation_key_params)
      rescue Exception => e
        Rails.logger.info "Exception saving translation"
        Rails.logger.info e
      end
      render 'edit'
    end
  end

  private

  def set_translation_key
    @translation_key = TranslationKey.find(params[:id])
  end

  def translation_key_params
    params.require(:translation_key).permit(:translations_attributes => [:id, :translation_key_id, :locale_id, :value])
  end

end