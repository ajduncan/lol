require 'spec_helper'

describe Agent do
  let(:item) { build(:item) }
  let(:agent) { build(:agent, location: item) }

  it "has a name" do
    expect(agent.name).to eq('player')
  end

  describe '#name' do
    it "requires a name" do
      expect(build(:agent, name: '')).not_to be_valid
      expect(build(:agent, name: 'player')).to be_valid
    end
  end

end
