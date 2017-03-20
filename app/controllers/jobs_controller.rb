class JobsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :update, :edit, :destroy]
  before_action :validate_search_key, only: [:search]

  def show
    @job = Job.find(params[:id])

    if @job.is_hidden
      flash[:warning] = "This Job already archieved"
      redirect_to root_path
    end
  end

  def index
    if params[:category].blank?
      @jobs = Job.where(is_hidden: false).recent
    else
      @category_id = Category.find_by(name: params[:category]).id
      @jobs = Job.where(:category_id => @category_id).recent
    end
  end

  def new
    @job = Job.new
    @categorys = Category.all.map { |c| [c.name, c.id]}
  end

  def create
    @job = Job.new(job_params)
    @job.category_id = params[:category_id]
    if @job.save
      redirect_to jobs_path
    else
      render :new
    end
  end

  def edit
    @job = Job.find(params[:id])
  end

  def update
    @job = Job.find(params[:id])
    if @job.update(job_params)
      redirect_to jobs_path
    else
      render :edit
    end
  end

  def destroy
    @job = Job.find(params[:id])
    @job.destroy
    redirect_to jobs.path
  end

  def search
    if @query_string.present?
      search_result = Job.ransack(@search_criteria).result(:distinct => true)
      @jobs = search_result.paginate(:page => params[:page], :per_page => 5 )
    end
  end

  def category
    @category_id = Category.find_by(name: params[:category]).id
    @jobs = Job.where(category_id: @category_id).order("created_at DESC")
  end


  protected

  def validate_search_key
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?
    @search_criteria = search_criteria(@query_string)
  end


  def search_criteria(query_string)
    { :title_cont => query_string }
  end

  private

  def job_params
    params.require(:job).permit(:title, :description, :wage_lower_bound, :wage_upper_bound, :contact_email, :is_hidden, :category_id)
  end

end
