require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
    let(:philip) { create(:philip, :with_account, :admin) }
    let(:poll)   { create(:poll, user: philip) }

  describe 'flag_notification' do
    let(:mail) { AdminMailer.flag_notification(philip, poll) }

    context 'when rendering header' do
      it 'renders the correct subject' do
        expect(mail.subject).to eq("poll #{poll.id} flagged")
      end
      it 'renders the correct sender' do
        expect(mail.from).to eq(['noreply@buckofive.herokuapps.com'])
      end
      it 'renders the correct receiver' do
        expect(mail.to).to eq([philip.email])
      end
    end

    context 'when rendering the body' do
      it 'contains the poll_url' do
        expect(mail.body.encoded).to match(poll_url(poll))
      end
    end
  end
end
