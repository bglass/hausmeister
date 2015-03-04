module Database
  def self.connect
    ActiveRecord::Base.establish_connection(
      :adapter  => "mysql",
      :host     => "localhost",
      :username => "knx",
      :password => "knx",
      :database => "knx2"
    )
  end
end
