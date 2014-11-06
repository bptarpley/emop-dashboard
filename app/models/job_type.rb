
class JobType < ActiveRecord::Base
   establish_connection("emop_#{Rails.env}".to_sym)
   self.table_name = :job_type
   self.primary_key = :id
   has_many :batch_jobs, foreign_key: 'job_type'

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.(self, :id, :name)
      end
    end
  end
end