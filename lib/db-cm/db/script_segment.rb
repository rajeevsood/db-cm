module Db
  module Cm
    module Db
      class ScriptSegment
        attr_reader :segment, :delimiter

        def initialize(segment, delimiter)
          @segment = segment
          @delimiter = delimiter
        end

        def <<(line)
          @segment<<line
        end
      end
    end
  end
end