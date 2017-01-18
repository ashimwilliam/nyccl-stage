class Admissions::SurveyTemplatesController < Admissions::AdmissionsController
  before_filter :set_survey, only: [:edit, :confirm_destroy, :destroy, :assign_ques]
	
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

  def show

  end

  def new
    @survey_template = SurveyTemplate.new
  end

  def create
    @survey_template = SurveyTemplate.new(params[:survey_template])
    @survey_template.creator_id = current_user.id
    if @survey_template.save
      redirect_to admin_survey_templates_path, notice: "Survey Template page saved successfully."
    else
      render :new, notice: "Sorry, something went wrong."
    end
  end

  def assign_ques
    @questions = SurveyQuestion.all

    if request.put?
      @questions.each do |ques|
        if params["#{ques.id.to_s}"] == 'on'
          
          if @survey_template.survey_questions.any?
            @survey_template.survey_questions.delete_all
            @survey_template_question = @survey_template.survey_template_questions.new(:survey_question_id => ques.id)
            @survey_template_question.save    
          else
            @survey_template_question = @survey_template.survey_template_questions.new(:survey_question_id => ques.id)
            @survey_template_question.save   
          end      
        end      
      end
      redirect_to admin_survey_templates_path, notice: "Question are assigned to Survey Template page successfully." 
    end
    
  end  

  def edit
   
  end

  def update   
    @survey_template = SurveyTemplate.find(params[:id])
    if @survey_template.update_attributes(params[:survey_template])
      redirect_to admin_survey_templates_path, notice: "Survey Template page updated successfully."
    else
      flash[:error] = "Sorry, something went wrong."
      render :edit
    end
  end


  def confirm_destroy
  end

  def destroy
    @survey_template.destroy
    redirect_to admin_survey_templates_path,
      notice: "Successfully deleted '#{@survey_template.title}'"
  end

  private
  
  def set_survey
    @survey_template = SurveyTemplate.find_by_secure_token(params[:id])
  end


end
