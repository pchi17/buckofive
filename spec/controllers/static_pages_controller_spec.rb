require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do
  describe 'GET #about' do
    it 'renders the :about template' do
      get :about
      expect(response).to render_template :about
    end
  end

  describe 'GET #Help' do
    it 'renders the :help template' do
      get :help
      expect(response).to render_template :help
    end
  end
end
