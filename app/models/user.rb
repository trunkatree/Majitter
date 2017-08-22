class User < ActiveRecord::Base

	# has_many :members, dependent: :destroy
	# has_many :requests, dependent: :destroy
	# has_many :groups, through: :members
  # has_many :groups, through: :requests

  has_many :members, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :tweets, dependent: :destroy

  has_many :member_groups, through: :members, class_name: 'Group', foreign_key: 'group_id', source: 'group'
  has_many :request_groups, through: :requests, class_name: 'Group', foreign_key: 'group_id', source: 'group'



	#引数に関連するユーザーが存在すればそれを返し、存在しなければ新規に作成する
 	def self.find_or_create_from_auth_hash(auth_hash)
 		provider 	= auth_hash[:provider]
    	uid 		= auth_hash[:uid]
    	nickname 	= auth_hash[:info][:nickname]
    	image_url 	= auth_hash[:info][:image]

    	self.find_or_create_by(provider: provider, uid: uid) do |user|
      		user.nickname = nickname
      		user.image_url = image_url
    	end
 	end

end
