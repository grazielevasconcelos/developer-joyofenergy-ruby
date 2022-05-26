# frozen_string_literal: true

require 'date'

class PricePlanService
  def initialize(price_plans, electricity_reading_service)
    @price_plans = price_plans
    @electricity_reading_service = electricity_reading_service
  end

  def consumption_cost_of_meter_readings_for_each_price_plan(meter_id)
    readings = @electricity_reading_service.get_readings(meter_id)
    if readings.nil?
      nil
    else
      @price_plans.to_h do |p|
        [p.plan_name, calculate_cost(readings, p)]
      end
    end
  end

  def calculate_cost(readings, price_plan)
    average = calculate_average_reading(readings)
    time_elapsed = calculate_time_elapsed(readings)

    averaged_cost = average / time_elapsed

    averaged_cost * price_plan.base_cost
  end

  def calculate_average_reading(readings)
    readings.sum { |entry| entry['reading'] } / readings.length
  end

  def calculate_time_elapsed(readings)
    time_span = readings.map { |entry| DateTime.iso8601(entry['time']).to_time }.minmax
    (time_span[1] - time_span[0]) / 3600.0
  end
end
