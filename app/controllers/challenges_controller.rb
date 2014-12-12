class ChallengesController < ApplicationController
  before_action :set_challenge, only: [:show, :edit, :update, :destroy]
  before_filter :login_user

  # GET /challenges
  # GET /challenges.json
  def index
    @challenges = current_user.challenges
  end

  # GET /challenges/1
  # GET /challenges/1.json
  def show
  end

  # GET /challenges/new
  def new
    @challenge = Challenge.new
    @competitors = User.all
  end

  # GET /challenges/1/edit
  def edit
    @check_old_competitors = UserChallenge.where(:user_id => current_user.id)
    if !@check_old_competitors.blank?
      @select_old_competitors = @check_old_competitors.pluck(:competitor_id)
      @competitors =  User.where("id not in (?)",@select_old_competitors)
    else
      @competitors = User.all
    end
  end

  # POST /challenges
  # POST /challenges.json
  def create
    @challenge = Challenge.new(challenge_params)
    competitors = params[:challenge][:competitor_id].delete_if{ |x| x == "0" }
    if competitors.blank?
        flash[:notice] = "Please select atleast one user to challenge!!"
        redirect_to new_challenge_path
        return
    end
    individual_points = params[:challenge][:points]
    total_points = individual_points.to_i * competitors.count
    available_points = current_user.points
    if !competitors.blank?
      if total_points.to_i > available_points.to_i
        flash[:notice] = "You do not have sufficient reward points to challenge a competitor!!"
        redirect_to new_challenge_path
        return
      end
    else 
      if !individual_points.blank?
        if individual_points.to_i > available_points.to_i
          flash[:notice] = "You do not have sufficient reward points to create a challenge!!"
          redirect_to new_challenge_path
          return
        end
      end
    end    
    # binding.pry

    respond_to do |format|
      if @challenge.save
        if !competitors.blank?
          competitors.each do |competitor|
            UserChallenge.create(:user_id => current_user.id, :competitor_id => competitor, :challenge_id => @challenge.id)
          end
          remaining_points = available_points - total_points 
          if current_user.points_at_stake != "0"
            stake_points = current_user.points_at_stake + total_points
          else
            stake_points = current_user.points_at_stake   
          end
          current_user.update(:points => remaining_points,:points_at_stake => stake_points) 
        end
        format.html { redirect_to @challenge, notice: 'Challenge was successfully created.' }
        format.json { render :show, status: :created, location: @challenge }
      else
        @competitors = User.all
        format.html { render :new }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /challenges/1
  # PATCH/PUT /challenges/1.json
  def update

    competitors = params[:challenge][:competitor_id].delete_if{ |x| x == "0" }
    individual_points = params[:challenge][:points]
    total_points = individual_points.to_i * competitors.count
    available_points = current_user.points
    if !competitors.blank?
      if total_points.to_i > available_points.to_i
        flash[:notice] = "You do not have sufficient reward points to challenge a competitor!!"
        redirect_to edit_challenge_path(@challenge.id)
        return
      end
    else 
      if !individual_points.blank?
        if individual_points.to_i > available_points.to_i
          flash[:notice] = "You do not have sufficient reward points to challenge a competitor!!"
          redirect_to edit_challenge_path(@challenge.id)
          return
        end
      end
    end    

    respond_to do |format|
      if @challenge.update(challenge_params)
        if !competitors.blank?
          competitors.each do |competitor|
            UserChallenge.create(:user_id => current_user.id, :competitor_id => competitor, :challenge_id => @challenge.id)
          end
          remaining_points = available_points - total_points 
          if current_user.points_at_stake != "0"
            stake_points = current_user.points_at_stake + total_points
          else
            stake_points = current_user.points_at_stake   
          end
          current_user.update(:points => remaining_points,:points_at_stake => stake_points) 
        end
        format.html { redirect_to @challenge, notice: 'Challenge was successfully updated.' }
        format.json { render :show, status: :ok, location: @challenge }
      else
        @check_old_competitors = UserChallenge.where(:user_id => current_user.id)
        if !@check_old_competitors.blank?
          @select_old_competitors = @check_old_competitors.pluck(:competitor_id)
          @competitors =  User.where("id not in (?)",@select_old_competitors)
        else
          @competitors = User.all
        end
        format.html { render :edit }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /challenges/1
  # DELETE /challenges/1.json
  def destroy
    @challenge.destroy
    respond_to do |format|
      format.html { redirect_to challenges_url, notice: 'Challenge was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_challenge
      @challenge = Challenge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def challenge_params
      params.require(:challenge).permit(:title, :description, :user_id, :start_date, :end_date, :points)
    end
end
