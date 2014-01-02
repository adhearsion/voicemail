module Voicemail
  class Matcher
    def initialize(entered, actual)
      @entered = entered.try :to_s
      @actual  = actual.try :to_s
    end

    def matches?
      logger.info "input : #{@entered}"
      logger.info "actual: #{@actual}"
      @entered == @actual
    end
  end
end
