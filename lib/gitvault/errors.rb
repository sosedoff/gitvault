module Gitvault
  class Error       < StandardError ; end
  class ConfigError < Error         ; end
  class GitError    < Error         ; end
  class KeyError    < Error         ; end
end