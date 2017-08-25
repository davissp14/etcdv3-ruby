
class Etcdv3
  class EnumeratorQueue
    extend Forwardable
    def_delegators :@q, :push

    def initialize(sentinel)
      @q = Queue.new
      @sentinel = sentinel
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

