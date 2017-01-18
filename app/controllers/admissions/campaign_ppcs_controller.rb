class Admissions::CampaignPpcsController < Admissions::AdmissionsController

  before_filter :set_ppc, only: [:edit, :update, :confirm_destroy, :destroy]
  load_resource find_by: :permalink
  authorize_resource

  def index
    order = params[:order]
    dir = (params[:dir].blank? || params[:dir] == "asc") ? "asc" : "desc"
    @campaign_ppcs = CampaignPpc.paginate page: params[:page], per_page: @per_page

    unless order.blank?
      @campaign_ppcs = @campaign_ppcs.order("#{order} #{dir}")
    else
      @campaign_ppcs = @campaign_ppcs.order('updated_at desc')   
    end

    @status_id = params[:status_id]
    
    unless @status_id.blank?
      @campaign_ppcs = @campaign_ppcs.where(status_id: @status_id)
    end
  end

  def show

  end

  def new
    @campaign_ppc = CampaignPpc.new
  end

  def create
    @campaign_ppc = CampaignPpc.new(params[:campaign_ppc])
    @campaign_ppc.layout = 1 if @campaign_ppc.layout.blank?
    if @campaign_ppc.save
      redirect_to admin_campaign_ppcs_path, notice: "PPC campaign page saved successfully."
    else
      render :new, notice: "Sorry, something went wrong."
    end
  end

  def edit
   
  end

  def update    
     if params[:is_removed].present?
        @campaign_ppc.image = nil
        @campaign_ppc.save
      end  
    if @campaign_ppc.update_attributes(params[:campaign_ppc])
     
      redirect_to admin_campaign_ppcs_path, notice: "PPC campaign page updated successfully."
    else
      flash[:error] = "Sorry, something went wrong."
      render :edit
    end
  end


  def confirm_destroy
  end

  def destroy
    @campaign_ppc.destroy
    redirect_to admin_campaign_ppcs_path,
      notice: "Successfully destroyed #{@campaign_ppc.title}."
  end

  private

  def set_ppc
    @campaign_ppc = CampaignPpc.find_by_permalink!(params[:id])
  end

end
