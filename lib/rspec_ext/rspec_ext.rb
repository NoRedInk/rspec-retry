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
        if respond_to? :__memoized, true
          __memoized.instance_variable_get(:@memoized).clear
        else
          @__memoized = nil
        end
      end

      def clear_lets
        clear_memoized
      end
    end
  end
end
