Sequel.migration do
  up do
    create_table(:agents) do
      primary_key :id
      foreign_key :location_id, :items
      String :name, :null=>false
      String :description, :text=>true
    end

    create_table(:items) do
      primary_key :id
      Integer :type, :null=>false, :default=>0
      String :name, :null=>false
      String :description
    end

    create_table(:items_properties) do
      primary_key :id
      foreign_key :item_id, :items
      String :key, :null=>false
      String :value, :null=>false
      index [:item_id, :key], :unique=>true
    end

    create_table(:links) do
      primary_key :id
      foreign_key :src_item_id, :items
      foreign_key :dst_item_id, :items
      String :name, :null=>false
    end

    create_table(:links_properties) do
      primary_key :id
      foreign_key :link_id, :links
      String :key, :null=>false
      String :value, :null=>false
      index [:link_id, :key], :unique=>true
    end

    src = self[:items].insert(:name => 'A dark cave', :description => 'A dark cave at the edge of a desert')
    dst = self[:items].insert(:name => 'Entrance to a dark cave',
    :description => 'The foot of an outcropping of rocks concealing a cave at the edge of a desert.')
    self[:links].insert(:src_item_id => src, :dst_item_id => dst, :name => "Outside")
    self[:links].insert(:src_item_id => dst, :dst_item_id => src, :name => "Cave")
    dst = self[:items].insert(:name => 'Deep inside a dark cave', :description => 'Barely any light fills the space deep within the earth.')
    self[:links].insert(:src_item_id => src, :dst_item_id => dst, :name => "Further Inside")
    self[:links].insert(:src_item_id => dst, :dst_item_id => src, :name => "A faint light")

    player = self[:agents].insert(:name => 'player', :description => 'A wandering stranger in a strange place.', :location_id => src)

  end

  down do
    drop_table(:items)
    drop_table(:items_properties)
    drop_table(:links)
    drop_table(:links_properties)
  end
end
