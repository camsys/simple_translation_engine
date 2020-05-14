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

    private

    def trans_params
      params.require(:translation).permit(:key, :locale, :value)
    end
    
    def upload_locale_params
      params.require(:upload_locale).permit(:locale, :file)
    end

end
