require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  let(:philip) { create(:philip, :with_account, :admin) }
  let(:mike)   { create(:mike,   :with_account, :activated) }

  describe 'GET #new' do
    context 'when not logged in' do
      it 'creates a new contact' do
        get :new
        expect(assigns(:contact).sender_email).to be_nil
      end
    end
    context 'when logged in' do
      it 'sets contact sender_email to current_user email' do
        login(mike)
        get :new
        expect(assigns(:contact).sender_email).to eq(mike.email)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      before(:all) do
        @attrs = { sender_email: 'foo@bar.com', message: 'how are you?'}
        @admin_count = User.admins.count
      end
      before(:each) { |example| post :create, contact: @attrs unless example.metadata[:skip_before] }

      it { expect(subject).to set_flash[:success] }
      it { expect(subject).to redirect_to contact_path }

      it 'emails all admins', skip_before: true do
        expect {
          post :create, contact: @attrs
        }.to change { AdminMailer.deliveries.size }.by(@admin_count)
      end

      context 'with JS' do
        it 'emails all admins', skip_before: true do
          expect {
            post :create, contact: @attrs, format: :js
          }.to change { AdminMailer.deliveries.size }.by(@admin_count)
        end
      end
    end

    context 'with blank message' do
      before(:all) { @attrs = { sender_email: 'foo@bar.com', message: '   '} }

      it 'does not send any email' do
        expect {
          post :create, contact: @attrs
        }.to_not change { AdminMailer.deliveries.size }
      end
      it 'renders :new' do
        post :create, contact: @attrs
        expect(subject).to render_template :new
      end
    end

    context 'with blank email' do
      before(:all) { @attrs = { sender_email: '  ', message: 'what sup'} }

      it 'does not send any email' do
        expect {
          post :create, contact: @attrs
        }.to_not change { AdminMailer.deliveries.size }
      end
      it 'renders :new' do
        post :create, contact: @attrs
        expect(subject).to render_template :new
      end
    end

    context 'with invalid email' do
      before(:all) { @attrs = { sender_email: 'foo@invalid', message: 'what sup'} }

      it 'does not send any email' do
        expect {
          post :create, contact: @attrs
        }.to_not change { AdminMailer.deliveries.size }
      end
      it 'renders :new' do
        post :create, contact: @attrs
        expect(subject).to render_template :new
      end
    end
  end
end
