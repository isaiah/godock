class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :openid_authenticatable, :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :remember_me, :identity_url
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
    User.new(identity_url: identity_url)
  end

  def self.openid_required_fields
    ["fullname", "email", "http://axschema.org/namePerson", "http://axschema.org/contact/email"]
  end

  def self.openid_optional_fields
    ["gender", "http://axschema.org/person/gender"]
  end

  def openid_fields=(fields)
    fields.each do |key, value|
      # Some AX providers can return multiple values per key
      if value.is_a? Array
        value = value.first
      end

      case key.to_s
      when "fullname", "http://axschema.org/namePerson"
        self.login = value
      when "email", "http://axschema.org/contact/email"
        self.email = value
      else
        logger.error "Unknown OpenID field: #{key}"
      end
    end
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
