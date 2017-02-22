require 'spec_helper'

describe HomeController do
  include Warden::Test::Helpers
  Warden.test_mode!
  
  it "should have language-selection links" do
    visit "/"
    page.should_not have_link("English", href: "/en")
    page.should have_text("English")
    page.should have_link(SimpleTranslationEngine.translate_text(:spanish))
  end

  it "should switch to spanish when selection link is clicked" do
    visit "/"
    click_link SimpleTranslationEngine.translate_text(:spanish)
    I18n.locale.should be :es
    # next check isn't really helpful, because locale selection is hidden in translate_helper()
  end

  it "should stick to selected language as I navigate" do
    visit "/"
    click_link SimpleTranslationEngine.translate_text(:spanish)
    I18n.locale.should be :es
    click_link SimpleTranslationEngine.translate_text(:log_in)
    I18n.locale.should be :es
    page.should have_text('Correo electrónico')
    # page.should have_text(TranslationEngine.translate_text('simple_form.labels.defaults.email'))
  end

  it "should switch to another locale correctly when in the non-default locale" do
    visit "/"
    click_link SimpleTranslationEngine.translate_text(:spanish)
    I18n.locale.should be :es
    click_link 'English'
    I18n.locale.should be :en
  end

end
