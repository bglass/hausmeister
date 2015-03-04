module Record
  def record
    if self.is_a? Class
      cname = self.name+"::"
    else
      cname = self.class.name+"#"
    end
    mname = cname+caller_locations(1,1)[0].label

    before = Time.now
    result = yield
    after  = Time.now

    @@time ||= {}
    @@call ||= {}
    @@time[mname] ||= 0
    @@call[mname] ||= 0

    @@time[mname] += after-before
    @@call[mname] += 1

    result
  end

  def report
    @@time.sort_by{|k,t| t}.map do |k,v|
      sprintf "%6d %3.3f %1.6f %s",@@call[k], @@time[k], @@time[k]/@@call[k], k
    end
  end
end
