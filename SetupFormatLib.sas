libname  R "H:\My Documents\Studies\Transfusions"; *sets up library location;
proc format library=R; *lets it know what library to put it in;
value $yesno '1'="Yes" '2'="No";
value $sex '1'="Male" '2'="Female";
value $race  '10'="White"
			'20'="Black or African American"
			'30'="American Indian or Alaska Native"
			'40'="Native Hawaiian or Other Pacific Islander"
			'50'="Asian"
			'70'="Unknown/Not Reported";

value $inout		'1'="Inpatient"
				'0'="Outpatient";
value $elective '1'='Yes'
				'2'="No"
				'3'="Unknown";
value $trans 	'1'="Not transferred (admitted from home)"
				'2'="From acute care hospital inpatient"
				'4'="Nursing home - Chronic care - Intermediate care"
				'6'="Transfer from other"
				'7'="Outside emergency department"
				'8'="Unknown";


value $surgspecialty	'50'="General Surgery"
						'62'="Vascular"
						'58'="Thoracic"
						'57'="Cardiac"
						'54'="Orthopedics"
						'52'="Neurosurgery"
						'59'="Urology"
						'55'="Otolaryngology (ENT)"
						'56'="Plastics"
						'51'="Gynecology"
						'81'="Other"
						'82'="Unknown";


value $woundclass	'1'="Clean"
					'2'="Clean/Contaminated"
					'3'="Contaminated"
					'4'="Dirty/Infected";
value $asaclass	'1'="ASA 1 - No Disturb"
				'3'="ASA 2 - Mild Disturb"
				'5'="ASA 3 - Severe Disturb"
				'7'="ASA 4 - Life Threat"
				'9'="ASA 5 - Moribund"
				'11'="ASA 6 - Brain Death"
				'0'="None assigned";

value $occurrence_post	'27'="Superficial Incisional SSI"
						'5'="Deep Incisional SSI"
						'32'="Organ/Space SSI"
						'31'="Wound Disruption"
						'20'="Pneumonia"
						'29'="Unplanned Intubation"
						'22'="Pulmonary Embolism"
						'13'="On Ventilator > 48 hours"
						'23'="Progressive Renal Insufficiency"
						'1'="Acute Renal Failure"
						'30'="Urinary Tract Infection"
						'26'="CVA"
						'4'="Coma > 24 hours"
						'19'="Peripheral Nerve Injury"
						'51'="Cerebral Vascular Accident (CVA)/Stroke or Intracranial Hemorrhage"
						'52'="Seizure"
						'53'="Nerve Injury"
						'61'="Grade 1"
						'62'="Grade 2"
						'63'="Grade 3"
						'64'="Grade 4"
						'65'="Unknown/Specific grade not documented"
						'3'="Cardiac Arrest Requiring CPR"
						'12'="Myocardial Infarction"
						'2'="Bleeding Requiring Transfusion (72h of surgery start time)"
						'8'="Graft/Prosthesis/Flap Failure"
						'6'="DVT Requiring Therapy"
						'28'="Sepsis"
						'34'="Septic Shock"
						'56'="Venous Thrombosis requiring Therapy"
						'57'="Postoperative Systemic Sepsis"
						'58'="Central-Line Associated Bloodstream Infection"
						'40'="Other (list ICD 9 code)" ;
run;
*In programs using these formats, use the following statement to set up the library;
*libname library "H:\My Documents\Studies....;


