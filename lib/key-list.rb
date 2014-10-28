require("rubygems")
require("json")

require_relative("key")
require_relative("watch")

class KeyList

  attr_accessor :keys_unblocked
  attr_reader :keys_all

  @@dbg_counter = 0

  def initialize
    @keys_all = {}
    @keys_unblocked = []
    @watcher = Watch.new(self)
  end

  def generate
    @watcher.mutex.lock

    keyObj = Key.new(_generate_random_key)
    # keyObj = Key.new(_dbg_generate_serial_key) # Convenient during dev
    puts "generate #{keyObj}"
    @keys_all[keyObj.val] = keyObj
    @keys_unblocked << keyObj.val

    @watcher.mutex.unlock
    puts debug
    true
  end

  def get
    @watcher.mutex.lock
    ret = if (@keys_unblocked.size == 0)
            nil 
          else
            key = @keys_unblocked.delete_at(rand(@keys_unblocked.size))
            if (!@keys_all.include?(key))
              nil
            else
              _block(key)
              puts "get: #{key}"
              puts debug
              key
            end
          end
    @watcher.mutex.unlock
    ret
  end
  
  def unblock(key)
    puts "Try to unblock #{key}"
    @watcher.mutex.lock

    keyObj = @keys_all[key]
    ret = if (keyObj == nil)
            puts "Unblock: no such key"
            nil
          else
            keyObj.unblock
            @keys_unblocked << key
            key
          end

    @watcher.mutex.unlock
    puts debug
    ret
  end

  def delete(key, msg_suffix="")
    @watcher.mutex.lock

    keyObj = @keys_all[key]
    ret = if (keyObj == nil)
            puts "Delete: no such key #{key} " << msg_suffix
            nil
          else
            # _delete(key)
            @keys_all.delete(key)
            keyObj.val
          end
    
    @watcher.mutex.unlock
    puts debug
    ret
  end

  # def _delete(key)
  #   @watcher.mutex.lock
  #   @keys_all.delete(key)
  #   # The watch/monitor thread will take care of deleting from unblocked_keys
  #   @watcher.mutex.unlock
  # end

  def keepalive(key)
    @watcher.mutex.lock

    keyObj = @keys_all[key]
    ret = if (keyObj == nil)
            nil 
          else
            keyObj.refresh if (keyObj)
            puts "Refresh #{keyObj}"
            keyObj.val
          end

    @watcher.mutex.unlock
    puts debug
    ret
  end

  def debug
    "Debug:\n" <<
      "@keys_all: " << JSON.pretty_generate(@keys_all) << "\n" <<
      "@keys_unblocked: " << JSON.pretty_generate(@keys_unblocked)
  end

  def debug_reset
    puts "debug_reset" 
    @watcher.mutex.lock
    @keys_all = {}
    @keys_unblocked = []
    @watcher.mutex.unlock
    "@keys_all: #{@keys_all.inspect}, @keys_unblocked #{@keys_unblocked}"
  end

  private
  
  def _block(key)
    keyObj = @keys_all[key]
    keyObj.block
  end

  def _generate_random_key
    # The generated key should be unique such that it is assumed that the same
    # key is note generated more than once.
    # Some options to do this are:
    # - Use UUID such that 
    # - Ensure uniqueness using combination of parameters such milliseconds
    #   since epoch, random string

    # For this example program use a simple random string
    length = 32
    (0...length).map { (65 + rand(26)).chr }.join
  end

  def _dbg_generate_serial_key
    count = @@dbg_counter
    @@dbg_counter += 1
    count.to_s
  end

end
