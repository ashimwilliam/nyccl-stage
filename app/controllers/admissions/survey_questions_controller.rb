class Admissions::SurveyQuestionsController <  Admissions::AdmissionsController
  before_filter :find_question, only: [:edit, :update, :confirm_destroy, :destroy]
  before_filter :check_options, only: [:create, :update]
	
  def index
    @survey_questions = SurveyQuestion.paginate(page: params[:page], per_page: @per_page || params[:per_page])
    order = params[:order]
    dir = params[:dir]

    unless order.blank? 
      @survey_questions = @survey_questions.order("question_title #{dir}")
    else
      @survey_questions = @survey_questions.order('updated_at  DESC')
    end

  end

  def show
  end

  def new
    @survey_question = SurveyQuestion.new
  end

  def create
  	
    @survey_question = SurveyQuestion.new(params[:survey_question])
    
    if @survey_question.save
      redirect_to admin_survey_questions_path, notice: "#{@survey_question.question_title} question saved successfully."
    else
      render :new, notice: "Sorry, something went wrong."
    end
  end

  def edit
   
  end

  def update    
    if @survey_question.update_attributes(params[:survey_question])
      redirect_to admin_survey_questions_path, notice: "#{@survey_question.question_title} question updated successfully."
    else
      flash[:error] = "Sorry, something went wrong."
      render :edit
    end
  end


  def confirm_destroy
  end

  def destroy
    @survey_question.destroy
    redirect_to admin_survey_questions_path, notice: "Successfully deleted '#{@survey_question.question_title}'"
  end

  private
  
  def find_question
    @survey_question = SurveyQuestion.find(params[:id])
  end

  def check_options
    question_type = params[:survey_question][:question_type].to_i
    if question_type == 2 || question_type == 3
      unless params[:survey_question][:survey_options_attributes].present?
        flash[:notice] = "Please add an option for your question."
        redirect_to :back
      end  
    end  
  end  

end
