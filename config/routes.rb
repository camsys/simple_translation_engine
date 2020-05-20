SimpleTranslationEngine::Engine.routes.draw do

	resources :translations do
		collection do
      get 'edit_locale'
      post 'update_locale'
			post 'upload_locale'
		end
	end
	
	resources :translation_keys, :only => [:edit,:update, :destroy]


end
