class ReferenceDatabase < ActiveRecord::Base
  attr_accessible :name, :path

  after_create :generate

  private
  def generate
    DbRef::DbFactory.generate_DB_REF(path)
  end
end
