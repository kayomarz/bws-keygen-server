class Key

  attr_accessor :blocked, :val

  # (USECS = micro seconds)
  EXPIRE_INTERVAL_USECS = 5 * 60 * 1000000
  AUTO_UNBLOCK_INTERVAL_USECS = 60 * 1000000
  
  def initialize(val)
    @val = val
    @blocked = false # used only for debugging
    @timestamp = timestamp_now
    @timestamp_when_blocked = nil
  end

  def refresh
    @timestamp = timestamp_now
    puts "refreshed #{@val}"
  end

  def has_expired
    (timestamp_now - @timestamp) > Key::EXPIRE_INTERVAL_USECS
  end

  def should_be_auto_unblocked?
    return false if (!@blocked)
    return false if (@timestamp_when_blocked == nil)
    (timestamp_now - @timestamp_when_blocked) > Key::AUTO_UNBLOCK_INTERVAL_USECS
  end

  def block
    # puts "block: #{self}"
    @timestamp_when_blocked = timestamp_now
    @blocked = true
  end

  def unblock
    # puts "Unblock: #{self}"
    @timestamp_when_blocked = nil
    @blocked = false
  end

  private

  def timestamp_now
    (Time.now.to_f * 1000 * 1000).round.to_i
  end

  def to_s
    "#{@val}:" <<
      " b" << (@blocked ? "1" : "0") <<
      " e" << (self.has_expired ? "1" : "0")
  end

end
