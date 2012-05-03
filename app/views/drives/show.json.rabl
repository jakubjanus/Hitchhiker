object false

node :start_add do |d|
  @drive.start_city.name
end

node :destination_add do |d|
  @drive.destination_city.name
end

node :throughs do
  @drive.mid_locations.collect do |mid|
    mid.city.name
  end
end