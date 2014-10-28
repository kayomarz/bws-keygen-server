require('thread')

class Watch

  attr_reader :mutex

  # MSECS = Milli seconds
  MONITOR_INTERVAL_MSECS = 10 * 1000

  def initialize(key_list)
    @key_list = key_list
    @mutex = Mutex.new
    @thread = Thread.new do
      puts "Monitoring..."
      monitor
    end
  end

  def monitor_keys()
    @mutex.lock

    puts "monitor_keys"
    keys_to_be_deleted = []
    @key_list.keys_all.each do |key, keyObj| 
      if (keyObj.has_expired)
        keys_to_be_deleted << key 
      elsif keyObj.should_be_auto_unblocked?
        keyObj.unblock
        @key_list.keys_unblocked << key
      end
    end
    keys_to_be_deleted.each {|item| @key_list.keys_all.delete(item)}

    @mutex.unlock
  end

  def cleanup_unblocked_keys()
    @mutex.lock

    puts "cleanup_unblocked_keys"
    @key_list.keys_unblocked.delete_if do |item|
      # If the key is missing from keys_all, it was previously deleted
      !@key_list.keys_all.include?(item)
    end

    @mutex.unlock
  end

  def monitor
    while (1)
      sleep (1.0/1000 * Watch::MONITOR_INTERVAL_MSECS)
      monitor_keys
      cleanup_unblocked_keys
      puts @key_list.debug
    end
  end

end
