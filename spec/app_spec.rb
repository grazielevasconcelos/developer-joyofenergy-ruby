# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/FilePath
RSpec.describe JOIEnergy do
  # rubocop:enable RSpec/FilePath
  include Rack::Test::Methods

  def app
    JOIEnergy
  end

  let(:readings_record) do
    {
      'smartMeterId' => 'smart-meter-0',
      'electricityReadings' => [{ time: '2018-01-01T00:00:00.000Z', reading: 1.5 }]
    }
  end

  it 'returns valid' do
    post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json'

    get '/readings/read/smart-meter-0'

    expect(last_response.ok?).to be(true)
  end

  it 'returns corrected content type' do
    post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json'

    get '/readings/read/smart-meter-0'

    expect(last_response['Content-type']).to include('json')
  end

  it 'given a meter id, it should return readings' do
    post '/readings/store', readings_record.to_json, 'CONTENT_TYPE' => 'application/json'

    get '/readings/read/smart-meter-0'

    expect(last_response.body).to include('reading')
  end
end
