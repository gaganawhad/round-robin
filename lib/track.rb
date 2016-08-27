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

  describe Track do
    def redis
      @redis ||= Redis.new(url: 'redis://localhost:6379')
    end

    before do
      redis.flushall
    end

    describe '#cycle' do
      it 'cycles through the list' do
        track = Track.new('customer-support', ['Andy', 'Sandy', 'George'])
        track.cycle
        expect(track.list).to eq ['Sandy', 'George', 'Andy']
      end
    end

    describe '#next' do
      it 'returns the element at the head of the list and cycles through it' do
        track = Track.new('customer-support', ['Andy', 'Sandy', 'George'])
        expect(track.next).to eq 'Andy'
        expect(track.list).to eq ['Sandy', 'George', 'Andy']
      end
    end

    describe '#add' do
      it 'adds an element to the end of the list' do
        track = Track.new('customer-support', ['Andy', 'Sandy', 'George'])
        track.add 'Sam'
        expect(track.list).to eq ['Andy', 'Sandy', 'George', 'Sam' ]
      end
    end
  end
end
