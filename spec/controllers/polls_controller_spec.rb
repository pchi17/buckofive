require 'rails_helper'

RSpec.describe PollsController, type: :controller do
  let(:admin)            { create(:philip,   :with_account, :admin) }
  let(:activated_user)   { create(:mike,     :with_account, :activated) }
  let(:unactivated_user) { create(:stephens, :with_account) }
  let(:poll) { build(:poll, creator: admin) }

  it { expect(subject).to use_before_action(:logged_in_user?) }
  it { expect(subject).to use_before_action(:activated_current_user?) }

  describe 'GET #new' do
    context 'when logged in' do
      context 'when current_user is activated' do
        before(:each) do
          login(activated_user)
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
          login(unactivated_user)
          get :new
        end

        it { expect(subject).to set_flash[:warning] }
        it { expect(subject).to redirect_to help_path(anchor: 'activation') }
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
        before(:each) { login(activated_user) }

        context 'with valid attributes' do
          before(:each) do |example|
            post :create, poll: attrs unless example.metadata[:skip_before]
          end

          it 'creates a @poll associated with current_user' do
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
          login(unactivated_user)
          post :create, poll: attrs
        end

        it { expect(subject).to set_flash[:warning] }
        it { expect(subject).to redirect_to help_path(anchor: 'activation') }
      end
    end

    context 'when not logged in' do
      before(:each) { get :new }
      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end
  end

  describe 'GET #index' do
    before(:all) do
      user = create(:philip, :with_account, :activated)
      @poll1 = create(:poll, content: 'blah blah abc', creator: user)
      @poll2 = create(:poll, content: 'blah blah xyz', creator: user)
      @poll3 = create(:poll, content: 'blah blah ccc', creator: user)
    end

    after(:all) { DatabaseCleaner.clean_with(:deletion) }

    context 'with no params' do
      before(:each) { get :index }
      it 'returns all polls' do
        expect(assigns(:polls).count).to eq(3)
      end
      it 'defaults to sort by created_at desc' do
        expect(assigns(:polls)).to eq([@poll3, @poll2, @poll1])
      end
    end

    context 'with search_term = c' do
      before(:each) { get :index, search_term: 'c' }
      it 'returns first 2 polls' do
        expect(assigns(:polls).count).to eq(2)
      end
      it 'defaults to sort by created_at desc' do
        expect(assigns(:polls)).to eq([@poll3, @poll1])
      end
    end

    context 'with sort = content' do
      before(:each) { get :index, sort: 'content'}
      it 'returns all polls' do
        expect(assigns(:polls).count).to eq(3)
      end
      it 'defaults to desc' do
        expect(assigns(:polls)).to eq([@poll2, @poll3, @poll1])
      end
    end

    context 'with sort = content and direction = asc' do
      before(:each) { get :index, sort: 'content', direction: 'asc' }
      it 'returns all polls' do
        expect(assigns(:polls).count).to eq(3)
      end
      it 'defaults to desc' do
        expect(assigns(:polls)).to eq([@poll1, @poll3, @poll2])
      end
    end

    it { get :index; expect(subject).to render_template :index }
  end

  describe 'GET #show' do
    before(:each) { poll.save }

    context 'when logged in and activated' do
      before(:each) do
        login(activated_user)
        get :show, id: poll.id
      end

      it 'finds the correct poll' do
        expect(assigns(:poll)).to eq(poll)
      end
      it 'renders the show template' do
        expect(subject).to render_template :show
      end
    end

    context 'when not logged in' do
      before(:each) { get :show, id: poll.id }
      it { expect(subject).to render_template :show }
    end

    context 'when not activated' do
      before(:each) do
        login(unactivated_user)
        get :show, id: poll.id
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) { poll.save }

    context 'when logged in and activated' do
      context 'when logged in as admin' do
        before(:each) do
          login(admin)
        end
        it 'deletes the poll' do
          expect {
            delete :destroy, id: poll.id
          }.to change { Poll.count }.by(-1)
        end
        it 'redirect_to root_path' do
          delete :destroy, id: poll.id
          expect(subject).to redirect_to profile_path
        end
      end

      context 'when logged in as non-admin' do
        before(:each) { login(activated_user) }

        context 'when deleting own poll' do
          before(:each) { @poll = create(:poll, content: 'what is this?', creator: activated_user) }
          it 'deletes the poll' do
            expect {
              delete :destroy, id: @poll.id
            }.to change { Poll.count }.by(-1)
          end

          it 'redirect_to root_path' do
            delete :destroy, id: @poll.id
            expect(subject).to redirect_to profile_path
          end
        end

        context 'when deleting others poll' do
          it 'does not delete the poll' do
            expect {
              delete :destroy, id: poll.id
            }.to_not change { Poll.count }
          end

          it 'redirect_to root_path' do
            delete :destroy, id: poll.id
            expect(subject).to redirect_to @poll
          end
        end
      end
    end

    context 'when not logged in' do
      before(:each) { delete :destroy, id: poll.id }

      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end

    context 'when not activated' do
      before(:each) do
        login(unactivated_user)
        delete :destroy, id: poll.id
      end

      it { expect(subject).to set_flash[:warning] }
      it { expect(subject).to redirect_to help_path(anchor: 'activation') }
    end
  end
end
