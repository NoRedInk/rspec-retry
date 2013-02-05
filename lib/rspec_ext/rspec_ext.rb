module RSpec
  module Core
    class Example
      def clear_exception
        @exception = nil
      end
    end
  end
end

module RSpec
  module Core
    class ExampleGroup
      def clear_lets
        @__memoized = {}
      end
    end
  end
end

