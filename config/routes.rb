SimpleTranslationEngine::Engine.routes.draw do

	resources :translations
	resources :translation_keys, :only => [:destroy]

end