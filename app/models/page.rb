class Page
  include Mongoid::Document
  include Mongoid::Tree
  # include ActiveModel::Serialization
  # include Mongoid::Ancestry
  # has_ancestry

  field :title, type: String
  field :RawName, type: String
  field :ArrivalId, type: String
  field :slogan_1, type: String
  field :slogan_2, type: String
  field :location_name, type: String
  field :location_text, type: String
  field :slug, type: String
  field :image, type: String
  field :visa, type: Boolean, default: true

  field :meta_title, type: String
  field :meta_keyword, type: String
  field :meta_description, type: String

  mount_uploader :image, PhotoUploader
  embeds_many :photos
  embeds_many :departures

  accepts_nested_attributes_for :departures, :allow_destroy => true

  # validates :parent_id, :presence => false
  validates_associated :parent, :children

  rails_admin do
    list do
      field :title
    end
    edit do
      field :title
      field :location_name
      field :meta_title
      field :ArrivalId
      field :slogan_1
      field :slogan_2
      field :parent
      field :visa
      field :image, :carrierwave
      field :location_text, :ck_editor
      field :meta_keyword
      field :meta_description
      field :departures
    end
  end

  def to_param
    slug
  end

  before_create :generate_slug
  before_update :generate_slug

  def start_search
    # if self.pricing.present?
    #   SearchJob.set(wait: 2.second).perform_later(self.slug)
    #   self.update(pricing: false)
    # end
    # SearchJob.perform_later(self.slug)
  end

  # attr_accessor :title, :url

  # def attributes
  #   {
  #       'title' => nil,
  #       'url'  => nil
  #   }
  # end

  def self.get_data slug
    page = self.where({departures: {'$all' => [{'$elemMatch' => {slug: slug}}]}})[0]
    if page.present?
      page = page
    else
      page = self.find_by({slug: slug})
    end

    # page.attributes.slug = slug
    # p page.attributes
    # page.slug  = 'srec'
    page.title = 'srec'
    # page.slug = 'asrcf'

    # page.serializable_hash
    # page.attributes

  end


  def nav_data name
    Page.collection.aggregate(
        [
            {
                '$match' => {
                    parent_id:  {'$in' => [self._id]},
                    departures: {'$all' => [{'$elemMatch' => {name: name}}]}
                }
            },
            {'$unwind' => '$departures'},
            {'$project' =>
                 {
                     title:         1,
                     slug:          "$departures.slug",
                     name:          {'$concat': ["$title", " ", "$departures.name"]},
                     DepartureName: "$departures.name"
                 }
            },
            {'$match' =>
                 {
                     DepartureName: {'$eq': name}
                 }
            }
        ]
    )
  end


  private
  def generate_slug
    p "========"
    unless self.title
      self.title = self.RawName
    end
    self.slug = self.title.parameterize
    # parent_page = self.parent
    # if parent_page.present?
    #   parent_page.departures.each do |departure|
    #     self.departures.find_or_create_by({
    #                                           name:        departure.name,
    #                                           DepartureId: departure.DepartureId
    #                                       })
    #   end
    # end
    self.departures.each do |departure|
      if departure.name.blank?
        departure.name = departure.RawName
      end
      if departure.isDefault.present?
        departure.slug = self.title.parameterize
      else
        departure.slug = self.title.parameterize + '-' + departure.RawName.parameterize
      end
    end
  end

end
