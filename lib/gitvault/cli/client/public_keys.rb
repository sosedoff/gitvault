module Gitvault::CLI
  module PublicKeys
    def get_public_keys
      get('/public_keys')
    end
    
    def get_public_key(id)
      get("/public_keys/#{id}")
    end
    
    def create_public_key(content)
      post("/public_keys")
    end
    
    def delete_public_key(id)
      delete("/public_keys/#{id}")
    end
  end
end
