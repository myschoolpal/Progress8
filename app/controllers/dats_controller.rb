class DatsController < ApplicationController
  before_action :set_dat, only: [:show, :edit, :update, :destroy]

  # GET /dats
  # GET /dats.json
  def index
    ks2_e_a8 = {1.5=>13,1.6=>15, 1.7=>15,1.8=>15,1.9=>15,2.0=>15,2.1=>17,2.2=>17,2.3=>17,
    				   2.4=>17,2.5=>17,2.6=>19,2.7=>19,2.8=>19,2.9=>20,3.0=>21,3.1=>22,3.2=>23,3.3=>24,3.4=>25,3.5=>26,3.6=>28,3.7=>29,
    				   3.8=>31,3.9=>32,4.0=>34,4.1=>36,4.2=>38,4.3=>40,4.4=>42,4.5=>44,4.6=>47,4.7=>49,4.8=>51,4.9=>54,5.0=>56,5.1=>59,
    				   5.2=>61,5.3=>64,5.4=>66,5.5=>69,5.6=>72,5.7=>74,5.8=>76}
    btec_score ={"PASS" => 5, "MERIT" => 6, "DISTINCTION" => 7, "DISTINCTION*" =>8}
    l2n_1_score ={"PASS" => 1.5, "MERIT" => 3, "DISTINCTION" => 4}
    l2n_2_score ={"PASS" => 5, "MERIT" => 6, "DISTINCTION" => 7, "DISTINCTION*" =>8}
    @grade_number = {"U" => 0, "G"=>1, "F"=>2, "E"=>3, "D"=>4, "C" => 5, "B" => 6, "A" => 7, "A*"=>8}
	details = ['Surname', 'Forename', 'English_KS2_fine', 'Maths_KS2_fine', 'English_KS2_grade', 'Maths_KS2_grade']
	ma_eng = ['Maths_Class', 'Maths_Result', 'English_Language_Class', 'English_Language_Result', 'English_Literature_Class', 'English_Literature_Result']
	ebacc = ['Core_Science_Class', 'Core_Science_Result', 'Additional_Science_Class', 'Additional_Science_Result', 'Biology_Class', 'Biology_Result', 'Chemistry_Class',
			'Chemistry_Result', 'Physics_Class', 'Physics_Result', 'Geography_Class', 'Geography_Result', 'History_Class', 'History_Result']
	voc = ['Art_Design_BTEC_level2_Class','Art_Design_BTEC_level2_Result']
	json = File.read('public/data.json')
	data = JSON.parse(json)

	@ks2_number = {"1C" => 1, "1B" => 2, "1A" => 3, "2C" => 4, "2B" => 5, "2A" => 6, "3C" => 7, "3B" => 8, "3A" => 9, "4C" => 10, "4B" => 11, "4A" => 12,  "5C" => 13, "5B" => 14,  "5A" => 15, "6C" => 16, "6B" => 17, "6A" => 18}
	
	
	@keys = []
	@subject_names =[]
	data[0].keys.each do |k|
		@keys << k
		if k.upcase.include? "CLASS"
			@subject_names << k
		end
	end
	details_c = @keys & details
	ma_eng_c = @keys & ma_eng
	ebacc_c = @keys & ebacc
	voc_c = @keys & voc
	
	
	
	
	d = []		
	for j in 0..data.length-1
		d[j] = {}
		num = ""
		num_ebacc = ""
		num_other =""
		for i in 0..details_c.length-1			
			if details_c[i].upcase == "ENGLISH_KS2_FINE"
				ks2_maths_fine = data[j][details_c[i]].to_f
				d[j].merge! details_c[i] => data[j][details_c[i]].to_f
			elsif details_c[i].upcase == "MATHS_KS2_FINE"
				ks2_eng_fine = data[j][details_c[i]].to_f
				d[j].merge! details_c[i] => data[j][details_c[i]].to_f
			else
				data[j][details_c[i]]
				d[j].merge! details_c[i] => data[j][details_c[i]]
			end
		end
		if ks2_maths_fine && ks2_eng_fine
			average_ks2_fine=((ks2_maths_fine+ks2_eng_fine)/2).round(1)
			d[j].merge! "average_ks2_fine" =>  average_ks2_fine
		end

		for i in 0..ma_eng_c.length-1
			grade = data[j][ma_eng_c[i]]
			d[j].merge! ma_eng_c[i] => data[j][ma_eng_c[i]]
			num = @grade_number[grade]
			if ma_eng_c[i] == "Maths_Result"
				maths_num = num 
			end
			if ma_eng_c[i] == "English_Language_Result"
				eng_lang_num = num 
			end
			if ma_eng_c[i] == "English_Literature_Result"
				eng_lit_num = num 
			end
		end

		ebacc_num = []
		for i in 0..ebacc_c.length-1
			grade = data[j][ebacc_c[i]]
			d[j].merge! ebacc_c[i] => data[j][ebacc_c[i]]
			if num_ebacc = @grade_number[grade]
				num_ebacc
			end
			if num_ebacc
				ebacc_num.push(num_ebacc)
			end
		end

		other_num = []
		for i in 0..voc_c.length-1
			grade = data[j][voc_c[i]]
			d[j].merge! voc_c[i] => data[j][voc_c[i]]
			if grade
				if btec_score[grade.upcase]
					if voc_c[i].upcase.include? "L2N"
						if  voc_c[i].upcase.include? "LEVEL1"
							num_other = l2n_1_score[grade.upcase]
						elsif voc_c[i].upcase.include? "LEVEL2"
							num_other = l2n_2_score[grade.upcase]
						end
					elsif voc_c[i].upcase.include? "BTEC"
						if  voc_c[i].upcase.include? "LEVEL1"
							if grade.upcase.include? "PASS"
								num_other = 2
							end
						elsif voc_c[i].upcase.include? "LEVEL2"
							num_other = btec_score[grade.upcase]
						end
					end
				else
					 num_other = @grade_number[grade]
				end
			end
			num_other						
			if num_other
				other_num.push(num_other.to_i)
			end	
		end
		maths_part = maths_num*2
		d[j].merge! "maths8" => maths_part	
		if eng_lang_num && eng_lit_num
			eng_part = 2*([eng_lang_num, eng_lit_num].max)
			d[j].merge! "english8" => eng_part
		elsif eng_lang_num
			eng_part = eng_lang_num
			d[j].merge! "english8" => eng_part
		end
		second_part = ebacc_num.sort.last(3).inject{|sum,x| sum + x }	
		d[j].merge! "ebacc8" => second_part 
		if eng_lit_num
			other_num.push(eng_lit_num)
		end
		third_part = other_num.sort.last(3).inject{|sum,x| sum + x }
		d[j].merge! "other8" => third_part 
		expect_a8=ks2_e_a8[average_ks2_fine]
		d[j].merge! "expected_a8" => expect_a8	 
		attainment8 = (maths_part + eng_part + second_part + third_part).to_f
		attainment8
		d[j].merge! "attainment8" => attainment8		
		 if attainment8 && expect_a8
			progress8 =attainment8-expect_a8
			d[j].merge! "progress8" => progress8	
		 end
		if progress8
			va = progress8/10
			d[j].merge! "va" => va	
		end		
	end

	@data =d
	

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
