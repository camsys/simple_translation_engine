class TranslationsController < ApplicationController

    def index
        @locales = Locale.where(name: I18n.available_locales.sort)
        @translation_keys = TranslationKey.visible.order(:name)
        @translations = {}

        @locales.each do |locale|
          @translations[locale.id] = Translation.joins(:translation_key).where(locale: locale).order('translation_keys.name').pluck('translation_keys.name', 'translations.id','value').each_with_object({}) { |(f,l,j),h|  h.update(f=>[l,j]) }
        end
    end

    def new
        locale = Locale.find_by_name(params[:key_locale])
        @key = params[:key] || ""
        @translation = Translation.new(locale: locale || nil)
    end

    def create
        #same form is used to create new keys as well as new translations with existing keys
        locale = Locale.find_by_name(trans_params["locale"])
        translation_key = TranslationKey.find_or_create_by!(name: trans_params["key"])

        #check for existing translation
        existing_translation = Translation.where("locale_id = #{locale.id} AND translation_key_id = #{translation_key.id}")

        if existing_translation.count > 0
            flash[:alert] = "Error: that translation already exists."
            redirect_to simple_translation_engine.translations_path and return
        else
            @translation = Translation.new
            @translation.value = trans_params["value"]
            @translation.locale = locale
            @translation.translation_key = translation_key
        end

        if @translation.save
            flash[:success] = "Translation Successfully Saved"
            redirect_to simple_translation_engine.translations_path
        else
            flash[:alert] = "Error creating translation."
            render 'new'
        end

    end

    def edit
        @translation = Translation.find_by_id params[:id]
    end

    def update
      @translation = Translation.find_by_id params[:id]

      @translation.value = trans_params["value"]

      Rails.logger.info "Saving translation.  Params = "
      Rails.logger.info params

      if @translation.save
        flash[:success] = "Translation Successfully Updated"
        redirect_to simple_translation_engine.translations_path
      else
        begin
          @translation.save!
        rescue Exception => e
          Rails.logger.info "Exception saving translation"
          Rails.logger.info e 
        end
        render 'edit'
      end
    end

    def destroy
        translation_key_ids = params[:id].to_s.split(',')
        Translation.where(translation_key_id: translation_key_ids).delete_all
        TranslationKey.where(id: translation_key_ids).delete_all

        flash[:success] = "Translation Removed"
        redirect_to simple_translation_engine.translations_path
    end
    
    def upload_locale
      @locale = upload_locale_params[:locale]
      @file = upload_locale_params[:file]
      if LocaleUploader.new(@locale, @file)
                       .build_translations
        flash[:success] = "All locale #{@locale.upcase} translations successfully uploaded."
        redirect_to simple_translation_engine.translations_path
      else
        flash[:alert] = "Error creating some translations for locale #{@locale.upcase}."
        redirect_to simple_translation_engine.translations_path
      end
    end

    def edit_locale
      @locale = Locale.find_by(name: params[:lang] || params[:locale])

      google_api_key = ENV['GOOGLE_API_KEY']

      if google_api_key
        translator = GoogleTranslator.new(google_api_key,target: params[:lang] || params[:locale])

        languages = translator.locales.map{|h| h.values}.to_h

        @locales = Locale.where(name: I18n.available_locales.sort).pluck(:name).map{|language_code| [languages[language_code], language_code]}
      else
        @locales = []
      end
    end

    def update_locale
      locale = Locale.find_by(name: update_locale_params[:locale])

      if locale
        google_api_key = ENV['GOOGLE_API_KEY']

        source_locale = Locale.of(I18n.default_locale)
        translator = (google_api_key ? GoogleTranslator.new(google_api_key) : DummyTranslator.new)
                         .from(I18n.default_locale)
                         .to(locale.name)

        source_translations = Translation.where(locale: source_locale)
        unless update_locale_params[:force_update].to_i == 1
          translations = Translation.where(locale: locale)
          source_translations = source_translations.where(translation_key_id: translations.where(value: [nil, '']).select(:translation_key_id)).or(source_translations.where.not(translation_key_id: translations.select(:translation_key_id)))
        end

        source_translations.each do |source_translation|
          target_translation_val = translator.translate(source_translation.value)
          target_translation = Translation.find_or_create_by(translation_key: source_translation.translation_key, locale: locale)
          target_translation.update(value: target_translation_val)
        end

        redirect_to simple_translation_engine.translations_path
      else
        render 'edit'
      end
    end

    private

    def trans_params
      params.require(:translation).permit(:key, :locale, :value)
    end
    
    def upload_locale_params
      params.require(:upload_locale).permit(:locale, :file)
    end

    def update_locale_params
      params.require(:update_locale).permit(:locale, :force_update)
    end

end
