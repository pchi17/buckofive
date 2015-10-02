require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:philip)   { create(:philip,   :with_account, :admin) }
  let(:mike)     { create(:mike,     :with_account, :activated) }
  let(:stephens) { create(:stephens, :with_account, :activated)}
  let(:poll)     { create(:poll, creator: mike) }
  let!(:comment) { create(:comment, user: mike, poll: poll)}

  it { expect(subject).to use_before_action :logged_in_user? }
  it { expect(subject).to use_before_action :activated_current_user? }

  describe 'POST #create' do
    # assume an activated user is logged in, we already tested before_actions
    context 'when posting with format.html' do
      context 'with valid content' do
        before(:each) do |example|
          login(mike)
          unless example.metadata[:skip_before]
            post :create, poll_id: poll, comment: { content: 'hello' }
          end
        end
        it 'creates finds the poll' do
          expect(assigns(:poll)).to eq(poll)
        end
        it 'builds a valid  new comment' do
          expect(assigns(:comment)).to be_valid
        end
        it 'creates a new poll', skip_before: true do
          expect {
            post :create, poll_id: poll, comment: { content: 'hello' }
          }.to change { Comment.count }.by(1)
        end
        it { expect(subject).to redirect_to poll }
      end

      context 'with invalid content' do
        before(:each) do |example|
          login(mike)
          unless example.metadata[:skip_before]
            post :create, poll_id: poll, comment: { content: '   ' }
          end
        end
        it 'creates finds the poll' do
          expect(assigns(:poll)).to eq(poll)
        end
        it 'builds a valid  new comment' do
          expect(assigns(:comment)).to be_invalid
        end
        it 'creates a new poll', skip_before: true do
          expect {
            post :create, poll_id: poll, comment: { content: '   ' }
          }.to_not change { Comment.count }
        end
        it { expect(subject).to render_template :'polls/show' }
      end
    end
    context 'when posting with format.js' do
      context 'with valid content' do
        before(:each) do |example|
          login(mike)
          unless example.metadata[:skip_before]
            post :create, poll_id: poll, comment: { content: 'hello' }, format: :js
          end
        end
        it 'creates finds the poll' do
          expect(assigns(:poll)).to eq(poll)
        end
        it 'builds a valid  new comment' do
          expect(assigns(:comment)).to be_valid
        end
        it 'creates a new poll', skip_before: true do
          expect {
            post :create, poll_id: poll, comment: { content: 'hello' }, format: :js
          }.to change { Comment.count }.by(1)
        end
        it { expect(subject).to render_template :create }
      end

      context 'with invalid content' do
        before(:each) do |example|
          login(mike)
          unless example.metadata[:skip_before]
            post :create, poll_id: poll, comment: { content: '   ' }, format: :js
          end
        end
        it 'creates finds the poll' do
          expect(assigns(:poll)).to eq(poll)
        end
        it 'builds a valid  new comment' do
          expect(assigns(:comment)).to be_invalid
        end
        it 'creates a new poll', skip_before: true do
          expect {
            post :create, poll_id: poll, comment: { content: '   ' }, format: :js
          }.to_not change { Comment.count }
        end
        it { expect(subject).to render_template :new }
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when logged in as poll creator' do
      before(:each) do |example|
        login(mike)
        unless example.metadata[:skip_before]
          delete :destroy, poll_id: poll, id: comment
        end
      end
      it 'finds the poll' do
        expect(assigns(:poll)).to eq(poll)
      end
      it 'finds the comment' do
        expect(assigns(:comment)).to eq(comment)
      end
      it 'deletes the comment', skip_before: true do
        expect {
          delete :destroy, poll_id: poll, id: comment
        }.to change { Comment.count }.by(-1)
      end
      it { expect(subject).to redirect_to poll }

      context 'with format.js', skip_before: true do
        it 'renders :destroy.js.erb' do
          delete :destroy, poll_id: poll, id: comment, format: :js
          expect(subject).to render_template :destroy
        end
      end
    end

    context 'when logged in as admin' do
      before(:each) do |example|
        login(philip)
        unless example.metadata[:skip_before]
          delete :destroy, poll_id: poll, id: comment
        end
      end
      it 'finds the poll' do
        expect(assigns(:poll)).to eq(poll)
      end
      it 'finds the comment' do
        expect(assigns(:comment)).to eq(comment)
      end
      it 'deletes the comment', skip_before: true do
        expect {
          delete :destroy, poll_id: poll, id: comment
        }.to change { Comment.count }.by(-1)
      end
      it { expect(subject).to redirect_to poll }

      context 'with format.js', skip_before: true do
        it 'renders :destroy.js.erb' do
          delete :destroy, poll_id: poll, id: comment, format: :js
          expect(subject).to render_template :destroy
        end
      end
    end

    context 'when logged in as another activated user' do
      before(:each) do |example|
        login(stephens)
        unless example.metadata[:skip_before]
          delete :destroy, poll_id: poll, id: comment
        end
      end
      it 'finds the poll' do
        expect(assigns(:poll)).to eq(poll)
      end
      it 'finds the comment' do
        expect(assigns(:comment)).to eq(comment)
      end
      it 'does not deletes the comment', skip_before: true do
        expect {
          delete :destroy, poll_id: poll, id: comment
        }.to_not change { Comment.count }
      end
      it { expect(subject).to redirect_to poll }

      context 'with format.js', skip_before: true do
        it 'renders json: nil' do
          delete :destroy, poll_id: poll, id: comment, format: :js
          expect(response.body).to eq("null") #render nil in json format
          expect(subject).to respond_with 200
        end
      end
    end
  end
end
