require 'spec_helper'

describe Agent do
  let(:item) { create(:item) }
  let(:link) { create(:link) }
  let(:agent) { build(:agent, :item => item) }

  before do
    # not sure what the convention here is or if i should just mock
    agent.connection = $stdout
  end

  it "has a name" do
    expect(agent.name).to eq('player')
  end

  it "can move in a direction" do
    expect(agent.item).to eq(item)
    expect { agent.move('link') }.to output('').to_stdout
  end

  describe '#name' do
    it "requires a name" do
      expect(build(:agent, item: item, name: '')).not_to be_valid
      expect(build(:agent, item: item, name: 'player')).to be_valid
    end
  end

end
