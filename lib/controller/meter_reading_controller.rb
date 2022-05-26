# frozen_string_literal: true

require 'sinatra/base'
require_relative '../service/electricity_reading_service'

class MeterReadingController < Sinatra::Base
  # rubocop:disable Style/OptionalArguments
  def initialize(app = nil, electricity_reading_service)
    super(app)
    @electricity_reading_service = electricity_reading_service
  end
  # rubocop:enable Style/OptionalArguments

  before do
    if request.post? && request.body.length.positive?
      request.body.rewind
      @request_payload = JSON.parse request.body.read
    end
  end

  get '/readings/read/{meter_id}' do
    content_type :json
    @electricity_reading_service.get_readings(@params['meter_id']).to_json
  end

  post '/readings/store' do
    readings = @request_payload['electricityReadings']
    if readings&.length&.positive?
      meter_id = @request_payload['smartMeterId']
      @electricity_reading_service.store_readings(meter_id, readings)
      status 200
    else
      status 500
    end
  end
end
