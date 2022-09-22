# frozen_string_literal: true

require 'shale'
require 'shale/schema'
require 'shale/adapter/ox'
require 'shale/adapter/rexml'
require 'shale/schema/compiler/boolean'
require 'shale/schema/compiler/date'
require 'shale/schema/compiler/float'
require 'shale/schema/compiler/integer'
require 'shale/schema/compiler/string'
require 'shale/schema/compiler/time'
require 'shale/schema/compiler/value'
require 'shale/schema/xml_compiler'

RSpec.describe Shale::Schema::XMLCompiler do
  before(:each) do
    Shale.xml_adapter = Shale::Adapter::REXML
  end

  EX = <<~RUBY_COPYRIGHT
    require 'shale'

    class FuelPriceExceptionType < Shale::Mapper
      attribute :start_hour, Shale::Type::Time
      attribute :end_hour, Shale::Type::Time
      attribute :fuel_price, Shale::Type::Float

      xml do
        root 'FuelPriceExceptionType'
        namespace 'http://emkt.pjm.com/emkt/xml', 'mkt'

        map_attribute 'startHour', to: :start_hour
        map_element 'EndHour', to: :end_hour
        map_element 'FuelPrice', to: :fuel_price
      end
    end
    require 'shale'

    require_relative 'fuel_price_exception_type'

    class FuelPriceExceptionsSetType < Shale::Mapper
      attribute :fuel_price_exceptions, FuelPriceExceptionType, collection: true

      xml do
        root 'FuelPriceExceptionsSet'
        namespace 'http://emkt.pjm.com/emkt/xml', 'mkt'

        map_element 'FuelPriceExceptions', to: :fuel_price_exceptions
      end
    end
  RUBY_COPYRIGHT

  describe 'real world' do
    let(:schema) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <schema xmlns:mkt="http://emkt.pjm.com/emkt/xml" xmlns="http://www.w3.org/2001/XMLSchema" targetNamespace="http://emkt.pjm.com/emkt/xml" elementFormDefault="qualified" attributeFormDefault="unqualified">
          <element name="FuelPriceExceptionsSet" type="mkt:FuelPriceExceptionsSetType" minOccurs="0" maxOccurs="unbounded"/>
          <complexType name="FuelPriceExceptionsSetType">
            <sequence>
              <element name="FuelPriceExceptions" type="mkt:FuelPriceExceptionType" minOccurs="0" maxOccurs="unbounded"/>
            </sequence>
          </complexType>
          <complexType name="FuelPriceExceptionType">
            <sequence>
              <element name="EndHour" type="dateTime"/>
              <element name="FuelPrice" type="mkt:FuelPriceType"/>
            </sequence>
            <attribute name="startHour" type="dateTime" use="required"/>
          </complexType>
          <simpleType name="FuelPriceType">
            <restriction base="decimal">
              <totalDigits value="9"/>
              <fractionDigits value="4"/>
              <minInclusive value="0"/>
              <maxInclusive value="99999.9999"/>
            </restriction>
          </simpleType>
        </schema>
      XML
    end

    it 'asdf' do
      models = Shale::Schema.from_xml [schema]
      expect(EX).to eq(models.values.join(''))
    end
  end
end
