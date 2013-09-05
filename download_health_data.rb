require 'rest_client'
require 'mongo'
require 'xmlsimple'
require 'date'
require 'sinatra'
require 'chartkick'
require 'erb'
require 'pp'
require 'nokogiri'


include Mongo

class DownloadHealthInspections

	def initialize
		
		# MongoDB client and DB credential information
		@client = MongoClient.new('localhost', 27017)
		@db = @client['HealthInspections']
		@coll = @db['Inspections']
		
		# Clears out the collection - Primarly used for Testing/Debug but has production reasons as well
		@coll.remove

		# Class variable for the initial Rest Client Call that grabs listing of Restaurants in the downloadHealthListXML method
		@noResults = false


		self.downloadHealthListXML

	end

	def downloadHealthListXML
		
		# Class variable for keeping track of the pagination of Restaurant listings
		@count = 0
		
		# Runs until the @Count value is greater than the @numFound value found in the parsedXML value in the parseHelathListXML method
		while @noResults == false  do
		   response = RestClient.get 'http://app06.ottawa.ca/cgi-bin/search/inspections/q.pl?ss=results_en&qt=fsi_s&sq_app_id=fsi&sq_keywords=&sq_field=fname&sq_fs_ftcd=&sq_fs_fwcd=&sort=fs_fnm+asc%2Cscore+desc&cookie=t&start=' + @count.to_s
	   
		   #Count is incremented by 15 for each pass through the loop becuase the Restraunt Site will provide a max of 15 results at a time
		   @count += 15
		   
		   # Debug Code for showing the current @count value
		   puts "Count: #{@count}"

		   self.parseHealthListXML(response)
		end
	end

	def parseHealthListXML(xmlData)
		parsedXML = XmlSimple.xml_in(xmlData, { 'KeyAttr' => 'name', 'ContentKey' => '-content'} )
		if @count >= parsedXML["result"][0]["numFound"].to_i + 15
			puts "All results returned"
			@noResults=true
		else
			self.processHealthList(parsedXML)
		end

	end

	def processHealthList(dataToParse)
		healthList = dataToParse["result"][0]["doc"]
		healthList.each do |y|
			response = RestClient.get 'http://app06.ottawa.ca/cgi-bin/search/inspections/q.pl?ss=details_en&cookie=t&sq_fs_fdid=' + y["str"]["fs_fdid"]
			self.parseHealthRecordSingle(response)
		end 
	end




	# TODO Add comments for xml parsing loops and structure
	# TODO Refactor visual of code for better readability
	# TODO Benchmark and time test parse and look for optimizations
	# TODO Rename Variables for better understanding and less similar names
	# TODO 
	def parseHealthRecordSingle(healthRecord)
  		puts healthRecord
		parsedXML = Nokogiri::XML(healthRecord)
		#puts parsedXML
		#selectAllEnglishInspectionData = "response/result/doc/arr[@name='fs_insp_en']//*"
		
		# Restaurant/Facility Information/Details
		inspValue_app_id = parsedXML.xpath("string(response/result/doc/str[@name='app_id'])")
		inspValue_fs_fa_en = parsedXML.xpath("string(response/result/doc/str[@name='fs_fa_en'])")
		inspValue_fs_fa_fr = parsedXML.xpath("string(response/result/doc/str[@name='fs_fa_fr'])")
		inspValue_fs_facd = parsedXML.xpath("string(response/result/doc/str[@name='fs_facd'])")
		inspValue_fs_faid = parsedXML.xpath("string(response/result/doc/str[@name='fs_faid'])")
		inspValue_fs_fcr = parsedXML.xpath("string(response/result/doc/str[@name='fs_fcr'])")
		
		if parsedXML.xpath("string(response/result/doc/str[@name='fs_fcr_date'])") != ""
			inspValue_fs_fcr_date = DateTime.strptime(parsedXML.xpath("string(response/result/doc/str[@name='fs_fcr_date'])")[0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
		else
			inspValue_fs_fcr_date = nil
		end

		inspValue_fs_fdid = parsedXML.xpath("string(response/result/doc/str[@name='fs_fdid'])")
		
		if parsedXML.xpath("string(response/result/doc/str[@name='fs_fefd'])") != ""
			inspValue_fs_fefd = DateTime.strptime(parsedXML.xpath("string(response/result/doc/str[@name='fs_fefd'])")[0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
		else
			inspValue_fs_fefd = nil
		end

		inspValue_fs_fnm = parsedXML.xpath("string(response/result/doc/str[@name='fs_fnm'])")
		inspValue_fs_fsc = parsedXML.xpath("string(response/result/doc/str[@name='fs_fsc'])")
		inspValue_fs_fsd = parsedXML.xpath("string(response/result/doc/str[@name='fs_fsd'])")
		inspValue_fs_fsf = parsedXML.xpath("string(response/result/doc/str[@name='fs_fsf'])")
		inspValue_fs_fsp_en = parsedXML.xpath("string(response/result/doc/str[@name='fs_fsp_en'])")
		inspValue_fs_fsp_fr = parsedXML.xpath("string(response/result/doc/str[@name='fs_fsp_fr'])")
		inspValue_fs_fspc = parsedXML.xpath("string(response/result/doc/str[@name='fs_fspc'])")
		inspValue_fs_fspcd = parsedXML.xpath("string(response/result/doc/str[@name='fs_fspcd'])")
		inspValue_fs_fsph = parsedXML.xpath("string(response/result/doc/str[@name='fs_fsph'])")
		inspValue_fs_fspid = parsedXML.xpath("string(response/result/doc/str[@name='fs_fspid'])")
		inspValue_fs_fss = parsedXML.xpath("string(response/result/doc/str[@name='fs_fss'])")
		inspValue_fs_fst = parsedXML.xpath("string(response/result/doc/str[@name='fs_fst'])")
		inspValue_fs_fstcd = parsedXML.xpath("string(response/result/doc/str[@name='fs_fstcd'])")
		inspValue_fs_fstic = parsedXML.xpath("string(response/result/doc/str[@name='fs_fstic'])")
		inspValue_fs_fstid = parsedXML.xpath("string(response/result/doc/str[@name='fs_fstid'])")
		
		if parsedXML.xpath("string(response/result/doc/str[@name='fs_fstlu'])") != ""
			inspValue_fs_fstlu = DateTime.strptime(parsedXML.xpath("string(response/result/doc/str[@name='fs_fstlu'])")[0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
		else
			inspValue_fs_fstlu = nil
		end

		inspValue_fs_fsun = parsedXML.xpath("string(response/result/doc/str[@name='fs_fsun'])")
		inspValue_fs_ft_en = parsedXML.xpath("string(response/result/doc/str[@name='fs_ft_en'])")
		inspValue_fs_ft_fr = parsedXML.xpath("string(response/result/doc/str[@name='fs_ft_fr'])")
		inspValue_fs_ftcd = parsedXML.xpath("string(response/result/doc/str[@name='fs_ftcd'])")
		inspValue_fs_ftcd_en = parsedXML.xpath("string(response/result/doc/str[@name='fs_ftcd_en'])")
		inspValue_fs_ftcd_fr = parsedXML.xpath("string(response/result/doc/str[@name='fs_ftcd_fr'])")
		inspValue_fs_ftid = parsedXML.xpath("string(response/result/doc/str[@name='fs_ftid'])")
		inspValue_fs_fw_en = parsedXML.xpath("string(response/result/doc/str[@name='fs_fw_en'])")
		inspValue_fs_fw_fr = parsedXML.xpath("string(response/result/doc/str[@name='fs_fw_fr'])")
		inspValue_fs_fwcd = parsedXML.xpath("string(response/result/doc/str[@name='fs_fwcd'])")
		inspValue_fs_fwcd_en = parsedXML.xpath("string(response/result/doc/str[@name='fs_fwcd_en'])")
		inspValue_fs_fwcd_fr = parsedXML.xpath("string(response/result/doc/str[@name='fs_fwcd_fr'])")
		inspValue_fs_fwid = parsedXML.xpath("string(response/result/doc/str[@name='fs_fwid'])")
		inspValue_fs_insp_sort = parsedXML.xpath("string(response/result/doc/str[@name='fs_insp_sort'])")
		inspValue_id = parsedXML.xpath("string(response/result/doc/str[@name='id'])")
		

		# Gets the number of <inspection> fields in the xml for the loop
		facilityInspectionCount = parsedXML.xpath("count(response/result/doc/arr[@name='fs_insp_en']/inspection)").to_i
	


		# loops through each <inspection> tag
		if facilityInspectionCount != 0 
			
			facilityInspections ={}
			
			(1..facilityInspectionCount).each do |i|
				

			   
				facilityinspectionData_inspectionid = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/@inspectionid)")
				facilityinspectionData_facilitydetailid = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/@facilitydetailid)")
				facilityinspectionData_inspectiondate = DateTime.strptime(parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/@inspectiondate)")[0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
				facilityinspectionData_isincompliance = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/@isincompliance)")
				facilityinspectionData_closuredate = DateTime.strptime(parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/@closuredate)")[0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
				facilityinspectionData_reportnumber = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/@reportnumber)")

				# gets the number of <question> fields in the xml for use in the loop
				facilityInspectionQuestionCount = parsedXML.xpath("count(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question)").to_i
				
				if facilityInspectionQuestionCount != 0

					inspectionQuestions = {}

					# Collect Question data - loops through each question
					(1..facilityInspectionQuestionCount).each do |qc|

						facilityinspectionData_QuestionData_sort = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/@sort)")
						facilityinspectionData_QuestionData_complianceresultcode = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/@complianceresultcode)")
						facilityinspectionData_QuestionData_complianceresulttext = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/@complianceresulttext)")
						facilityinspectionData_QuestionData_risklevelid = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/@risklevelid)")
						facilityinspectionData_QuestionData_riskleveltext = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/@riskleveltext)")
						facilityinspectionData_QuestionData_compliancecategorycode = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/@compliancecategorycode)")
						facilityinspectionData_QuestionData_compliancecategorytext = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/@compliancecategorytext)")
						facilityinspectionData_QuestionData_compliancedescriptioncode = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/@compliancedescriptioncode)")

						# qtext value
						facilityinspectionData_QuestionData_qtext = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/qtext)")

						facilityInspectionQuestionCommentCount = parsedXML.xpath("count(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/comment)").to_i
						
						if facilityInspectionQuestionCommentCount != 0

							# Hash to hold each of the comments for each of the questions for each of the inspections
							inspectionQuestionComments = {}

							# Collect Comment Data - loops through each comment field in the xml of each question field of each inspection
							(1..facilityInspectionQuestionCommentCount).each do |qcc|

								facilityinspectionData_QuestionDataCommentText = parsedXML.xpath("string(response/result/doc/arr[@name='fs_insp_en']/inspection[#{i}]/question[#{qc}]/comment[#{qcc}])")
								inspectionQuestionComments['comment_' + qcc.to_s] = facilityinspectionData_QuestionDataCommentText
							end
						end
										# Add Question text and question details 
						inspectionQuestions['question_' + qc.to_s] = {	'Sort' => facilityinspectionData_QuestionData_sort, 
																		'ComplianceResultCode'  => facilityinspectionData_QuestionData_complianceresultcode,
																		'ComplianceResultText' => facilityinspectionData_QuestionData_complianceresulttext,
																		'RiskLevelId' => facilityinspectionData_QuestionData_risklevelid,
																		'RiskLevelText' => facilityinspectionData_QuestionData_riskleveltext,
																		'ComplianceCategoryCode' => facilityinspectionData_QuestionData_compliancecategorycode,
																		'ComplianceCategoryText' => facilityinspectionData_QuestionData_compliancecategorytext,
																		'ComplianceDescriptionCode' => facilityinspectionData_QuestionData_compliancedescriptioncode,
																		'QuestionText' => facilityinspectionData_QuestionData_qtext,
																		'InspectionQuestionComments' => inspectionQuestionComments
																	}
						if facilityInspectionQuestionCommentCount == 0
							inspectionQuestions['question_' + qc.to_s].delete('InspectionQuestionComments')
						end
					end
				end

				facilityInspections['inspection_' + i.to_s] = {
													'InspectionId' => facilityinspectionData_inspectionid,
													'FacilityDetailId' => facilityinspectionData_facilitydetailid,
													'InspectionDate' => facilityinspectionData_inspectiondate,
													'IsInCompliance' => facilityinspectionData_isincompliance,
													'ClosureDate' => facilityinspectionData_closuredate,
													'ReportNumber' => facilityinspectionData_reportnumber,
													'InspectionQuestionDetails' => inspectionQuestions
												}
				if facilityInspectionQuestionCount == 0 
					facilityInspections['inspection_' + i.to_s].delete('InspectionQuestionDetails')
				end
			end
		end
		# Hash that holds all of the details for the specific facility
		facilityDetails = {
							'app_id' => inspValue_app_id,
							'fs_fa_en' => inspValue_fs_fa_en,
							'fs_fa_fr' => inspValue_fs_fa_fr,
							'fs_facd' => inspValue_fs_facd,
							'fs_faid' => inspValue_fs_faid,
							'fs_fcr' => inspValue_fs_fcr,
							'fs_fcr_date' => inspValue_fs_fcr_date,
							'fs_fdid' => inspValue_fs_fdid,
							'fs_fefd' => inspValue_fs_fefd,
							'fs_fnm' => inspValue_fs_fnm,
							'fs_fsc' => inspValue_fs_fsc,
							'fs_fsd' => inspValue_fs_fsd,
							'fs_fsf' => inspValue_fs_fsf,
							'fs_fsp_en' => inspValue_fs_fsp_en,
							'fs_fsp_fr' => inspValue_fs_fsp_fr,
							'fs_fspc' => inspValue_fs_fspc,
							'fs_fspcd' => inspValue_fs_fspcd,
							'fs_fsph' => inspValue_fs_fsph,
							'fs_fspid' => inspValue_fs_fspid,
							'fs_fss' => inspValue_fs_fss,
							'fs_fst' => inspValue_fs_fst,
							'fs_fstcd' => inspValue_fs_fstcd,
							'fs_fstic' => inspValue_fs_fstic,
							'fs_fstid' => inspValue_fs_fstid,
							'fs_fstlu' => inspValue_fs_fstlu,
							'fs_fsun' => inspValue_fs_fsun,
							'fs_ft_en' => inspValue_fs_ft_en,
							'fs_ft_fr' => inspValue_fs_ft_fr,
							'fs_ftcd' => inspValue_fs_ftcd,
							'fs_ftcd_en' => inspValue_fs_ftcd_en,
							'fs_ftcd_fr' => inspValue_fs_ftcd_fr,
							'fs_ftid' => inspValue_fs_ftid,
							'fs_fw_en' => inspValue_fs_fw_en,
							'fs_fw_fr' => inspValue_fs_fw_fr,
							'fs_fwcd' => inspValue_fs_fwcd,
							'fs_fwcd_en' => inspValue_fs_fwcd_en,
							'fs_fwcd_fr' => inspValue_fs_fwcd_fr,
							'fs_fwid' => inspValue_fs_fwid,
							'fs_insp_sort' => inspValue_fs_insp_sort,
							'id' => inspValue_id,
							'FacilityInspections' => facilityInspections
							
						}

		if facilityInspectionCount == 0
			facilityDetails.delete('FacilityInspections')
		end

		puts '***** Facility Hash ******'
		puts pp facilityDetails
		puts '*********END**************'
		
		self.putHealthXMLinMongo(facilityDetails)
	end

	def putHealthXMLinMongo(mongoPayload)
		@coll.insert(mongoPayload)
	end
