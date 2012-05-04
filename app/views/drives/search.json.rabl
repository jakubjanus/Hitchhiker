collection @drives, :root => false, :object_root => false

attributes :id, :date, :free_seats, :is_up_to_date

node :start_city do |d|
  d.start_city.name
end

node :destination_city do |d|
  d.destination_city.name
end