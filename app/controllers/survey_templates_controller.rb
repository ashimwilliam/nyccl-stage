class SurveyTemplatesController < ApplicationController
  
	def show
	  @user_survey_template = UserSurveyTemplate.find_by_email_secure_token(params[:id])
    if @user_survey_template.present?

      if @user_survey_template.accessed? 
        redirect_to root_path, :notice => "Your response has been successfully submitted"
      else   
        template = SurveyTemplate.find(@user_survey_template.survey_template_id)
        @survey_template = SurveyTemplate.find_by_secure_token(template.secure_token)
      end  

    else
      
      @guest_user_survey_template = GuestUserSurveyTemplate.find_by_email_secure_token(params[:id]) 
      
      if @guest_user_survey_template.accessed?
        redirect_to root_path, :notice => "Your response has been successfully submitted"
      else
        template = SurveyTemplate.find(@guest_user_survey_template.survey_template_id)
        @survey_template = SurveyTemplate.find_by_secure_token(template.secure_token)
      end

    end  
   
  end

  def template
    @survey_template = SurveyTemplate.find_by_secure_token(params[:id])
    puts "#{@survey_template.inspect}===================================="
  end  

  def survey_answer
    @user_survey_template_id = params[:user_survey_template_id].to_i if params[:user_survey_template_id].present?
    if @user_survey_template_id.present?
      @user_survey_template = UserSurveyTemplate.find(@user_survey_template_id)
      @user_survey_template.update_attributes(accessed: true)
    end

    @guest_user_survey_template_id = params[:guest_user_survey_template_id] if params[:guest_user_survey_template_id].present?
    if @guest_user_survey_template_id.present?
      @guest_user_survey_template = GuestUserSurveyTemplate.find(@guest_user_survey_template_id)
      @guest_user_survey_template.update_attributes(accessed: true)
    end  
    params[:survey].each do |id, attribute| 
      survey_question_id = id.to_i
      question = SurveyQuestion.find(survey_question_id)
      ques_type = question.question_type
      if ques_type == 3
        attribute.each  do |option, value|  
          survey_answer =SurveyAnswer.new
          survey_answer.survey_question_id = survey_question_id
          survey_answer.user_survey_template_id = @user_survey_template_id if @user_survey_template_id.present? 
          survey_answer.guest_user_survey_template_id = @guest_user_survey_template_id if @guest_user_survey_template_id.present?
          survey_answer.answer =  value
          survey_answer.save
        end   
      else 
        survey_answer =SurveyAnswer.new
        survey_answer.survey_question_id = survey_question_id
        survey_answer.user_survey_template_id = @user_survey_template_id if @user_survey_template_id.present? 
        survey_answer.guest_user_survey_template_id = @guest_user_survey_template_id if @guest_user_survey_template_id.present?
        survey_answer.answer =  attribute
        survey_answer.save
      end      
    end
    redirect_to root_path, :notice => "Your response has been successfully submitted"
  end
  
end
 