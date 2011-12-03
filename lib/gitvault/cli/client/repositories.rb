module Gitvault::CLI
  module Repositories
    def get_repositories
      get('/repositories')
    end
    
    def get_repository(name)
      get("/repositories/#{name}")
    end
    
    def create_repository(name)
      post("/repositories", :name => name)
    end
    
    def delete_repository(name)
      delete("/repositories/#{name}")
    end
  end
end