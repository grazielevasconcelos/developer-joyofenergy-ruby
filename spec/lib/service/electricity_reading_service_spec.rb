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

  context 'with previous week empty' do
    it 'returns empty array when date is before' do
      meter_reading_service = described_class.new
      meter_reading_service.store_readings('meter-id', readings_store)
      expect(meter_reading_service.get_previous_week('meter-id')).to eq([])
    end
  end

  context 'with previous week has data' do
    let(:interval_end) { Date.today - Date.today.cwday }
    let(:interval_begin) { interval_end - 7 }
    let(:readings_store) do
      [
        { time: interval_begin.iso8601.to_s, reading: 0.0503 },
        { time: interval_end.iso8601.to_s, reading: 0.0213 }
      ]
    end

    it 'returns empty array when date is before' do
      meter_reading_service = described_class.new
      meter_reading_service.store_readings('meter-id', readings_store)
      expect(meter_reading_service.get_previous_week('meter-id')).to eq(readings_store)
    end
  end

  it "returns null when asked for a meter that doesn't exist" do
    meter_reading_service = described_class.new
    expect(meter_reading_service.get_readings('nonexistent-meter').nil?).to be(true)
  end

  it 'returns meter readings for a meter that exists' do
    meter_reading_service = described_class.new
    meter_reading_service.store_readings('meter-id', [])
    expect(meter_reading_service.get_readings('meter-id')).to eq []
  end

  it 'stores more meter readings against an existing meter' do
    meter_reading_service = described_class.new
    meter_reading_service.store_readings('meter-id', ['reading 1'])
    meter_reading_service.store_readings('meter-id', ['reading 2'])
    expect(meter_reading_service.get_readings('meter-id')).to eq ['reading 1', 'reading 2']
  end
end
