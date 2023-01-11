/*==============================================*/
/* Project: RESPOND    			                */
/* Author: Ryan O'Dea  			                */ 
/* Created: 12/26/2022 		                	*/
/* Updated: NA         			                */
/* Purpose: Fatality Counts, stratified by OUD  */
/*==============================================*/

/*==============DEATH COUNT=====================*/
DATA death (KEEP= ID oud_death year);
    SET PHDDEATH.DEATH (KEEP= ID OPIOID_DEATH YEAR_DEATH);
    IF OPIOID_DEATH = 1 
    THEN oud_death = 1;
    ELSE oud_death = 0;
    
    year = YEAR_DEATH;
RUN;

PROC SQL;
    CREATE TABLE oud_death AS
    SELECT DISTINCT ID, oud_death, year
    FROM death;
QUIT;

PROC SQL;
    CREATE TABLE death AS
    SELECT oud_death, count(distinct(ID)) as N_ID, year
    FROM oud_death
    GROUP BY oud_death, year;
QUIT;

PROC EXPORT DATA = death
	OUTFILE = "/sas/data/DPH/OPH/PHD/FOLDERS/SUBSTANCE_USE_CODE/RESPOND/RESPOND UPDATE/DeathCount.csv"
	DBMS = csv;
RUN;