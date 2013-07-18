if defined? Rspec
  # only for test environment
else
  require "blossom/redis_persistence"
  self.persistence = Blossom::RedisPersistence.new
end
