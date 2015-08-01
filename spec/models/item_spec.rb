require 'spec_helper'

describe Item do
  let(:item) { build(:item) }

  it "has a name" do
    expect(item.name).to eq('item')
  end

  describe '#name' do
    it "requires a name" do
      expect(build(:item, name: '')).not_to be_valid
      expect(build(:item, name: 'item')).to be_valid
    end
  end

end
