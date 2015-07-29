require 'spec_helper'

describe Link do
  it "should require a name" do
    expect(Link.new()).not_to be_valid
    expect(Link.new(:name => '')).not_to be_valid
    expect(Link.new(:name => 'link name')).to be_valid
  end
end
