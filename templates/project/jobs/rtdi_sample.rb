SCHEDULER.every '15s', allow_overlapping: false do |job|
  # This command ist just for generating sample-data. dont use this!
  values, status = RTDI::Getdata.sample()

  #!!use the commented command below!!
  #values, status = RTDI::Getdata.start(/path/to/rtdi/lib/name_of.csv)


  send_event('dc1', {items:values[0], status:status[0]})
  send_event('dc2', {items:values[1], status:status[1]})
  send_event('dc3', {items:values[2], status:status[2]})
  send_event('network', {items:values[3], status:status[3]})
  send_event('miscellaneous', {items:values[5], status:status[5]})
  send_event('communication', {items: values[4], status:status[4]})
  # and so on ..
end
