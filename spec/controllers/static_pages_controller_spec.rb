require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do

  describe '#home action' do
    it 'renders the static_pages/home view' do
      get :home
      expect(response).to render_template :home
    end
  end

  describe '#about action' do
    it 'renders the static_pages/about view' do
      get :about
      expect(response).to render_template :about
    end
  end

  describe '#Help action' do
    it 'renders the static_pages/help view' do
      get :help
      expect(response).to render_template :help
    end
  end

  describe '#contact action' do
    it 'renders the static_pages/contact view' do
      get :contact
      expect(response).to render_template :contact
    end
  end
end
