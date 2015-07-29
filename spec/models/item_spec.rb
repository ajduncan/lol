require 'spec_helper'

describe Item do
  it "should require a name" do
    expect(Item.new()).not_to be_valid
    expect(Item.new(:name => '')).not_to be_valid
    expect(Item.new(:name => 'item')).to be_valid
  end
end
