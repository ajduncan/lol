FactoryGirl.define do
  factory :item do
    name "item"
  end

  factory :link do
    name "link"
  end

  factory :agent do
    name "player"
    description "a player"
    location_id item
  end
end
