# frozen_string_literal: true

require_relative '../helpers/usage_interval'

class ElectricityReadingService
  def initialize(readings_store = nil)
    @readings_store = readings_store || {}
  end

  def get_readings(meter_id)
    @readings_store[meter_id]
  end

  def store_readings(meter_id, readings)
    @readings_store[meter_id] ||= []
    @readings_store[meter_id].concat(readings)
  end

  def get_previous_week(meter_id)
    interval = UsageInterval.usage_interval_from_previous_week
    readings = @readings_store[meter_id]

    readings.select { |item| interval.begin < item['time'] && interval.end > item['time'] }
  end
end
