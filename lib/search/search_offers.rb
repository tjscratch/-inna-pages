require 'json'
require 'open-uri'
require 'rails'

class SearchOffers

  attr_reader :dates, :arrival_id, :departure_id, :departure_slug

  def initialize(dates, arrival_id, departure_id, departure_slug)
    @dates        = dates
    @arrival_id   = arrival_id
    @departure_id = departure_id
    @departure_slug = departure_slug

    if Rails.env.production?
      @api_url      = "http://api.inna.ru/api/v1/"
      @url          = "https://nspk.inna.ru/"
      @dates_system = (2..7).to_a
    else
      @api_url      = "https://api.inna.ru/api/v1/"
      @url          = "http://lh.inna.ru/"
      @dates_system = (2..2).to_a
    end

  end

  def array_dates
    if @dates.present?
      @dates = @dates.split(/\,\s+/)
      @dates.map do |item|
        item.split(/\s+/)
      end
    else
      @dates = []
      @dates_system.each do |date|
        date            = Date.current.weeks_since(date)
        startVoyageDate = date.beginning_of_week(:saturday)
        endVoyageDate   = date + 7.day

        @dates << [startVoyageDate.strftime('%F'), endVoyageDate.strftime('%F')]
      end
      @dates
    end
  end

  def get_offers(startVoyageDate, endVoyageDate)
    url_array = [
        @api_url,
        "Packages/SearchHotels?",
        "AddFilter=true&",
        "Adult=2&",
        "ArrivalId=#{@arrival_id}&",
        "DepartureId=#{@departure_id}&",
        "StartVoyageDate=#{startVoyageDate}&",
        "EndVoyageDate=#{endVoyageDate}&",
        "TicketClass=0"
    ].join

    p "-------"
    p @departure_slug
    p url_array
    offer_list = JSON.parse(open(url_array).read)
    if offer_list
      offer_params = {
          HotelId: offer_list['RecommendedPair']['Hotel']['HotelId'],
          HotelProviderId: offer_list['RecommendedPair']['Hotel']['ProviderId'],
          TicketToId: offer_list['RecommendedPair']['AviaInfo']['VariantId1'],
          TicketBackId: offer_list['RecommendedPair']['AviaInfo']['VariantId2'],
          startVoyageDate: startVoyageDate,
          endVoyageDate: endVoyageDate
      }
      self.get_offer(offer_params)
    else
      nil
    end

  end

  def get_offer params
    url_array_details = [
        @api_url,
        "Packages/HotelDetails?",
        "HotelId=#{params[:HotelId]}&",
        "HotelProviderId=#{params[:HotelProviderId]}&",
        "TicketToId=#{params[:TicketBackId]}&",
        "TicketBackId=#{params[:TicketBackId]}&",
        "Filter[displayHotel]=#{params[:HotelId]}&",
        "Filter[DepartureId]=#{@departure_id}&",
        "Filter[ArrivalId]=#{@arrival_id}&",
        "Filter[StartVoyageDate]=#{params[:startVoyageDate]}&",
        "Filter[EndVoyageDate]=#{params[:endVoyageDate]}&",
        "Filter[TicketClass]=0&",
        "Filter[Adult]=2&",
        "Filter[HotelId]=#{params[:HotelId]}&",
        "Filter[TicketId]=#{params[:TicketBackId]}&",
        "Filter[TicketBackId]=#{params[:TicketBackId]}&",
        "Filter[ProviderId]=#{params[:HotelProviderId]}&",
        "Rooms=true",
    ].join

    p url_array_details
    offer_details = JSON.parse(open(url_array_details).read)


    if offer_details.present?

      searchDate = params[:startVoyageDate] + "-" + params[:endVoyageDate]

      searchUrl = [
          @url,
          "#/packages/details/",
          @departure_id,
          "-",
          @arrival_id,
          "-",
          params[:startVoyageDate].to_date.strftime('%d.%m.%Y'),
          "-",
          params[:endVoyageDate].to_date.strftime('%d.%m.%Y'),
          "-0-2--",
          params[:HotelId],
          "-",
          params[:TicketBackId],
          "-",
          params[:TicketBackId],
          "-",
          params[:HotelProviderId],
          "?departureSlug=#{@departure_slug}&SearchDate=#{searchDate}",
      ].join

      offer = {
          SearchDate:      searchDate,
          StartVoyageDate: params[:startVoyageDate].to_date,
          EndVoyageDate:   params[:endVoyageDate].to_date,
          Price:           offer_details['Rooms'][0]['PackagePrice'],
          SearchUrl:       searchUrl,
          Hotel:           offer_details['Hotel'],
          Rooms:           offer_details['Rooms'],
          AviaInfo:        offer_details['AviaInfo'],
      }
    else
      nil
    end
  end


  def offers
    offers = []
    self.array_dates.each do |data|
      # sleep 10
      offers << self.get_offers(data[0], data[1])
    end
    offers.compact
  end

end