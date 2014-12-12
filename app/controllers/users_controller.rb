class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        @user.update(:points => "100", :points_at_stake => "0")
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def given_challenge
    
    @challenges_list = UserChallenge.where(:competitor_id => current_user.id).pluck(:challenge_id)
    @challenges_to_me = Challenge.where("id in (?)",@challenges_list)

    respond_to do |format|
      format.html 
    end

  end

  

  def accept_challenge
    @challenge = Challenge.find(params[:challenege_id])
    @user_challenge = UserChallenge.where(:competitor_id => current_user.id,:challenge_id => @challenge.id).first
    if current_user.points > @challenge.points
      reduce_points = current_user.points - @challenge.points
      add_stake_points = current_user.points_at_stake + @challenge.points
      current_user.update(:points_at_stake => add_stake_points,:points => reduce_points) 
      @user_challenge.update(:is_accepted => true)
      flash[:notice] = "You have successfully accepted this challenge"
      redirect_to (:back)
      return
    else
      flash[:notice] = "You do not have sufficient reward points to keep at stake for this challenge"
      redirect_to (:back)
      return
    end
  end

  def complete_challenge
    @challenge = Challenge.find(params[:challenege_id])
    @user_challenge = UserChallenge.where(:competitor_id => current_user.id,:challenge_id => @challenge.id).first
    @user_challenge.update(:is_completed => true)


    flash[:notice] = "You have successfully completed this challenge"
    redirect_to (:back)
  end

  def reject_challenge
    @challenge = Challenge.find(params[:challenege_id])
    @user_challenge = UserChallenge.where(:competitor_id => current_user.id,:challenge_id => @challenge.id).first
    @user_challenge.update(:is_accepted => false)
    
    # challenge_owner = User.find @user_challenge.user_id
    # user_points = challenge_owner.points + @challenge.points
    # user_stakes = challenge_owner.points_at_stake - @challenge.points
    # challenge_owner.update(:points => user_points, :points_at_stake => user_stakes)

    flash[:notice] = "You have successfully rejected this challenge"
    redirect_to (:back)
  end

  def approve_challenge
    @challenge = Challenge.find(params[:challenge_id])
    @competitor = User.find(params[:competitor_id])
    @user_challenges = UserChallenge.where(:challenge_id => @challenge.id)
    @user_challenges.update_all(:is_active => false)
    @user_challenge = UserChallenge.where(:competitor_id => @competitor.id,:challenge_id => @challenge.id).first
    @user_challenge.update(:is_approved => true)
    accepted_challengers = UserChallenge.where(:challenge_id => @challenge.id, :is_accepted => true)
    persons_involved = accepted_challengers.count + 1
    competitor_points = @competitor.points + ( 2 * @challenge.points )
    competitor_stakes = @competitor.points_at_stake - @challenge.points
    @competitor.update(:points => competitor_points, :points_at_stake => competitor_stakes)
    user_stakes = current_user.points_at_stake - @challenge.points
    current_user.update(:points_at_stake => user_stakes)
    # binding.pry
    user_and_winner = [@competitor.id, current_user.id]
    other_participants = accepted_challengers.where("competitor_id not in (?)",user_and_winner).pluck(:competitor_id)
    if !other_participants.blank?
    user_participants = User.where("id in (?)",other_participants)
      if !user_participants.blank?
        user_participants.each do |user|
          usr_stake = user.points_at_stake - @challenge.points
          user.update(:points_at_stake => usr_stake)
        end
      end
    end

    flash[:notice] = "You have successfully approved this challenge"
    redirect_to (:back)
  end

  def disapprove_challenge
    @challenge = Challenge.find(params[:challenge_id])
    @competitor = User.find(params[:competitor_id])
    @user_challenge = UserChallenge.where(:competitor_id => @competitor.id,:challenge_id => @challenge.id).first
    @user_challenge.update(:is_approved => false)
    # competitor_stakes = @competitor.points_at_stake - @challenge.points
    # @competitor.update(:points_at_stake => competitor_stakes)
    # user_points = current_user.points + ( 2 * @challenge.points )
    # user_stakes = current_user.points_at_stake - @challenge.points
    # current_user.update(:points => user_points, :points_at_stake => user_stakes)

    flash[:notice] = "You have successfully rejected this challenge"
    redirect_to (:back)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end
end
