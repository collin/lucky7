module Lucky7
  module Renders
    class << self
      def render template, object="__context"
        "={\"#{template}\":#{object}}"
      end
    end
  end
end