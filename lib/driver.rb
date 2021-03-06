require 'csv'
require_relative 'csv_record'

VALID_STATUS = [:AVAILABLE, :UNAVAILABLE]

module RideShare
  class Driver < CsvRecord

    attr_reader :name, :vin, :status, :trips

    def initialize(
        id:,
        name:,
        vin:,
        status: :AVAILABLE,
        trips: []
    )

      super(id)
      @name = name
      @vin = vin
      @status = status
      @trips = trips

      unless @vin.length == 17
        raise ArgumentError, "Invalid vehicle identification number"
      end

      raise ArgumentError, "Invalid driver status" if !VALID_STATUS.include?(@status)
    end

    def add_trip(trip)
      @trips << trip
    end

    def average_rating
      return 0 if @trips.empty?

      all_ratings = @trips.map(&:rating).compact  # array of all Driver ratings; compact removes nil values.

      return all_ratings.sum.to_f / all_ratings.length
    end

    def total_revenue
      return 0 if @trips.length == 0

      cost = @trips.map(&:cost).compact

      return 0 if cost.sum < 1.65

      fee = cost.length * 1.65
      return (cost.sum - fee) * 0.8
    end

    def start_trip(trip)
      raise ArgumentError, "Driver #{@id} is not available." if @status != :AVAILABLE

      @status = :UNAVAILABLE

      self.add_trip(trip)
    end

    private

    def self.from_csv(record)
      return new(
          id: record[:id],
          name: record[:name],
          vin: record[:vin],
          status: record[:status].to_sym
      )
    end
  end
end