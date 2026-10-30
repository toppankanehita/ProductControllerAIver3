# == Schema Information
#
# Table name: uploadfiles
#
#  id           :bigint           not null, primary key
#  name         :string(255)
#  size         :integer
#  content_type :string(255)
#  job_id       :integer
#  life         :integer          default(0)
#  sales_code   :integer
#  sheet_name   :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  change_no    :integer          default(0)
#  lastest      :integer          default(0)
#  data         :binary(65535)
#
class Uploadfile < VisualizeModel
  has_many :up_infos, dependent: :destroy
  has_many :up_data, dependent: :destroy
  has_many :specs,-> {where lastest:1}, dependent:  :destroy
  belongs_to :job, optional: true

  MAX_FILE_SIZE = 1.megabyte
  #UPLOAD_DIR = Rails.root.join("public", "user_images")
  UPLOAD_DIR = "/Volumes/www/user_images/"

  validates :job_id, presence: { message: "名前を入力してください" }
  validates :name, presence: { message: "ファイルを選択して下さい" }
  validates_inclusion_of :size, :in => (1..MAX_FILE_SIZE),allow_nil: true , :message => "ファイルサイズが大きすぎます。"
  validates :size, presence: { message: "ファイルを選択して下さい" }


  def file=(file)
    self.name = file.original_filename if file.respond_to?(:original_filename)
    self.content_type = file.content_type  if file.respond_to?(:content_type)
    self.size = file.size                  if file.respond_to?(:size)
    @tmp = file
  end

  after_create do
    filepath = UPLOAD_DIR + "#{self.id}"
    File.open(filepath, "wb") do |f|
      f.write @tmp.read
    end
  end

  after_destroy do
    filepath = UPLOAD_DIR + "#{self.id}"
    File.delete filepath if File.exist? filepath
  end

  def savepath
    "#{UPLOAD_DIR}/#{self.id}"
  end
  private


end