end


# TODO rebuild Queries because of new data structure
class AnalyzeHealthInspectionData

	def initialize
		# MongoDB client and DB credential information
		@client = MongoClient.new('localhost', 27017)
		@db = @client['HealthInspections']
		@coll = @db['Inspections']
	
	end

	def analyzeRestaurantNameCount
		return restaurantNameCount = @coll.aggregate([
		    { "$project" => {doc:{str:{fs_fnm: 1}}}},
		    { "$group" => {_id: "$doc.str.fs_fnm", number: { "$sum" => 1 }}},
		    { "$sort" => {"_id" => 1 }}
		])
	end

	def analyzeRestaurantCategoryCount
		restaurantCategoryCount = @coll.aggregate([
		    { "$project" => {doc:{str:{fs_ft_en: 1}}}},
		    { "$group" => {_id: "$doc.str.fs_ft_en", number: { "$sum" => 1 }}},
		    { "$sort" => {"_id" => 1 }}
		])
		
		# TODO clean up hash creation code with better namming
		newHash={}
		restaurantCategoryCount.each do |x|

			newHash[x["_id"][0]] = x["number"]

		end
		return newHash

	end

	def analyzeRestaurantStreetCount
		return restaurantStreetCount = @coll.aggregate([
		    { "$project" => {doc:{str:{fs_fss: 1}}}},
		    { "$group" => {_id: "$doc.str.fs_fss", number: { "$sum" => 1 }}},
		    { "$sort" => {"_id" => 1 }}
		])
	end

	def analyzeRestaurantCreationDateCount
		return restaurantCreationDateCount = @coll.aggregate([
		    { "$project" => {doc:{str:{fs_fcr_date: 1}}}},
		    { "$group" => {_id: "$doc.str.fs_fcr_date", number: { "$sum" => 1 }}},
		    { "$sort" => {"_id" => 1 }}
		])
	end

	def analyzeRestaurantsCreatedPerMonth
		return restaurantsCreatedPerMonth = @coll.aggregate([
		    { "$project" => {created_month: {"$month" => "$doc.str.fs_fcr_date"}}},
		    { "$group" => {_id: {"created_month" => "$doc.str.fs_fcr_date"}, number: { "$sum" => 1 }}},
		    { "$sort" => {"_id.created_month" => 1}}
		])

	end



	def produceChart(data)

		values = []
		legend = []

		data.each do |x|
			legend.push(x["_id"][0])
			values.push(x["number"])
		end

			return chartURL = Gchart.bar(:title => "Event Types",
        	:data => values, 
        	#:bar_colors => 'FF0000,267678,FF0055,0800FF,00FF00',
        	:stacked => false, :size => '500x900',
        	:legend => legend)
	end




