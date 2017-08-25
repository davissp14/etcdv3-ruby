
class Etcdv3
  class EnumeratorQueue
    SENTINEL = Object.new

    extend Forwardable
    def_delegators :@q, :push

    def initialize(sentinel: SENTINEL)
      @q = Queue.new
      @sentinel = sentinel
    end

    def cancel
      @q.push(@sentinel)
    end

    def error(error)
      @q.push(error)
    end

    def each_item
      return enum_for(:each_item) unless block_given?
      loop do
        r = @q.pop
        break if r.equal?(@sentinel)
        fail r if r.is_a? Exception
        yield r
      end
    end
  end
end

