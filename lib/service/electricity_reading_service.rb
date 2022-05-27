# frozen_string_literal: true

require_relative '../helpers/usage_interval'
require 'date'

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
    return unless @readings_store[meter_id]

    readings_store_keys_format(meter_id).select do |item|
      time_reading_in_int = to_date_for_int(item[:time])
      time_reading_in_int.between?(interval.begin, interval.end)
    end
  end

  private

  def readings_store_keys_format(meter_id)
    @readings_store[meter_id].map { |item| item&.transform_keys(&:to_sym) }
  end

  def interval
    @interval ||= UsageInterval.usage_interval_from_previous_week
  end

  def to_date_for_int(calendar_day)
    DateTime.parse(calendar_day).to_time.to_i
  end
end
