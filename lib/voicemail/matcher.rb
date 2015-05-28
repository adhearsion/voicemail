# encoding: utf-8
# This template exists for the purpose of being overridden.  See the README for more information.

module Voicemail
  class Matcher
    def initialize(entered, actual)
      @entered = entered.to_s
      @actual  = actual.to_s
    end

    def matches?
      logger.info "input : #{@entered}"
      logger.info "actual: #{@actual}"
      @entered == @actual
    end
  end
end
