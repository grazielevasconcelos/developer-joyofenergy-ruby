# frozen_string_literal: true

require 'spec_helper'

describe PricePlanComparatorController do
  include Rack::Test::Methods
  subject(:app) { described_class.new price_plan_service, account_service }

  let(:price_plan_1_id) { 'test-supplier' }
  let(:price_plan_2_id) { 'best-supplier' }
  let(:price_plan_3_id) { 'second-best-supplier' }
  let(:price_plan_service) { PricePlanService.new price_plans, electricity_reading_service }
  let(:electricity_reading_service) { ElectricityReadingService.new }
  let(:account_service) { AccountService.new 'meter-0' => price_plan_1_id }
  let(:price_plans) do
    [
      PricePlan.new(price_plan_1_id, nil, 10.0, nil),
      PricePlan.new(price_plan_2_id, nil, 1.0, nil),
      PricePlan.new(price_plan_3_id, nil, 2.0, nil)
    ]
  end

  describe '/price-plans/compare-all' do
    it 'returns 404 if there is no price plan associated with the meter' do
      get '/price-plans/compare-all/meter-1000'
      expect(last_response.status).to eq 404
    end

    context 'with all price plans' do
      let(:expected_response) do
        {
          PricePlanComparatorController::PRICE_PLAN_KEY => price_plan_1_id,
          PricePlanComparatorController::PRICE_PLAN_COMPARISON_KEY => {
            price_plan_2_id => 10.0,
            price_plan_3_id => 20.0,
            price_plan_1_id => 100.0
          }
        }
      end
      let(:readings) do
        [
          { 'time' => '2018-01-01T00:00:00.000Z', 'reading' => 15.0 },
          { 'time' => '2018-01-01T01:00:00.000Z', 'reading' => 5.0 }
        ]
      end

      it 'gets costs against all price plans response' do
        electricity_reading_service.store_readings('meter-0', readings)

        get '/price-plans/compare-all/meter-0'
        expect(JSON.parse(last_response.body)).to eq(expected_response)
      end

      it 'gets costs against all price plans' do
        electricity_reading_service.store_readings('meter-0', readings)

        get '/price-plans/compare-all/meter-0'
        expect(last_response.ok?).to be(true)
      end
    end
  end

  describe '/price-plans/recommend' do
    let(:readings) do
      [
        { 'time' => '2018-01-01T00:00:00.000Z', 'reading' => 35.0 },
        { 'time' => '2018-01-01T00:30:00.000Z', 'reading' => 3.0 }
      ]
    end
    let(:expected_response) do
      [
        { price_plan_2_id => 38.0 },
        { price_plan_3_id => 76.0 },
        { price_plan_1_id => 380.0 }
      ]
    end
    let(:expected_response_with_limit2) { [{ price_plan_2_id => 38.0 }, { price_plan_3_id => 76.0 }] }

    it 'returns no match if there is no meter with that meter id' do
      get '/price-plans/recommend/meter-1000'
      expect(last_response.status).to eq(404)
    end

    it 'recommends cheapest price plans for meter id without any limit response' do
      electricity_reading_service.store_readings('meter-0', readings)

      get '/price-plans/recommend/meter-0'
      expect(JSON.parse(last_response.body)).to eq(expected_response)
    end

    it 'recommends cheapest price plans for meter id without any limit' do
      electricity_reading_service.store_readings('meter-0', readings)

      get '/price-plans/recommend/meter-0'
      expect(last_response.ok?).to be(true)
    end

    it 'recommends cheapest price plans for meter id up to a limited number response' do
      electricity_reading_service.store_readings('meter-0', readings)

      get '/price-plans/recommend/meter-0?limit=2'
      expect(JSON.parse(last_response.body)).to eq(expected_response_with_limit2)
    end

    it 'recommends cheapest price plans for meter id up to a limited number' do
      electricity_reading_service.store_readings('meter-0', readings)

      get '/price-plans/recommend/meter-0?limit=2'
      expect(last_response.ok?).to be(true)
    end

    it 'recommends cheapest price plans for meter id, returning all if the limit is too big response' do
      electricity_reading_service.store_readings('meter-0', readings)

      get '/price-plans/recommend/meter-0?limit=5'
      expect(JSON.parse(last_response.body)).to eq(expected_response)
    end

    it 'recommends cheapest price plans for meter id, returning all if the limit is too big' do
      electricity_reading_service.store_readings('meter-0', readings)

      get '/price-plans/recommend/meter-0?limit=5'
      expect(last_response.ok?).to be(true)
    end
  end
end
