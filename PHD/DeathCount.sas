/*==============================================*/
/* Project: RESPOND    			                */
/* Author: Ryan O'Dea  			                */ 
/* Created: 12/26/2022 		                	*/
/* Updated: NA         			                */
/* Purpose: Fatality Counts, stratified by OUD  */
/*==============================================*/

/*==============================================*/
/*  	    GLOBAL VARIABLES     	            */
/*==============================================*/

/*================YEARS=========================*/
%LET year = 2020;

/*==============DEATH COUNT=====================*/
DATA death (keep = ID, oud_death);
    SET PHDDEATH.DEATH (keep = ID OPIOID_DEATH YEAR_DEATH
                            where = (YEAR_DEATH = &year));
    IF OPIOID_DEATH = 1 
    THEN oud_death = 1;
    ELSE oud_death = 0;
RUN;

PROC SQL;
    CREATE TABLE oud_death AS
    SELECT DISTINCT ID, oud_death
    FROM death;
QUIT;

ODS CSV FILE = cat(%year, "_DeathCount.csv");
PROC SQL;
    CREATE TABLE death AS
    SELECT oud_death, count(distinct(ID)) as N_ID
    GROUP BY oud_death;
QUIT;
ODS CSV CLOSE;