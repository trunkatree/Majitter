class RequestsController < ApplicationController

	def index
		# 届いている招待を表示
		@requests = current_user.accepter_requests.includes([:group, :requester])
	end

	def destroy
		# グループ参加拒否 (グループ招待(request)を拒否)
		# request = Request.find_by(group_id: params[:id], user_id: current_user.id)
		request = current_user.accepter_requests.find_by(group_id: params[:id])
		unless request==nil
			if request.destroy
				# redirect_to groups_path and return, notice: 'グループ招待を拒否しました'
				flash[:success] = "グループ招待を拒否しました"
				redirect_to groups_path and return
			else
				redirect_to request.referrer || root_url, flash: { error: request.errors.full_messages }
			end
		else
			flash[:danger] = "アクセスが許可されていないページです"
			redirect_to root_path
		end
	end

end
