class GroupsController < ApplicationController

	# require 'JSON'

	def index
		# 届いている招待を表示
		# @requests = current_user.accepter_requests.includes([:group, :requester])
		# 所属グループ一覧を表示
		@member_groups = current_user.member_groups
	end

	def show
		@group = Group.includes([:member_users, :tweets]).find(params[:id])
		if @group.member_users.include?(current_user)
			@i_am_member = true
			@tweets = @group.tweets
		elsif @group.accepters.include?(current_user)
			@request_for_me = true
		else
			redirect_to root_path, notice: 'アクセスが許可されていないページです'
		end
	end

	def new
		# フォロワーからメンバーを選んでグループをつくる
		# @friend_first = client.friends　← JSON形式のまんまになる
		# @friend_first = JSON.parse((client.friends).body) ← bodyがエラー
		# @friend_first = JSON.generate(client.friends.first.to_h) ← hashになるが、generateの意味がないっぽい
		# @friend_first = JSON.load(client.friends.first) ←　エラー
		# @friend_first = JSON.parse(client.friends.first) ← エラー

		@friends = client.friends.to_h
		# @friends = JSON.load(client.friends) ← エラー、なんかおしい

		@friend = @friends[:users]

		# フォロワー情報を取ってきて、Majitterユーザーだけ表示する(グループメンバー候補)



		# 本番用
		followers_hash = client.followers.to_h
		followers = followers_hash[:users]

		maji_uids = User.pluck(:uid) # pluck: 任意のカラムの値の配列をつくる
		@maji_followers = []

		followers.each do |f|
			f_user = User.find_by(uid: f[:id_str])
			unless f_user==nil 
				# f[:maji_id] = f_user.id
				# @maji_followers << f
				@maji_followers << f_user
			end
		end

		@group = Group.new
	end

	def create
		# グループの新規作成
		group = Group.new(group_params)
		group.requests.each do |r|
			r[:requester_id] = current_user.id
		end
		gsaved = group.save
		member = Member.new(group_id: group.id, user_id: current_user.id)
		if gsaved && member.save
			redirect_to "/groups/#{group.id}"
		else
			redirect_to new_group_path, notice: 'グループの作成に失敗しました'
		end
	end


	private

	def group_params
		params.require(:group).permit(:group_name, {:accepter_ids => []} )
	end

end
