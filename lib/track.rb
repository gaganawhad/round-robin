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

    class RedisTrackStore
      def initialize(name, list)
        @name = name
        @list = list
        @redis = Redis.new(url: 'redis://localhost:6379')
      end

      def update_track
        if @redis.exists @name
          @list.each_with_index do |element, index|
            @redis.lset @name, index, element
          end
        else
          @list.each do |element|
            @redis.lpush @name, element
          end
        end
      end
    end
  end
end
