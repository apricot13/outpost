class Admin::UsersController < Admin::BaseController
    before_action :set_user, only: [:show, :update, :destroy]
    
    def index
      @users = User.order(:last_seen).includes(:organisation)

      if params[:deactivated] === "true"
        @users = @users.discarded
      else
        @users = @users.kept
      end

      @users = @users.community if params[:filter_users] === "community"
      @users = @users.admins if params[:filter_users] === "admins"
      @users = @users.never_seen if params[:filter_logged_in] === "never"
      @users = @users.only_seen if params[:filter_logged_in] === "only"

      @users = @users.search(params[:query]) if params[:query].present?


      @active_count = User.kept.count
      @deactivated_count = User.discarded.count
    end

    def new
      @user = User.new
    end

    def create
      @user = User.create(user_params)
      @user.password = SecureRandom.urlsafe_base64
      if @user.save
        UserMailer.with(user: @user).invite_from_admin_email.deliver_later
        redirect_to admin_users_path
      else
        render "new"
      end
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User has been updated"
      else
        render "show"
      end
    end

    def show
      @activities = Snapshot.order("created_at DESC").where(user: params[:id]).limit(5).includes(:service)
    end

    def destroy
      unless @user === current_user
        @user.discard
        redirect_to admin_users_path, notice: "That user has been deactivated"
      else
        redirect_to admin_user_path(@user), notice: "You can't deactivate yourself"
      end
    end

    def reactivate
      User.find(params[:user_id]).undiscard
      redirect_to request.referer, notice: "That user has been reactivated"
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :email,
        :first_name,
        :last_name,
        :admin,
        :organisation_id
      )
    end
end