end


class MyApp < Sinatra::Base



  get '/' do

    @foo = 'erb23'
    analyze = AnalyzeHealthInspectionData.new
    #@values = analyze.analyzeRestaurantsCreatedPerMonth.to_s
    @pie = pie_chart(analyze.analyzeRestaurantCategoryCount)
    @bar = line_chart(analyze.analyzeRestaurantCategoryCount)
  	@column = column_chart(analyze.analyzeRestaurantCategoryCount)


    erb :index
  end
end




start = DownloadHealthInspections.new
#analyze = AnalyzeHealthInspectionData.new
#MyApp.run!
#puts "************************************************** Restarant Name Count:"
#puts analyze.analyzeRestaurantNameCount
#puts "************************************************** Restarant Category Count:"
#puts analyze.analyzeRestaurantCategoryCount

#puts "************************************************** Restarant Category Created Per Month Count:"
#puts analyze.analyzeRestaurantsCreatedPerMonth

#puts analyze.produceChart(analyze.analyzeRestaurantCategoryCount)

#puts "************************************************** Restarants Per Street Count:"
#puts analyze.analyzeRestaurantStreetCount
#puts "************************************************** Restarants Creation Date Count:"
#puts analyze.analyzeRestaurantCreationDateCount
#dog = analyze.analyzeRestaurantCategoryCount