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
end
