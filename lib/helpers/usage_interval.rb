require 'date'

class UsageInterval
  def initialize(date)
    day_of_the_week = date.cwday
    @end = date - day_of_the_week
    @begin = @end - 7
  end

  def self.usageIntervalFromPreviousWeek(date = Date.today)
    UsageInterval.new date
  end

  def begin
    @begin.to_time.to_i
  end

  def end
    @end.to_time.to_i
  end
end
