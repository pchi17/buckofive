require 'rails_helper'

RSpec.describe PollsController, type: :controller do
  before(:all) do
    @activated_user   = create(:philip, :activated)
    @unactivated_user = create(:mike)
  end

  it { expect(subject).to use_before_action(:logged_in_user?) }
  it { expect(subject).to use_before_action(:activated_current_user?) }

  describe 'GET #new' do
    context 'when logged in' do
      context 'when current_user is activated' do
        before(:each) do
          login(@activated_user)
          get :new
        end

        it 'assigns a new poll to @poll' do
          expect(assigns(:poll).id).to be_nil
        end

        it 'creates 2 choices for @poll' do
          expect(assigns(:poll).choices.length).to eq(2)
        end

        it { expect(subject).to render_template :new }
      end

      context 'when current_user is not activated' do
        before(:each) do
          login(@unactivated_user)
          get :new
        end

        it { expect(subject).to set_flash[:warning] }
        it { expect(subject).to redirect_to edit_profile_path }
      end
    end

    context 'when not logged in' do
      before(:each) { get :new }
      it 'stores this page in sessions[:forwarding_url]' do
        expect(session[:forwarding_url]).to eq(new_poll_url)
      end
      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end
  end

  describe 'POST #create' do
    let(:attrs) do
      { content: 'Is this cool?', choices_attributes: {
          '0'=> { value: 'yes' },
          '1'=> { value: 'no'},
          '2'=> { value: 'maybe'}
        }
      }
    end

    context 'when logged in' do
      context 'when current_user is activated' do
        before(:each) { login(@activated_user) }

        context 'with valid attributes' do
          before(:each) do |example|
            post :create, poll: attrs unless example.metadata[:skip_before]
          end

          it 'creates a @poll associated with current_user' do
            expect(assigns(:poll).user).to eq(current_user)
            expect(assigns(:poll).creator).to eq(current_user)
          end

          it { expect(assigns(:poll)).to be_valid }

          it 'creates a poll', skip_before: true do
            expect {
              post :create, poll: attrs
            }.to change(Poll, :count).by(1)
          end

          it 'creates 3 choices', skip_before: true do
            expect {
              post :create, poll: attrs
            }.to change(Choice, :count).by(3)
          end

          it 'creates 3 choices associated with the poll', skip_before: true do
            expect(Choice.count).to eq(0)
            post :create, poll: attrs
            expect(assigns(:poll).choices.count).to eq(3)
          end

          it { expect(subject).to set_flash[:success] }
          it { expect(subject).to redirect_to poll_path(assigns(:poll)) }
        end

        context 'with invalid attributes' do
          context 'when poll content is blank' do
            let(:bad_attrs) do
              { content: '', choices_attributes: {
                  '0'=> { value: 'yes' },
                  '1'=> { value: 'no'},
                  '2'=> { value: 'maybe'}
                }
              }
            end

            before(:each) do |example|
              post :create, poll: bad_attrs unless example.metadata[:skip_before]
            end

            it { expect(assigns(:poll)).to be_invalid }

            it 'does not create a poll', skip_before: true do
              expect {
                post :create, poll: bad_attrs
              }.to_not change(Poll, :count)
            end

            it 'does not creates any choices', skip_before: true do
              expect {
                post :create, poll: bad_attrs
              }.to_not change(Choice, :count)
            end

            it { expect(subject).to render_template :new }
          end

          context 'when choices duplicate (case insensitive)' do
            let(:bad_attrs) do
              { content: 'Is this cool?', choices_attributes: {
                  '0'=> { value: 'yes' },
                  '1'=> { value: 'no'},
                  '2'=> { value: 'YES'}
                }
              }
            end

            before(:each) do |example|
              post :create, poll: bad_attrs unless example.metadata[:skip_before]
            end

            it { expect(assigns(:poll)).to be_invalid }

            it 'does not create a poll', skip_before: true do
              expect {
                post :create, poll: bad_attrs
              }.to_not change(Poll, :count)
            end

            it 'does not creates any choices', skip_before: true do
              expect {
                post :create, poll: bad_attrs
              }.to_not change(Choice, :count)
            end

            it { expect(subject).to render_template :new }
          end

          context 'when there are fewer than 2 non-blank choices' do
            let(:bad_attrs) do
              { content: 'Is this cool?', choices_attributes: {
                '0' => { value: 'yes' },
                '1' => { value: '' },
                '2' => { value: '   ' }
                }
              }
            end

            before(:each) do |example|
              post :create, poll: bad_attrs unless example.metadata[:skip_before]
            end

            it { expect(assigns(:poll)).to be_invalid }

            it 'does not create a poll', skip_before: true do
              expect {
                post :create, poll: bad_attrs
              }.to_not change(Poll, :count)
            end

            it 'does not creates any choices', skip_before: true do
              expect {
                post :create, poll: bad_attrs
              }.to_not change(Choice, :count)
            end

            it { expect(subject).to render_template :new }
          end
        end
      end

      context 'when current_user is not activated' do
        before(:each) do
          login(@unactivated_user)
          post :create, poll: attrs
        end

        it { expect(subject).to set_flash[:warning] }
        it { expect(subject).to redirect_to edit_profile_path }
      end
    end

    context 'when not logged in' do
      before(:each) { get :new }
      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end
  end

  describe 'GET #index'
  describe 'GET #show'
  describe 'DELETE #destroy'
end
