class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
    has_many :set_metas, :autosave => true, :dependent => :delete_all
  has_many :thermal_storage_profiles, :autosave => true, :dependent => :delete_all
  has_many :calculations, autosave: true, dependent: :delete_all
end
