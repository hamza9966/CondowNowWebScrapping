require 'openssl'
require 'nokogiri'
require 'httparty'
require 'open-uri'
require 'net/http'
require 'json'



OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class BuildingsController < ApplicationController

  def index
    scrape_buidlings
  end

  def scrape_buidlings
    # doc = Nokogiri::HTML(URI.open('https://condonow.com/ModelSearchPublicAjax.aspx?ProjectId=4034&SearchText=&SortBy=Name&OrderBy=A&PrefKey=&IsOrderToggle=yes&tick=96476640530820000&favourite=N&IsOnlySoldOutVal=0&From=public&shBroker=&v=0.692429036472431&_=1607944008849'))

    no_of_pages = 1
    pure_title = []
    heading = Array.new
    for i in 1..no_of_pages
       docs = Nokogiri::HTML(URI.open("https://condonow.com/ProjectSearchAjax.aspx?SearchText=toronto&PageNo=#{i}&preferenceKey=city_City-Toronto,;salesstatus_;constructionstatus_;mlsdistrict_;neighbourhood_;occupancydate_;condoamenities_;commission_;pricerange_;pricepersqftrange_;promotion_;bedrooms_;bathrooms_;size_;depositamount_;walkscore_;transitscore_;producttype_;freetext_&DeveloperID=&tick=96461701140540000&ActualSize=1&LoadFPForProjects=True&latlng=&ProjectsList=&boundedLatLng=&SearchNeighbor=&RadiusSearch=&PointMarkerLatLng=&hdnRealtor=&IsPublic=True&rand11-11-2020&cityPreferenceKey=city_City-Toronto,&_=1607695019014"))
       raw_title = docs.css('.Info').css('.projTitle').css('.listviewTitleInfo').css('.projName').css('div.projectTitle').css('a.projects').text.delete "\r\n"
       raw_title.gsub!(/[^0-9A-Za-z]/, ' ')
       title = raw_title.split('      ')
       title.pop
       title.select! do |x|
         !x.empty?
       end
       title.each do |x|
         x.tr!(" ","-")
       end
       pure_title.push(title)
    end

    abc = []
    for i in 0..no_of_pages-1
      abc = pure_title[i]
      for p in 0...abc.count
        heading.push(abc.pop)
      end
      heading.pop
    end

    raw_building_overview = []
    raw_building_floor_plan_price = []
    raw_building_features_finishes = []


    heading.each do |x|
      begin
      raw_building_overview.push(Nokogiri::HTML(URI.open("https://condonow.com/"+x)))
      raw_building_floor_plan_price.push(Nokogiri::HTML(URI.open("https://condonow.com/"+x+"/Floor-Plan-Price")))
      raw_building_features_finishes.push(Nokogiri::HTML(URI.open("http://condonow.com/"+x+"/Features-Finishes")))
      rescue
        raw_building_features_finishes.push("")
        next
      end
    end


    for building in 0..raw_building_overview.count-1

      puts project_name = raw_building_overview[building].css('.publicContainer').css('#dvPreviewHeader').css('.projectName').text
      puts address = raw_building_overview[building].css('.publicContainer').css('#dvPreviewHeader').css('.address').text
      puts  developer = raw_building_overview[building].css('.publicContainer').css('#dvPreviewHeader').css('.subtitle').text
      puts  starting_and_ending_price = raw_building_overview[building].css('.publicContainer').css('#dvPreviewHeader').css('.h3').text
      puts   description = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblDescription').text
      puts number_of_stories = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblStoriesNumber').text
      puts number_of_suites = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblTotalUnits').text
      puts suite_starting_floor = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblSuitesStartingFloor').text
      puts number_of_suites = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblNumberofSuitesPerFloor').text
      puts floor_plan = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblFloorPlansshow').text
      puts suite_size = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblSuiteSize').text
      puts parking_price = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblParkingPrice').text
      puts ceiling_height = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblCeilingHeights').text
      puts price_per_sq_ft = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblPricesqftfrom').text
      puts locker_price = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblLockerPrice').text
      puts architech = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblArchitects').text
      puts interior_designer = raw_building_overview[building].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('.table').css('#ctl00_ContentPlaceHolder1_lblInteriorDesigners').text
      puts amenities = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_dvAmenities').text
      puts est_maintenance = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblEstimatedMaintenance').text
      puts locker_maintenance = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblLockerMaintenance').text
      puts parking_maintenance = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblParkingMaintenance').text
      puts est_property_tax = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblEstPropertytax').text
      puts maintenance_note = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblMaintenanceNotes').text
      puts est_occupancy = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblEstimatedOccupancy').text
      puts vip_launch = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblVIPSalesStartDate').text
      puts public_launch = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblPublicSalesStartDate').text
      puts total_min_deposit = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblTotalMinimumDeposit').text
      puts deposit_note = raw_building_overview[building].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblDepositNotes').text
      if raw_building_features_finishes[building] != ""
        puts  features =raw_building_features_finishes[building].css('#ctl00_ContentPlaceHolder1_divFeature').text
      else
        puts features = ""
      end
      abc = raw_building_floor_plan_price[building].text
      json_string = ""

      json_string = JSON.parse(abc.scan(/\[\{(.*?)\}\]/).to_s)

      if json_string.any?
        raw_floor_objects = json_string.last.last
        floor_objects =  raw_floor_objects.scan(/{(.*?)}/)
        text = ""
        array_of_text = []
        array_of_bedrooms = []
        array_of_bathroom = []
        floor_objects.each do |floor|
          temp_text = floor.last.index('text') + 7
          while floor.last[temp_text] != v
            text = text + floor.last[temp_text]
            temp_text = temp_text + 1
          end
          begin
            array_of_bedrooms.push(floor.last[floor.last.index('bedrooms') + 11])
          rescue
            array_of_bedrooms.push("")
            next
          end
          begin
            array_of_bathroom.push(floor.last[floor.last.index('bathrooms') + 12])
          rescue
            array_of_bathroom.push("")
            next
          end
          array_of_text.push(text)
          text = ""
        end
      end
      for i in 0..array_of_text.count
        puts array_of_text[i]
        # puts array_of_starting_price[i]
        puts array_of_bathroom[i]
        puts array_of_bedrooms[i]
      end
    end
    #   raw_floor_objects = json_string.last.last
    #   floor_objects =  raw_floor_objects.scan(/{(.*?)}/)
    #   text = ""
    #   array_of_text = []
    #   array_of_bedrooms = []
    #   array_of_bathroom = []
    #   floor_objects.each do |floor|
    #     temp_text = floor.last.index('text') + 7
    #     v = '\\'
    #     while floor.last[temp_text] != v
    #       text = text + floor.last[temp_text]
    #       temp_text = temp_text + 1
    #     end
    #     begin
    #       array_of_bedrooms.push(floor.last[floor.last.index('bedrooms') + 11])
    #     rescue
    #       array_of_bedrooms.push("")
    #       next
    #     end
    #     begin
    #       array_of_bathroom.push(floor.last[floor.last.index('bathrooms') + 12])
    #     rescue
    #       array_of_bathroom.push("")
    #       next
    #     end
    #     array_of_text.push(text)
    #     text = ""
    #   end
    # end
    # for i in 0..array_of_text.count
    #   puts array_of_text[i]
    #   # puts array_of_starting_price[i]
    #   puts array_of_bathroom[i]
    #   puts array_of_bedrooms[i]
    # end

  end



