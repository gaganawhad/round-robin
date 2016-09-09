require 'redis'

module RoundRobin
  class Track
    attr_accessor :name, :list

    def initialize(name, list=[])
      @name = name
      @list = list
    end

    def add element
      persist { list << element }
    end

    def cycle
      persist { list.rotate! }
    end

    def next
      persist do
        cycle
        list.last
      end
    end

    def persist
      yield.tap do
        save
      end
    end

    def save
      RedisTrackStore.new(name, list).update_track
    end
  end

  class RedisTrackStore
    attr_reader :name, :list, :redis

    def initialize(name, list)
      @name = name
      @list = list
      @redis = Redis.new(url: 'redis://localhost:6379')
    end

    def update_track
      redis.del name if redis.exists name
      redis.rpush name, list
    end
  end
end
