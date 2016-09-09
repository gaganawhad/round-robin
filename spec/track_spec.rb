require 'track'

module RoundRobin
  def self.redis
    @redis ||= Redis.new(url: 'redis://localhost:6379')
  end

  describe Track do
    before do
      RoundRobin.redis.flushall
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

  describe RedisTrackStore do
    describe '#update_track' do
      it 'adds the track if one does not exist' do
        RedisTrackStore.new('new-array', ['foo', 'bar', 'baz']).update_track
        expect(RoundRobin.redis.lrange('new-array', 0, -1)).to eq ['foo', 'bar', 'baz']
      end

      it 'updates existing track if one does not exists' do
        RedisTrackStore.new('new-array', ['foo', 'bar', 'baz']).update_track
        RedisTrackStore.new('new-array', ['a', 'b', 'c']).update_track

        expect(RoundRobin.redis.lrange('new-array', 0, -1)).to eq ['a', 'b', 'c']
      end
    end
  end
end
