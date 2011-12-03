module Gitvault
  module CLI
    class Error < StandardError ; end
  
    class BadRequest    < Error ; end # 400, 406
    class Unauthorized  < Error ; end # 401
    class Forbidden     < Error ; end # 403
    class NotFound      < Error ; end # 404
    class InternalError < Error ; end # 500
  end
end
