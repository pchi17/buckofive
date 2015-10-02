class PollsController < ApplicationController
  before_action :logged_in_user?,         except: [:index, :show]
  before_action :activated_current_user?, except: [:index, :show]

  def new
    @poll = current_user.polls.build
    @poll.choices.build(value: 'Yay')
    @poll.choices.build(value: 'Nay')
  end

  def create
    @poll = current_user.polls.build(poll_params)
    if params[:add_choice]
      @poll.choices.build
    elsif params[:remove_choices]
      # do nothing, allow_destroy automatically removes choices marked with :_destroy
    else
      if @poll.save
        flash[:success] = 'your poll was created successfully'
        return redirect_to poll_path(@poll)
      end
    end
    render :new
  end

  def index
    @polls = Poll.search(params[:search_term], sort_column, sort_direction, params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @poll     = Poll.find(params[:id])
    @comment  = @poll.comments.build
    @comments = @poll.comments.paginate(page: params[:page], per_page: 10)
  end

  def destroy
    @poll = Poll.find(params[:id])
    if @poll.created_by?(current_user) || current_user.admin?
      @poll.delete
      flash[:info] = 'poll deleted'
      redirect_to flags_path
    else
      redirect_to @poll
    end
  end

  private
    def poll_params
      params.require(:poll).permit(:content, :picture, choices_attributes: [:value, :_destroy] )
    end
end
