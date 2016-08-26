module RoundRobin
  class Track
    attr_accessor :name, :list

    def initialize(name, list=[])
      @name = name
      @list = list
    end

    def add element
      list << element
    end

    def cycle
      list.rotate!
    end

    def next
      list[0].tap { cycle }
    end
  end

  describe Track do
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