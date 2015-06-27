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
      def clear_memoized
        # __memoized is private method and is defined in rspec 3.3
        __memoized.instance_variable_get(:@memoized).clear
      rescue NameError
        @__memoized = nil
      end

      def clear_lets
        clear_memoized
      end
    end
  end
end
