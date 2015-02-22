module DatsHelper
	
	#Converts ks2 grade to score
	def convert_ks2_to_a_score(ks2)
		   
    				
    	return @ks2_number[ks2.upcase]
    				
	end
	
	# Chooses between maths,english and Average depending on subject
	def choose_ks2_measure(s,eng,ma,avg)
		if s && eng && ma && avg
			if check_subject(s) == 'MATHS'
				ks2 = ma
			elsif ['ENGLISH_LIT','ENGLISH_LANG', 'ENG_COMB'].include? check_subject(s)
				ks2 = eng
			else
				ks2 = avg
			end
		
			return convert_ks2_to_a_score(ks2)
		end
	end
	#Checks to see if pupil is in a group then returns a circle with a tick
	def check_group(g)
		if g == 'Y'
			content_tag(:i, '' ,class: 'fa fa-check-circle')
		else 
			return ""
		end
	end
	
	#Calculates value added from expected8 and 1 subjects points score
	def calculate_va(expected,ps)
		if expected && ps 
			return va = (ps - expected.to_f/10).round(1)
		end
	end
	
	# Checks highest score from english and english lit
	def calculate_highest_score_english(eng,eng_lit)
		if eng>eng_lit
			return eng
		else 
			return eng_lit
		end
	end
	
	def five_A_C(arr)
		maths_pupils = arr.select {|arr| arr['Maths_Points_Score'] >= 5}.count
		eng_pupils = arr.select {|arr| arr['English_Points_Score'] >= 5}.count
		pupils = arr.select {|arr| arr['Maths_Points_Score'] >= 5 && arr['English_Points_Score'] >= 5}.count
		content_tag(:table, class: 'table table-bordered text-center') do
			concat( content_tag(:tr) do 
				concat content_tag(:th, '', class: 'text-center')
				concat content_tag(:th, 'Maths', class: 'text-center')
				concat content_tag(:th, 'English', class: 'text-center')
				concat content_tag(:th, 'Combined Maths & English', class: 'text-center')
			end)
			concat( content_tag(:tr) do 
				concat content_tag(:th, 'Number of Pupils', class: 'text-center')
				concat content_tag(:td, maths_pupils)
				concat content_tag(:td, eng_pupils)
				concat content_tag(:td, pupils)
			end)
			concat( content_tag(:tr) do 
				concat content_tag(:th, 'Percentage of Pupils', class: 'text-center')
				concat content_tag(:td, (maths_pupils*100/arr.count).to_s+' %')
				concat content_tag(:td, (eng_pupils*100/arr.count).to_s+' %')
				concat content_tag(:td, (pupils*100/arr.count).to_s+' %')
			end)
		end
					
	end
	
	# Draws a summary table of the schools overview with pp, sen and EAL included
	def school_summary_table(arr)
		th = ['Expected Attainment 8','Maths Points Score','English Points Score','Other Ebacc Subjects','Other Subjects','Attainment 8','Progress 8']
		h = ['Expected Attainment 8','Maths_Points_Score','English_Points_Score','Other Ebacc Subjects','Other Subjects','Attainment 8','Value Added']
	 	m = ['na','PP','SEN','EAL']
	 	title = ['All Pupils','PP','SEN','EAL']
	 	i = 0
	 	content_tag(:table, class: 'table table-bordered text-center') do
			concat( content_tag(:tr) do 
				concat content_tag(:th)
				title.each { |t| concat content_tag(:th, t, class: 'text-center')}
			end)
			
			h.each do |h| 
				concat( content_tag(:tr) do 
					concat content_tag(:td,th[i])
					m.each { |m| concat content_tag(:td,calc_avg_school(arr,h,m),class: color_div_total(calc_avg_school(arr,h,m),calc_avg_school(arr,'Expected Attainment 8',m),h))}
				end)
				i+=1
			end
	 	end
	end
		
	#Provides color class for summary table
	def color_div_total(avg,ea8,symbol)
		if !ea8.blank? && !avg.blank? && !symbol.blank? && symbol != 'Expected Attainment 8'
			if ['Maths_Points_Score','English_Points_Score'].include? symbol 
				expected = (ea8.to_f/10)
				score = avg - expected 
				
			elsif ['Other Ebacc Subjects','Other Subjects'].include? symbol
				expected = (ea8.to_f/10)*3
				score = (avg - expected)/3 
				
			elsif ['Attainment 8','Progress 8','Value Added'].include? symbol
				if symbol == 'Attainment 8'
					score = (avg-ea8)/10
				elsif symbol == 'Progress 8'
					score = avg/10
				elsif symbol == 'Value Added'
					score = avg/10
				end
			end
			if score<-0.5
					color = 'black_color'
			elsif score<0
				color = 'below_color'
			elsif score <0.5
				color = 'one_below_color'
			elsif score <1
				color = 'on_track_color'
			elsif score >=1
				color = 'above_color'
			end
			return color
		end
	end
	
	
	def va_bar_color(a)
		if !a.blank?
			if a<-0.5
				color = '#777'
			elsif a<0
				color = '#d9534f'
			elsif a <0.5
				color = '#f0ad4e'
			elsif a <1
				color = '#5cb85c'
			elsif a >=1
				color = '#428bca'
			end
		end
	end
	
	#Create value added hash for statistical significance graph
	def create_va_hash(arr)
		title = ['na','PP','SEN','EAL']
		va_full_array=[]
		for h in title.reverse
		va_total = calc_avg_school(arr,'Value Added',h)
		if va_total
			ci = 1.96 * 1.14/ Math.sqrt(calc_number_pupils_school(@students,h))
			up_va_total = (va_total + ci).round(2)
			lo_va_total = (va_total - ci).round(2)
			va_hash = {:title => h == 'na' ? 'Whole School' : h ,:va => va_total,:up_va => up_va_total, :lo_va => lo_va_total}
			va_full_array.push(va_hash)
		end
		end
			
		return va_full_array
		
	end
	
	
	# Calculates average for group e.g. pp or sen for any column title
	def calc_avg_school(arr,title,group)
		if group == 'na'
			if arr.count > 0
				(arr.map{|x| x[title].to_f}.reduce(:+)/arr.count).round(2)
			end
		else
			pupils = arr.select {|arr| arr[group].upcase == 'Y'}
			if pupils.count > 0
				(pupils.map{|x| x[title].to_f}.reduce(:+)/pupils.count).round(2)
			end
		end
	end
	
	#Calculate number of pupils in group
	def calc_number_pupils_school(arr,group) 
		if group == 'na'
			if arr.count > 0 
				return arr.count
			else
				return 0
			end
		else
			pupils = arr.select {|arr| arr[group].upcase == 'Y'}
			if pupils.count > 0 
				return pupils.count
			else
				return 0
			end
			
		end
	end
	
	# Draws a summary table for each subject
	def draw_summary_table(class_name,qualification,arr)
		h = ['Measure','All Pupils','PP','SEN','EAL']
		m = ['all','PP','SEN','EAL']
		n = {'Levels of Progress' => 'lp', 'Points Score' => 'ps' , 'Progress 8 Score' => 'va'}
		content_tag(:table, class: 'table table-bordered') do
			concat( content_tag(:tr) do
			 h.each { |h| concat content_tag(:th, h)}
			 end)
			n.each do |n|
				concat( content_tag(:tr) do 
					concat content_tag(:td,n[0])
					m.each { |x| concat content_tag(:td, calculate_average_from_hash(class_name, qualification,x,arr,n[1]), class: color_class(calculate_average_from_hash(class_name, qualification,x,arr,n[1]),n[1]))}
				end)
			end
		end  
	
	end
	
	
	# Calculates number of pupils taking a certain qualification
	
	def number_of_pupils(qualification,arr)
		pupils = arr.select {|arr| !arr[qualification+'_Class'].blank?}.count
	end
	
	
	# Calulates average from a hash given the class name qualification the whole array group and what it needs to be an average of e.g. lp or points score
	def calculate_average_from_hash(class_name,qualification, group_name,arr,compare_data)
		if compare_data == 'lp'
			d = ' Levels of Progress'
		elsif compare_data == 'ps'
			d= ' Points Score'
		elsif compare_data == 'va'
			d= ' Value Added'
		end
		
		if class_name == 'subject'
			if group_name == 'all'
				pupils = arr.select {|arr| !arr[qualification+'_Class'].blank?}
			else 
				pupils = arr.select {|arr| arr[group_name].upcase == 'Y' && !arr[qualification+'_Class'].blank?}
			end	
		else
			if group_name == 'all'
				pupils = arr.select {|arr| arr[qualification+'_Class'].upcase == class_name.upcase }
			else 
				pupils = arr.select {|arr| arr[group_name].upcase == 'Y' && arr[qualification+'_Class'].upcase == class_name.upcase }
			end		
		end
		array = []
		if !pupils.blank?
			
			pupils.map{|x| x[qualification+d]}.each do |a|
				if !a.blank?
					array << a
				end
			end
			if array.count>0
				(array.reduce(:+)/array.count).round(2)	
			end	
			end
	end
	
	
	
	
	#Returns a color css class for ks2, ps,va,lp
		def color_class(avg,symbol)
		if !avg.to_s.blank?
			if symbol == 'a_g'
				if avg<95
					color = 'below_color'
				elsif avg<99
					color = 'one_below_color'
				elsif avg>=99
					color = 'on_track_color'
				end
			elsif symbol == 'a_c'
				if avg<50
					color = 'below_color'
				elsif avg<70
					color = 'one_below_color'
				elsif avg>=70
					color = 'on_track_color'
				end
			
			elsif symbol == 'a_a'
				if avg<10
					color = 'below_color'
				elsif avg<35
					color = 'one_below_color'
				elsif avg>35
					color = 'on_track_color'
				end
			
			elsif symbol == 'ks2'
				if avg < 4 
					color = 'below_color'
				elsif avg < 5
					color = 'one_below_color'
				elsif avg >= 5
					color = 'on_track_color'
				end
			elsif symbol == 'ps'
		
				if avg < 3 
					color = 'below_color'
				elsif avg < 5
					color = 'one_below_color'
				elsif avg < 7
					color = 'on_track_color'
				elsif avg >= 7 
					color = 'above_color'
				end
		
		
	
			elsif symbol == 'va'
				if avg<-0.5
					color = 'black_color'
				elsif avg<0
					color = 'below_color'
				elsif avg <0.5
					color = 'one_below_color'
				elsif avg <1
					color = 'on_track_color'
				elsif avg >=1
					color = 'above_color'
				else ''
				end
		
	
			elsif symbol =='lp'
					if avg<0
						color = 'black_color'
					elsif avg<3
						color = 'below_color'
					elsif avg <4
						color = 'one_below_color'
					elsif avg <5
						color = 'on_track_color'
					elsif avg >=5
						color = 'above_color'
					end
				else
				color = ""
			end
		end
		return color
	end
	
	
	# Averages an array
	def avg_arr(arr)
		if !arr.blank?
		array = arr.inject(0.0) { |sum, el| sum + el } / arr.size
		return array.round(1)
		
		else
		return ""
		end
	end

	
	def color_div_other(ps)
		if ps < 3 
			color = 'below_color'
		elsif ps < 5
			color = 'one_below_color'
		elsif ps < 7
			color = 'on_track_color'
		elsif ps >= 7 
			color = 'above_color'
		end
		html = ""
		html += color
    	html.html_safe
	end
	
	def color_div_va(va)
		if !va.kind_of? String 
			if va<-0.5
				color = 'black_color'
			elsif va<0
				color = 'below_color'
			elsif va <1
				color = 'one_below_color'
			elsif va <2
				color = 'on_track_color'
			elsif va >=2
				color = 'above_color'
			else ''
			end
			html = ""
			html = color
			html.html_safe
		end
	end
	
	def color_div_lp(lp)
		if !lp.to_s.blank?
			if lp<3
				color = 'below_color'
			elsif lp <4
				color = 'one_below_color'
			elsif lp <5
				color = 'on_track_color'
			elsif lp >=5
				color = 'above_color'
			end
			html = ""
			html = color
			html.html_safe
		
		end
		
	end
	
	# Select correct colour based on points score
	def color_div_ps(ps)
		if ps
			if ps < 3 
				color = 'below_color'
			elsif ps < 5
				color = 'one_below_color'
			elsif ps < 7
				color = 'on_track_color'
			elsif ps >= 7 
				color = 'above_color'
			end
			html = ""
			html += color
			html.html_safe
		end
	end
	
	
	#Takes info to calculate levels of progress made
	def calculate_levels_of_progess(eng_ks2, math_ks2, subject_title, point_score)
		if !eng_ks2.blank? && !math_ks2.blank?
		
			if subject_title.include? 'Points'
				subject = check_subject(subject_title[0..-14].gsub(/-/, ' '))
			else
				subject = check_subject(subject_title.gsub(/-/, ' '))
			end
			if subject == 'MATHS'
				ks2_score = convert_ks2_to_a_score(math_ks2)
			elsif ['ENGLISH_LANG','ENGLISH_LIT','ENG_COMB'].include? subject
				ks2_score = convert_ks2_to_a_score(eng_ks2)
			else
				eng = convert_ks2_to_a_score(eng_ks2)
				math = convert_ks2_to_a_score(math_ks2)
				if eng && math
					ks2_score = (eng+math)/2
				end
			end
			if point_score && ks2_score
				return (2+(point_score.to_f - ks2_score.to_f/3)).round(2)
			end
		end
	end


	# Convert the grade to the correct number 
	# This still needs adapting to cover the different level 1 and level 2 /BTEC Cambridge Nationals Scores
	
	def convert_grade_to_number(subject_title, grade)
		
		@grade_score = {"U" => 0, "G"=>1, "F"=>2, "E"=>3, "D"=>4, "C" => 5, "B" => 6, "A" => 7, "A*"=>8}
    	@P_L1 = {"PASS" => 2.5}
    	@three_L1 = {'A*' => 4, 'A' => 3, 'B' => 1.5,'U' => 0, "FAIL" => 0, "PASS" => 1.5, "MERIT" => 3, "DISTINCTION" => 4}
    	@four_L1 = {'A*' => 4, 'A' => 3, 'B' => 2, 'C' => 1, 'U' => 0, 'D' => 4, 'E' => 3, 'F' => 2, 'G' => 1}
    	@three_L2 = {"PASS" => 5, "MERIT" => 6.5, "DISTINCTION" => 7.5}
    	@four_L2 = {'A*' => 4, 'A' => 3, 'B' => 2, 'C' => 1, 'U' => 0, "FAIL" => 0, "PASS" => 5, "MERIT" => 6, "DISTINCTION" => 7, "DISTINCTION*" =>8}
    	@five_L2 = {'A' => 7, 'B' => 6.5, 'C' => 6, 'D' => 5.5, 'E' => 5, 'U' => 0}
    	@seven_L2 = {'PP' => 5, 'MP' => 5.5, 'MM' => 6, 'DM' => 6.5, 'DD' => 7, 'D*D' => 7.5, 'D*D*' => 8}
		if ['maths','english','english_lit','science','humanities','language'].include? check_subject(subject_title) 
		return @grade_score[grade.upcase]
		else 
			if check_other_subject(subject_title) == '3_L1'
				return @three_L1[grade.upcase]
			elsif check_other_subject(subject_title) == '4_L2'
				return @four_L2[grade.upcase]
			elsif check_other_subject(subject_title) == '4_L1'
				return @four_L1[grade.upcase]
			elsif check_other_subject(subject_title) == '5_L2'
				return @five_L2[grade.upcase]
			elsif check_other_subject(subject_title) == '8_L12'
				return @grade_score[grade.upcase]
			elsif check_other_subject(subject_title) == 'P_L1'
				return @P_L1[grade.upcase]
			elsif check_other_subject(subject_title) == '3_L2'
				return @three_L2[grade.upcase]
			elsif check_other_subject(subject_title) == '7_L2'
				return @seven_L2[grade.upcase]
			elsif check_other_subject(subject_title) == 'cn_l1'
				return @P_L1[grade.upcase]
			else
				
			end
		end
	end
	
	#Check other subjects, return grade structure code
	def check_other_subject(title)
		
		
		q = @qualifications.find {|x| x['Qualification Title'].upcase == title.upcase }
		
		if !q.blank?
			return q['Grade Scheme']
		end
		
		
	end
	
	# Check the subject 
	def check_subject(subject_title)
		
		
		q = @qualifications.find {|x| x['Qualification Title'].upcase == subject_title.upcase }
		
		if q 
			return q['Category']
		else
			return false
		end
	end
end
