class DatsController < ApplicationController
  include DatsHelper
  
  before_action :set_dat, only: [:show, :edit, :update, :destroy]
  
  # GET /dats
  # GET /dats.json
  
  def create_template
  
  end
  
  
  
  
  def index
 
    #Conversion of ks2 to Expected Attainment 8
    
    ks2_e_a8 = {1.5=>13,1.6=>15, 1.7=>15,1.8=>15,1.9=>15,2.0=>15,2.1=>17,2.2=>17,2.3=>17,
    				   2.4=>17,2.5=>17,2.6=>19,2.7=>19,2.8=>19,2.9=>20,3.0=>21,3.1=>22,3.2=>23,3.3=>24,3.4=>25,3.5=>26,3.6=>28,3.7=>29,
    				   3.8=>31,3.9=>32,4.0=>34,4.1=>36,4.2=>38,4.3=>40,4.4=>42,4.5=>44,4.6=>47,4.7=>49,4.8=>51,4.9=>54,5.0=>56,5.1=>59,
    				   5.2=>61,5.3=>64,5.4=>66,5.5=>69,5.6=>72,5.7=>74,5.8=>76}
    				   
    # Points Score for different qualifications
    				   
    btec_score ={"PASS" => 5, "MERIT" => 6, "DISTINCTION" => 7, "DISTINCTION*" =>8}
    l2n_1_score ={"PASS" => 1.5, "MERIT" => 3, "DISTINCTION" => 4}
    l2n_2_score ={"PASS" => 5, "MERIT" => 6, "DISTINCTION" => 7, "DISTINCTION*" =>8}
    @grade_score = {"U" => 0, "G"=>1, "F"=>2, "E"=>3, "D"=>4, "C" => 5, "B" => 6, "A" => 7, "A*"=>8}
    
    @ks2_number = {"W"=> 0, "1C" => 1, "1B" => 2, "1A" => 3, "2C" => 4, "2B" => 5, "2A" => 6, "3C" => 7, "3B" => 8, "3A" => 9, "4C" => 10, "4B" => 11, "4A" => 12,  "5C" => 13, "5B" => 14,
    				"5A" => 15, "6C" => 16, "6B" => 17, "6A" => 18}
	
    # Basic details on each of the pupils
    
	details = ['Surname', 'Forename','PP' , 'SEN', 'EAL', 'English_KS2_fine', 'Maths_KS2_fine', 'English_KS2_grade', 'Maths_KS2_grade']
	@display_details = ['Surname', 'Forename','PP' , 'SEN', 'EAL', 'Exp A8', 'Eng KS2', 'Ma KS2','Avg KS2']
	json = File.read('public/data.json')
	data = JSON.parse(json)

		@students =[]
		data.each do |s|
			@student_data={}
			# Create arrays to store point scores for each section
			maths = []
			english = []
			english_lit = []
			ebacc = []
			other = []
			ks2_average = ((s['Maths_KS2_fine']+s['English_KS2_fine'])/2).round(1)
			ks2_grade_average = (@ks2_number[s['Maths_KS2_grade'].upcase] +  @ks2_number[s['English_KS2_grade'].upcase])/2
			s.each do |d|
				@student_data[d[0]]=d[1]
				if d[0] == 'Maths_KS2_fine'
					@student_data['Average KS2 Fine']=ks2_average
					@student_data['Expected Attainment 8']=  ks2_e_a8[ks2_average]
				end
				if d[0] == 'Maths_KS2_grade'
					@student_data['Average KS2']= @ks2_number.key(ks2_grade_average)
				end
				qual = check_subject(d[0].gsub(/-/, ' '))
				if qual !=false
					point_score = convert_grade_to_number(d[0].gsub(/-/, ' '),d[1])
					@student_data[d[0]+' Points Score'] = point_score
					if qual == 'maths'
						maths.push(point_score)
					elsif qual == 'english'
						english.push(point_score)
					elsif qual == 'english_lit'
						english_lit.push(point_score)
						other.push(point_score.to_i)
					elsif ['science','humanities','language'].include? qual
						ebacc.push(point_score.to_i)
					# The other lookup will need to be changed to level 1 and 2 etc
					elsif ['other'].include? qual
						other.push(point_score.to_i)
					end
				end
			end
			#Add the points scores to the main Hashes
			@student_data['Maths_Points_Score'] = maths.max
			@student_data['English_Points_Score'] = english.max
			@student_data['English_Literature_Points_Score'] = english_lit.max
			@student_data['Other Ebacc Subjects'] = ebacc = ebacc.sort.last(3).inject{|sum,x| sum + x }
			@student_data['Other Subjects'] =other = other.sort.last(3).inject{|sum,x| sum + x }
			if english_lit.max >0
			english = english.max * 2
			end
			#Calculate Attainment 8
			@student_data['Attainment 8'] = a8 =  (maths.max * 2) + english + ebacc + other
			@student_data['Progress 8'] = p8 =a8 - ks2_e_a8[ks2_average]
			@student_data['Value Added'] = (p8.to_f/10)
			@students << @student_data
		end
	
	

	
	

  end

  # GET /dats/1
  # GET /dats/1.json
  def show
  end

  # GET /dats/new
  def new
    @dat = Dat.new
  end

  # GET /dats/1/edit
  def edit
  end

  # POST /dats
  # POST /dats.json
  def create
    @dat = Dat.new(dat_params)

    respond_to do |format|
      if @dat.save
        format.html { redirect_to @dat, notice: 'Dat was successfully created.' }
        format.json { render :show, status: :created, location: @dat }
      else
        format.html { render :new }
        format.json { render json: @dat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dats/1
  # PATCH/PUT /dats/1.json
  def update
    respond_to do |format|
      if @dat.update(dat_params)
        format.html { redirect_to @dat, notice: 'Dat was successfully updated.' }
        format.json { render :show, status: :ok, location: @dat }
      else
        format.html { render :edit }
        format.json { render json: @dat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dats/1
  # DELETE /dats/1.json
  def destroy
    @dat.destroy
    respond_to do |format|
      format.html { redirect_to dats_url, notice: 'Dat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dat
      @dat = Dat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dat_params
      params[:dat]
    end
end
