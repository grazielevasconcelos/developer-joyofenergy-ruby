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

  describe '/readings/read/{meter_id}/previous_week' do
    subject(:previous_week) { get '/readings/read/0101010/previous_week' }

    context 'with meter id with previous week readings' do
      let(:interval_end) { Date.today - Date.today.cwday }
      let(:interval_begin) { interval_end - 7 }
      let(:readings_record) do
        {
          'smartMeterId' => '0101010',
          'electricityReadings' => [
            { time: interval_begin.iso8601.to_s, reading: 1.5 },
            { time: interval_end.iso8601.to_s, reading: 1.9 }
          ]
        }
      end

      before { post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json' }

      it 'returns http 200' do
        previous_week

        expect(last_response.status).to eq(200)
      end

      it 'returns readings' do
        previous_week

        expect(last_response.body).to eq(readings_record['electricityReadings'].to_json)
      end
    end

    context 'with meter id without readings' do
      let(:readings_record) do
        {
          'smartMeterId' => '0101010',
          'electricityReadings' => [
            { time: '2021-05-20T00:00:58+00:00', reading: 1.5 },
            { time: '2021-05-19T00:00:58+00:00', reading: 1.5 }
          ]
        }
      end

      before { post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json' }

      it 'returns http 200' do
        previous_week

        expect(last_response.status).to eq(200)
      end

      it 'returns empty array' do
        previous_week

        expect(last_response.body).to eq('[]')
      end
    end

    context 'with meter id does not exists' do
      let(:readings_record) do
        {
          'smartMeterId' => '23333',
          'electricityReadings' => [
            { time: '2021-05-20T00:00:58+00:00', reading: 1.5 },
            { time: '2021-05-19T00:00:58+00:00', reading: 1.5 }
          ]
        }
      end

      before { post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json' }

      it 'returns http 404' do
        previous_week

        expect(last_response.status).to eq(404)
      end

      it 'returns empty' do
        previous_week

        expect(last_response.body.empty?).to be(true)
      end
    end
  end
end
