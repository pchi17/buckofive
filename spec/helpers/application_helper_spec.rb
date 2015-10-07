require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#page_title' do
    context 'when passed an argument' do
      it 'returns the "argument | Buck O Five"' do
        expect(page_title('Home')).to eq("Home | Buck O Five")
      end
    end

    context 'when not passed an argument' do
      it 'returns "Buck O Five" only' do
        expect(page_title).to eq("Buck O Five")
      end
    end
  end

  describe '#render_error_message' do
    context 'when passed a valid obj' do
      it 'returns nil' do
        philip = build(:philip, :with_account)
        expect(philip).to be_valid
        expect(render_error_message(philip)).to be_nil
      end
    end

    context 'when passed an invalid obj' do
      it 'does not return nil' do
        philip = build(:philip)
        expect(philip).to be_invalid
        expect(render_error_message(philip)).to_not be_nil
      end
    end
  end
end
