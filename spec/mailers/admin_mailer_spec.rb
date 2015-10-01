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

  describe 'contact_message' do
    let(:mike) { create(:mike, :with_account) }
    let(:msg)  { 'what is going on bro?' }
    let(:mail) { AdminMailer.contact_message(mike.email, philip.email, msg)}

    context 'when rendering header' do
      it 'renders the correct subject' do
        expect(mail.subject).to eq("Message from a user of Buck O Five")
      end
      it 'renders the correct sender' do
        expect(mail.from).to eq([mike.email])
      end
      it 'renders the correct receiver' do
        expect(mail.to).to eq([philip.email])
      end
    end

    context 'when rendering the body' do
      it 'contains the poll_url' do
        expect(mail.body.encoded).to match(msg)
      end
    end
  end
end
