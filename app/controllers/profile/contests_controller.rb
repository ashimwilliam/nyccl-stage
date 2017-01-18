class Profile::ContestsController < Profile::ProfileController

  def index
    @contests = Contest.where(is_active: true)
  end 
  
end
