class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :openid_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  def self.find_by_login_or_email(login)
    User.find_by_login(login) || User.find_by_email(login)
  end
  
  def authority
    col = 0
    see_alsos.map{|sa| sa.vote_score}.each do |score|
      col += score
    end
    
    col
  end

  def self.build_from_identity_url(identity_url)
    User.new(:identity_url => identity_url)
  end
  
  private 
  def map_openid_registration(reg)
    self.email = reg["email"] if email.blank?
    self.login = reg["nickname"] if login.blank?
  end
  
  has_many :examples
  has_many :comments
  has_many :see_alsos
  
end