end


# raw_title = doc.css('.Info').css('.projTitle').css('.listviewTitleInfo').css('.projName').css('div.projectTitle').css('a.projects').text.delete "\r\n"
# developers = doc.css('.Info').css('.projTitle').css('.listviewTitleInfo').css('.projName').css('.devName').text.delete "\r\n"
# address = doc.css('.Info').css('.projInfo').css('#text').text.delete "\r\n"
# raw_building[1].css('.publicContainer').css('#dvPreviewHeader').text mmmmmmmmmmmmmm

# project_name = raw_building[0].css('.publicContainer').css('#dvPreviewHeader').css('.projectName').text
# address = raw_building[0].css('.publicContainer').css('#dvPreviewHeader').css('.address').text
# developer = raw_building[0].css('.publicContainer').css('#dvPreviewHeader').css('.subtitle').text
# starting_and_ending_price = raw_building[0].css('.publicContainer').css('#dvPreviewHeader').css('.h3').text
# description = raw_building[0].css('.DivBlock').text
# number_of_stories = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblStoriesNumber').text
# number_of_suites = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblTotalUnits').text
# suite_starting_floor = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblSuitesStartingFloor').text
# number_of_suites = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblNumberofSuitesPerFloor').text
# floor_plan = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblFloorPlansshow').text
# suite_size = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblSuiteSize').text
# parking_price = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblParkingPrice').text
# ceiling_height = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblCeilingHeights').text
# price_per_sq_ft = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblPricesqftfrom').text
# locker_price = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblLockerPrice').text
# architech = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblArchitects').text
# interior_designer = raw_building[0].css('.div-tabular-data').css('.col4').css('.DivBlock').css('.tabularData.noneResponsiveTable.SpecsTable').css('#ctl00_ContentPlaceHolder1_lblInteriorDesigners').text
# amenities = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_dvAmenities').text
# est_maintenance = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblEstimatedMaintenance').text
# locker_maintenance = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblLockerMaintenance').text
# parking_maintenance = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblParkingMaintenance').text
# est_property_tax = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblEstPropertytax').text
# maintenance_note = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblMaintenanceNotes').text
# est_occupancy = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblEstimatedOccupancy').text
# vip_launch = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblVIPSalesStartDate').text
# public_launch = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblPublicSalesStartDate').text
# total_min_deposit = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblTotalMinimumDeposit').text
# deposit_note = raw_building[0].css('.DivBlock').css('#ctl00_ContentPlaceHolder1_lblDepositNotes').text