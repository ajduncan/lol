require 'spec_helper'

describe Link do
  let(:link) { build(:link) }

  it "has a name" do
    expect(link.name).to eq('link')
  end

  describe '#name' do
    it "requires a name" do
      expect(build(:link, name: '')).not_to be_valid
      expect(build(:link, name: 'link')).to be_valid
    end
  end

end
