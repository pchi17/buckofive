require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do
  render_views

  describe '#home action' do
    before(:each) { get :home }
    it 'renders the static_pages/home view' do
      expect(response).to render_template :home
    end
    it 'has "Home | Buck O Five" as title' do
      assert_select 'title', page_title('Home')
    end
  end

  describe '#about action' do
    before(:each) { get :about }
    it 'renders the static_pages/about view' do
      expect(response).to render_template :about
    end
    it 'has "About | Buck O Five" as title' do
      assert_select 'title', page_title('About')
    end
  end

  describe '#Help action' do
    before(:each) { get :help }
    it 'renders the static_pages/help view' do
      expect(response).to render_template :help
    end
    it 'has "Help | Buck O Five" as title' do
      assert_select 'title', page_title('Help')
    end
  end

  describe '#contact action' do
    before(:each) { get :contact }
    it 'renders the static_pages/contact view' do
      expect(response).to render_template :contact
    end
    it 'has "Contact | Buck O Five" as title' do
      assert_select 'title', page_title('Contact')
    end
  end
end
