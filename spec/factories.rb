FactoryGirl.define do
  factory :item do
    name "item"
    description "an item"
  end

  factory :item2 do
    name "item2"
    description "another item"
  end

  factory :link do
    name "link"
    src_item_id 1
    dst_item_id 2
  end

  factory :agent do
    name "player"
    description "a player"
  end
end
