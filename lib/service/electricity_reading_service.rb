require_relative '../helpers/usage_interval'

class ElectricityReadingService
  def initialize(readings_store = nil)
    @readings_store = readings_store || {}
  end

  def getReadings(meter_id)
    @readings_store[meter_id]
  end

  def storeReadings(meter_id, readings)
    @readings_store[meter_id] ||= []
    @readings_store[meter_id].concat(readings)
  end

  def getPreviousWeek(meter_id)
    interval = UsageInterval.usageIntervalFromPreviousWeek
    readings = @readings_store[meter_id]

    readings.select { |item| interval.begin < item['time'] && interval.end > item['time'] }
  end
end
