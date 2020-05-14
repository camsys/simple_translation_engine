SimpleTranslationEngine::Engine.routes.draw do

	resources :translations do
		collection do
			post 'upload_locale'
		end
	end
	
	resources :translation_keys, :only => [:edit,:update, :destroy]


end
