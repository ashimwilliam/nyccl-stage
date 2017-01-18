class Admissions::SurveyReportsController < Admissions::AdmissionsController

	def index
	  @survey_templates = SurveyTemplate.paginate(page: params[:page], per_page: @per_page || params[:per_page])
      @status_id = params[:status_id]
      order = params[:order]
      dir = params[:dir]
    
	  unless @status_id.blank?
	    @survey_templates = @survey_templates.where(status_id: @status_id)
	  end

	  unless order.blank? 
        @survey_templates = @survey_templates.order("#{order} #{dir}")
      else
        @survey_templates = @survey_templates.order('updated_at  DESC')
      end
	end

	def report
		@user_templates = []
		template_id = SurveyTemplate.find_by_secure_token(params[:id])
		@user_survey_templates = UserSurveyTemplate.where(survey_template_id: template_id)
		@guest_user_survey_templates = GuestUserSurveyTemplate.where(survey_template_id: template_id)
		@user_templates << @user_survey_templates
		@user_templates << @guest_user_survey_templates
		@user_templates = @user_templates.flatten!
		@user_templates = @user_templates.sort_by!(&:updated_at)
		@user_templates = @user_templates.reverse!  

		@user_templates = @user_templates.paginate(page: params[:page], per_page: params[:per_page])
		
        @status_id = params[:status_id]
        if @status_id.present?
		  if @status_id == "accessed"
			@user_survey_templates =  @user_survey_templates.where(accessed: true)
		    @guest_user_survey_templates = @guest_user_survey_templates.where(accessed: true)
		  elsif @status_id == "unaccessed"
			@user_survey_templates =  @user_survey_templates.where(accessed: false)
		    @guest_user_survey_templates = @guest_user_survey_templates.where(accessed: false)
	      end
	      @user_templates.clear
	      @user_templates << @user_survey_templates
          @user_templates << @guest_user_survey_templates
		  @user_templates = @user_templates.flatten!
		  # @user_templates = @user_templates.sort_by &:updated_at
		  #@user_templates = @user_templates.paginate(page: params[:page], per_page: @per_page || params[:per_page])
	      
	      if @user_templates.count < 25
	        @user_templates = @user_templates.paginate page: 1, per_page: @per_page
	      else
	      	@user_templates = @user_templates.paginate(page: params[:page], per_page: @per_page || params[:per_page])
	      end	

	    end     	 	 

	end 

	def show
	  @survey_answers = SurveyAnswer.where('(user_survey_template_id= ?)', params[:id]) 
    
	    if @survey_answers.blank? 
		    @survey_answers = SurveyAnswer.where('(guest_user_survey_template_id= ?)', params[:id])  
		  end 
	    
	    @survey_questions = []
		  questions = @survey_answers.pluck(:survey_question_id).uniq 

		  questions.each do |ques|
			  begin
		        @survey_questions <<  SurveyQuestion.find(ques)
			  rescue Exception => e
	           logger.error e.message		 
	  	       next
			  end
	    end		   	

	end	

	def confirm_destroy
	  @user_survey_report = UserSurveyTemplate.find_by_email_secure_token(params[:id])
	  
	  if @survey_report.blank?
	  	@guest_user_survey_report = GuestUserSurveyTemplate.find_by_email_secure_token(params[:id])
	  end	

    end

    def delete	
      begin
        @survey_report = UserSurveyTemplate.find(params[:id]) 
      		
      rescue
        @survey_report = GuestUserSurveyTemplate.find(params[:id])
      end	

      survey_token = @survey_report.survey_template.secure_token
      @survey_report.destroy
      redirect_to report_admin_survey_report_path(survey_token),
            notice: "Successfully destroyed report "
    end 	
end
