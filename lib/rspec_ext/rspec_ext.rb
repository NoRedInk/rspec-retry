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
        if respond_to? :__init_memoized, true
          __init_memoized
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
