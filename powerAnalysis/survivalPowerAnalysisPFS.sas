
*Macro to model candidate variables for model selection;
%macro powerAnalysisPFS(controlMedPFS, treatMedPFS, accrual,followup, pow=0.8, alph=0.05, numSide=2);

* determine the number of subjects per group needed;
proc power ;
      twosamplesurvival test=logrank
         GROUPMEDSURVTIMES = &controlMedPFS | &treatMedPFS
         accrualtime = &accrual
         followuptime = &followup
         power = &pow
		 alpha = &alph
         npergroup = .		 	
		sides= &numSide;
		ODS Output output=tmp;
   run;

   * select the output of interest and determine the total N and the hazard ratio that corresponds to the median PFS being assessed;
   data tmp2;
   set tmp;
   NTotal = NPerGroup*2;
   HazardRatio = MedSurvTime1/MedSurvTime2;
   keep
   Analysis Sides AccrualTime FollowUpTime Alpha MedSurvTime1 MedSurvTime2 NominalPower Power NPerGroup NTotal HazardRatio;
   run;

 * determine the number of events needed;
   proc power ;
      twosamplesurvival test=logrank
         GROUPMEDSURVTIMES = &controlMedPFS | &treatMedPFS
         accrualtime = &accrual
         followuptime = &followup
         power = &pow
		 alpha = &alph
         eventstotal = .
		sides= &numSide;
		ODS Output output=tmpEvents;
   run;

   * add the number of events to the results;
   data tmp3;
   set tmpEvents;
   NumEvents = EETotal;
   keep
   Analysis Sides AccrualTime FollowUpTime Alpha MedSurvTime1 MedSurvTime2 NominalPower Power NumEvents;
   run;

   data tmp4;
   set tmp2;
   set tmp3;
   run;

   proc print data = tmp4; run;

   *end the macro;
%mend powerAnalysisPFS;

* run macro;
%powerAnalysisPFS(controlMedPFS=8,treatMedPFS=10 12 14 16, pow=0.8,alph=0.1, numSide=1, accrual=23,followup=25)

