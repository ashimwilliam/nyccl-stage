class CampaignPpcsController < ApplicationController
  layout 'advertise_ppc'

  def show
    @campaign_ppc = CampaignPpc.find_by_permalink!(params[:id])
    @guest_question = GuestQuestion.new
  end

  def question
	question_params = params[:guest_question]
    guest_user_params = params[:guest_user]

    session[:guest_email] = guest_user_params[:email]
    session[:guest_zipcode] = guest_user_params[:zipcode]

    # return render :new if User.find_by_email(guest_user_params[:email])
    if User.find_by_email(guest_user_params[:email])
      user = User.find_by_email(guest_user_params[:email])
      guest_question = user.questions.new(question_params)

      if guest_question.save
        session[:user_exists] = true
        QuestionMailer.delay(queue: 'questions').send_to_admins(guest_question)
        redirect_to :back, notice: "Your Question has been submitted. We will contact you soon!"
      end

      return
    end

    if GuestUser.find_by_email(guest_user_params[:email])
      @guest_user = GuestUser.find_by_email(guest_user_params[:email])
    else
      @guest_user = GuestUser.create(guest_user_params)
    end

    session[:guest_user_id] = @guest_user.id

    @guest_question = @guest_user.guest_questions.new(question_params)

    if @guest_question.save

      QuestionMailer.delay(queue: 'questions').send_to_admins(@guest_question)

       redirect_to :back, notice: "Your Question has been submitted. We will contact you soon!"    else
    end  
  end	

end
