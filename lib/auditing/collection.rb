module Auditing
  class Collection
    include Enumerable

    def initialize(klass, cursor)
      @klass = klass
      @cursor = cursor
    end

    def each
      @cursor.each do |element|
        yield @klass.new(element)
      end
    end

    def first
      result = @cursor.first
      @cursor.rewind!
      @klass.new(result)
    end

    def size
      @cursor.count
    end

    def method_missing(method, *args, &block)
      if @cursor.respond_to?(method)
        self.class.new(@klass, @cursor.__send__(method, *args, &block))
      else
        super
      end
    end
  end
end
