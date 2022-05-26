# frozen_string_literal: true

require 'spec_helper'

describe MeterReadingController do
  include Rack::Test::Methods

  subject(:app) { described_class.new(electricity_reading_service) }

  let(:electricity_reading_service) { ElectricityReadingService.new }

  describe '/readings/store' do
    let(:readings_record) do
      {
        'smartMeterId' => '0101010',
        'electricityReadings' => [
          { time: '2018-01-01T00:00:00.000Z', reading: 1.5 },
          { time: '2018-01-01T00:00:00.000Z', reading: 1.5 }
        ]
      }
    end

    let(:more_readings) do
      {
        'smartMeterId' => '0101010',
        'electricityReadings' => [
          { time: '2018-01-01T00:00:00.000Z', reading: 1.5 }
        ]
      }
    end

    it 'create stores a meter reading against a new meter' do
      post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response.ok?).to be(true)
    end

    it 'returns stores a meter reading against a new meter' do
      post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json'
      get '/readings/read/0101010'
      expect(JSON.parse(last_response.body).length).to eq 2
    end

    it 'create stores more meter readings against an existing meter' do
      post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json'
      post '/readings/store', more_readings.to_json, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.ok?).to be(true)
    end

    it 'returns stores more meter readings against an existing meter' do
      post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json'
      post '/readings/store', more_readings.to_json, 'CONTENT_TYPE' => 'application/json'
      get '/readings/read/0101010'

      expect(JSON.parse(last_response.body).length).to eq 3
    end

    it 'returns error when no meter id is supplied' do
      post '/readings/store', {}.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 500
    end

    it 'returns error when given empty readings' do
      post '/readings/store', { 'smartMeterId' => '0101010', 'electricityReadings' => [] }.to_json,
           'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 500
    end

    it 'returns error when readings not provided' do
      post '/readings/store', { 'smartMeterId' => '0101010' }.to_json, 'CONTENT_TYPE' => 'application/json'
      expect(last_response.status).to eq 500
    end
  end
end
