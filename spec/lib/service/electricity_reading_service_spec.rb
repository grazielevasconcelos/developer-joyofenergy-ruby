# frozen_string_literal: true

require 'spec_helper'

describe ElectricityReadingService do
  subject(:meter_reading_service) { described_class.new(readings_store) }

  let(:readings_store) do
    [
      {
        time: '2020-11-17T08:00+00',
        reading: 0.0503
      },
      {
        time: '2020-11-18T08:00+00',
        reading: 0.0213
      }
    ]
  end

  xit 'should return empty array when date is before' do
    expect(meter_reading_service.getPreviousWeek).to eq([])
  end

  it "returns null when asked for a meter that doesn't exist" do
    meter_reading_service = ElectricityReadingService.new
    expect(meter_reading_service.getReadings('nonexistent-meter')).to be_nil
  end

  it 'returns meter readings for a meter that exists' do
    meter_reading_service = ElectricityReadingService.new
    meter_reading_service.storeReadings('meter-id', [])
    expect(meter_reading_service.getReadings('meter-id')).to eq []
  end

  it 'stores more meter readings against an existing meter' do
    meter_reading_service = ElectricityReadingService.new
    meter_reading_service.storeReadings('meter-id', ['reading 1'])
    meter_reading_service.storeReadings('meter-id', ['reading 2'])
    expect(meter_reading_service.getReadings('meter-id')).to eq ['reading 1', 'reading 2']
  end
end
