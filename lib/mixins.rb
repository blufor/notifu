class Object
  def deep_symbolize_keys
    return self.inject({}){|memo,(k,v) | memo[k.to_sym] =  v.deep_symbolize_keys; memo} if self.is_a? Hash
    return self.inject([]){|memo,v     | memo           << v.deep_symbolize_keys; memo} if self.is_a? Array
    return self
  end
end
class Numeric
  def duration
    secs  = self.to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days > 0
      "#{days} days and #{hours % 24} hours"
    elsif hours > 0
      "#{hours} hours and #{mins % 60} minutes"
    elsif mins > 0
      "#{mins} minutes and #{secs % 60} seconds"
    elsif secs >= 0
      "#{secs} seconds"
    end
  end

  def to_state
    case self.to_int
    when 0
      return "OK"
    when 1
      return "WARNING"
    when 2
      return "CRITICAL"
    else
      return "UNKNOWN [#{self.to_s}]"
    end
  end
end

class String
  def camelize
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end

  def to_state
    return self.to_i.to_state
  end
end
