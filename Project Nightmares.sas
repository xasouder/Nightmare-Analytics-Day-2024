libname stat3120 'C:\Users\star-\Data Science\SAS stuff\SAS code\analytics day 2024';
PROC IMPORT datafile = "C:\Users\star-\Data Science\SAS stuff\SAS code\analytics day 2024\nightmare_dataset.csv"
dbms = csv
out = stat3120.nightmares replace;
getnames = yes;
RUN;

/*creates the nightmare dataset that has some added variables so that I dont touch the original one
it not used and inefficient, but I did not have time to combine this and night_cat*/
Data nightmare;
set stat3120.nightmares;
if gender = 'Male' then gender_binary = 1;
if gender = 'Female' then gender_binary = 0;
RUN;

/*creates the night_cat dataset which is what I work on for a majority of the project*/
Data nightmare_cat;
set nightmare;
if nightmare_content = 'Alone and Lost' then night_cat = 8;
if nightmare_content = 'Animals attacking' then night_cat = 2;
if nightmare_content = 'Being Chased' then night_cat = 1;
if nightmare_content = 'Darkness Fears' then night_cat = 11;
if nightmare_content = 'Dead or Dying' then night_cat = 10;
if nightmare_content = 'Falling from Edge' then night_cat = 6;
if nightmare_content = 'Falling from Height' then night_cat = 6;
if nightmare_content = 'Fire Burning' then night_cat = 7;
if nightmare_content = 'Losing Body Parts' then night_cat = 10;
if nightmare_content = 'Losing Control' then night_cat = 8;
if nightmare_content = 'Losing Someone' then night_cat = 10;
if nightmare_content = 'Monster Under Bed' then night_cat = 5;
if nightmare_content = 'Monster in Room' then night_cat = 5;
if nightmare_content = 'Natural Disaster' then night_cat = 7;
if nightmare_content = 'Parental Slap Fear' then night_cat = 2;
if nightmare_content = 'Parents Fights' then night_cat = 3;
if nightmare_content = 'Scary Place Fear' then night_cat =11;
if nightmare_content = 'School Test Failure' then night_cat = 8;
if nightmare_content = 'Trapped in Space' then night_cat = 4;
if nightmare_content = 'Unknown' then night_cat = 12;
if nightmare_content = 'Water Drowning' then night_cat = 6;
if nightmare_content = 'Zombie Attack' then night_cat = 5;
if nightmare_content = 'loud noises' then night_cat = 11;
/*removes an outlier of age and nightmare content*/
if age = 24  then delete; 
if nightmare_content = "bedwetting" then delete;
Run;
/*adjust night_cat dataset to workable values that I send the glm through*/
Data nightmare_cat;
set nightmare_cat;
/*Narrows the usable categories in nightmare content and recent life changes with a focus on aged 7 and greater*/
if night_cat ne 5 AND night_cat ne 12 AND night_cat ne 11 AND night_cat ne 1
AND night_cat ne 2  AND night_cat ne 7 then
	sig_night_cat = 1;
else 
	sig_night_cat = 0;

if Recent_Life_changes ne "No recent changes" AND Recent_Life_changes ne "Started daycare" 
AND Recent_Life_changes ne "Starting kindergarten" then 
	life_num = 1;
else 
	life_num = 0;

if sig_night_cat = 1 AND LIFE_NUM = 1 AND age >=7 then output;
RUn;

/*used to check if setting the life num and night cat variables went through*/
PRoc freq data = nightmare_cat;
tables recent_life_changes*life_num;
Run;
/* shows the category assigned to each nightmare and the amount present*/
PRoc freq data = nightmare_cat;
tables nightmare_content*night_cat;
Run;
PRoc freq data = nightmare_cat;
tables nightmare_content*recent_life_changes;
by sig_night_cat;
Run;


*GLM creates the model for the multiple linear regression with the univariate assessing residuals (broken currently though);
PROC GLM data = nightmare_cat;
*can handle continuous and categorical variables;
 class gender recent_life_changes nightmare_content;
 *class has categorical variables;
 model Psychological_Problems_at_School = recent_life_changes nightmare_content gender/ solution;
 *if it is 0 it is the reference group;
 output out=stdres_MLR p=predict student=resids rstudent=rstudent_val;
 *outputting residuals;
 lsmeans recent_life_changes / pdiff=all adjust=tukey cl;
 lsmeans nightmare_content / pdiff=all adjust=tukey cl;
 *least squared means, pdiff = pairwise differences for all the level of programs, 
 tukey is comparisons, stat adjustment of inflation of type one error rate;
run; quit;
/*plots the residuals*/
PROC UNIVARIATE data=stdres_MLR cibasic (alpha=.05) normal plot;
var resids;
RUN;
PROC SGPLOT data=stdres_MLR;
    SCATTER x=Predict y=resids ;
    
    REFLINE 0 / AXIS=y;
RUN;

/*chi square test showing the correlation between different variables*/
PROC FREQ data=nightmare_cat;
tables gender*recent_life_changes* Psychological_Problems_at_School/ chisq expected cellchi2;
RUN;
PROC FREQ data=nightmare_cat;
tables gender*recent_life_changes/ chisq expected cellchi2;
RUN;
PROC FREQ data=nightmare_cat;
tables gender*nightmare_content/ chisq expected cellchi2;
RUN;
PROC FREQ data=nightmare_cat;
tables gender*nightmare_content* Psychological_Problems_at_School/ chisq expected cellchi2;
RUN;

/*Citation*/
/*Robert, G., & Zadra, A. (2014). Thematic and content analysis of idiopathic nightmares and Bad dreams.
Sleep, 37(2), 409–417. https://doi.org/10.5665/sleep.3426 ?*/


