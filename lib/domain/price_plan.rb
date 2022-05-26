# frozen_string_literal: true

class PricePlan
  attr_reader :plan_name, :base_cost

  def initialize(plan_name, energy_supplier, base_cost, peak_time_multipliers)
    @plan_name = plan_name
    @energy_supplier = energy_supplier
    @base_cost = base_cost
    @peak_time_multipliers = peak_time_multipliers
  end

  def price(date_time)
    peak_time_multiplier = @peak_time_multipliers.find { |peak_time| peak_time.day_of_week == date_time.wday }
    peak_time_multiplier.nil? ? @base_cost : @base_cost * peak_time_multiplier.multiplier
  end

  class PeakTimeMultiplier
    attr_reader :day_of_week, :multiplier

    def initialize(day_of_week, multiplier)
      @day_of_week = day_of_week
      @multiplier = multiplier
    end
  end
end
