/*==============================*/
/* Project: RESPOND    			*/
/* Author: Ryan O'Dea  			*/ 
/* Created: 12/16/2022 			*/
/* Updated: NA         			*/
/*==============================*/

/*==============================*/
/*  	GLOBAL VARIABLES   		*/
/*==============================*/

/*===========YEARS==============*/
%LET year = 2020

/*===========AGE================*/
%LET max_age = 90;
%LET min_age = 10;

PROC FORMAT;
	VALUE age_grps
		low-10 = '999'
		11-20 = '2'
		21-30 = '3'
		31-40 = '4'
		41-50 = '5'
		51-60 = '6'
		61-70 = '7'
		71-80 = '8'
		81-90 = '9'
		91-high = '999';

/*========ICD CODES=============*/
%LET ICD = ('30400', '30401', '30402', '30403',
            '30470', '30471', '30472', '30473',
            '30550', '30551', '30552', '30553',
            'E8500', 'E8501', 'E8502', '96500',
            '96501', '96502', '96509', '9701', /* ICD9 */
            'F1120', 'F1121', 'F1110', 'F11120',
            'F11121', 'F11122', 'F11129', 'F1114',
            'F11150', 'F11151', 'F11159', 'F11181',
            'F11182', 'F11188', 'F11190', 'F1119',
            'F11220', 'F11221', 'F11222', 'F11229',
            'F1123', 'F1124', 'F11250', 'F11251',
            'F11259', 'F11281', 'F11282', 'F11288',
            'F1129', 'F1190', 'F11920', 'F11921',
            'F11922', 'F11929', 'F11913', 'F11914',
            'F1193', 'F1194', 'F11950', 'F11951',
            'F11959', 'F11981', 'F11982', 'F11989',
            'F1199', 'F1110', 'F1111', /* Additional for HCS */
            'F1113', 'H0047', 'J0592', 'G2068',
            'G2069', 'G2070', 'G2071', 'G2072',
            'G2073', 'G2079', 'J0570', 'J0571',
            'J0572', 'J0573', 'J0574', 'J0575', /* Additional for Bup */
            'H0020', 'G2067', 'G2078', 'S0109',
            'J1230', 'HZ91ZZZ', 'HZ81ZZZ', '9464', /* Additional for Methedone */
            'T40.0X1A', 'T40.0X2A', 'T40.0X3A', 'T40.0X4A',
            'T40.0X1D', 'T40.0X2D', 'T40.0X3D', 'T40.0X4D',
            'T40.1X1A', 'T40.1X2A', 'T40.1X3A', 'T40.1X4A',
            'T40.1X1D', 'T40.1X2D', 'T40.1X3D', 'T40.1X4D',
            'T40.2X1A', 'T40.2X2A', 'T40.2X3A', 'T40.2X4A',
            'T40.2X1D', 'T40.2X2D', 'T40.2X3D', 'T40.2X4D', 
			'T40.3X1A', 'T40.3X2A', 'T40.3X3A', 'T40.3X4A', 
			'T40.3X1D', 'T40.3X2D', 'T40.3X3D', 'T40.3X4D', 
			'T40.4X1A', 'T40.4X2A', 'T40.4X3A', 'T40.4X4A', 
			'T40.4X1D', 'T40.4X2D', 'T40.4X3D', 'T40.4X4D',
			'T40.601A', 'T40.601D', 'T40.602A', 'T40.602D', 
			'T40.603A', 'T40.603D', 'T40.604A', 'T40.604D', 
			'T40.691A', 'T40.692A', 'T40.693A', 'T40.694A', 
			'T40.691D', 'T40.692D', 'T40.693D', 'T40.694D', /* T codes */
			'E8500', 'E8501', 'E8502', /* Principle Encodes */
			'G2067', 'G2068', 'G2069', 'G2070', 
			'G2071', 'G2072', 'G2073', 'G2074', 
			'G2075', /* MAT Opioid */
			'G2076', 'G2077', 'G2078', 'G2079', 
			'G2080', 'G2081', /*Opioid Trt */
 			'J0570', 'J0571', 'J0572', 'J0573', 
 			'J0574', 'J0575', 'J0592', 'S0109', 
            'G2215', 'G2216', 'G1028' /* Naloxone */);

%LET bsas_drugs = (5,6,7,21,22,23,24);
            
/*===============================*/            
/*			DATA PULL			 */
/*===============================*/ 

/*======DEMOGRAPHIC DATA=========*/
PROC SQL;
	CREATE TABLE demographics AS
	SELECT DISTINCT ID, FINAL_RE, FINAL_SEX
	FROM PHDSPINE.DEMO;
QUIT;

/*======DEMOGRAPHIC DATA=========*/
PROC SQL;
	CREATE TABLE demographics AS
	SELECT DISTINCT ID, FINAL_RE, FINAL_SEX
	FROM PHDSPINE.DEMO;
QUIT;

/*=========APCD DATA=============*/
DATA apcd (KEEP = ID oud_apcd age_apcd agegrp_apcd, year);

/* OUD Identification */
	SET PHDAPCD.MEDICAL (KEEP = ID MED_ENCODE MED_ADM_DIAGNOSIS MED_AGE
								MED_ICD_PROC1-MED_ICD_PROC7
								MED_ICD1-MED_ICD25
								MED_FROM_DATE_YEAR)
						WHERE = (MED_FROM_DATE_YEAR = &year);
	cnt_oud_apcd = 0;
	oud_apcd = 0;
	year =  MED_FROM_DATE_YEAR;
	ARRAY vars1 {*} ID MED_ENCODE MED_ADM_DIAGNOSIS
					MED_ICD_PROC1-MED_ICD_PROC7
					MED_ICD1-MED_ICD25;
		DO i = 1 TO dim(vars1);
		IF vars1[i] in &ICD
		THEN cnt_oud_apcd = cnt_oud_apcd+1;
		END;
		DROP i;
	IF cnt_oud_apcd > 0 THEN oud_apcd = 1;
	IF oud_apcd = 0 THEN DELETE;
	
/* Age */ 
	IF MED_AGE < &min_age OR MED_AGE > &max_age THEN DELETE;
	age_apcd = MED_AGE;
	agegrp = put(age_apcd, age_grps.);
RUN;

PROC SQL;
	CREATE TABLE apcd AS
	SELECT DISTINCT ID, oud_apcd, agegrp
	FROM apcd;
QUIT;

/*======CASEMIX DATA==========*/
/* ED */
DATA casemix_ed (KEEP = ID oud_cm_ed ED_ID);
	SET PHDCM.ED (KEEP = ID ED_DIAG1 ED_PRINCIPLE_ECODE ED_ADMIT_YEAR)
				  WHERE = (ED_ADMIT_YEAR = &year);
	IF ED_DIAG1 in &ICD OR ED_PRINCIPLE_ENCODE in &ICD
	THEN oud_cm_ed = 1;
	ELSE oud_cm_ed = 0;
RUN;

PROC SQL;
	CREATE TABLE casemix_ed AS
	SELECT DISTINCT ID oud_cm_ed ED_ID
	FROM casemix_ed;
QUIT;

/* ED_DIAG */
DATA casemix_ed_diag (KEEP = oud_cm_ed_diag ED_ID);
	SET PHDCM.ED_DIAG (KEEP = ED_ID ED_DIAG ED_ADMIT_YEAR)
					   WHERE = (ED_ADMIT_YEAR = &year);
	IF ED_DIAG in &ICD
	THEN oud_cm_ed_diag = 1;
	ELSE oud_cm_ed_diag = 0;
RUN;

PROC SQL;
	CREATE TABLE casemix_ed_diag AS
	SELECT DISTINCT oud_cm_ed_diag ED_ID
	FROM casemix_ed_diag;
QUIT;

/* ED_PROC */
DATA casemix_ed_proc (KEEP = oud_cm_ed_proc ED_ID);
	SET PHDCM.ED_PROC (KEEP = ED_ID ED_PROC);
	IF ED_PROC in &ICD
	THEN oud_cm_ed_proc = 1;
	ELSE oud_cm_ed_proc = 0;
RUN;

PROC SQL;
	CREATE TABLE casemix_ed_proc AS
	SELECT DISTINCT oud_cm_ed_proc ED_ID
	FROM casemix_ed_proc;
QUIT;

/* CASEMIX MERGE */
PROC SQL;
	CREATE TABLE casemix AS 
	SELECT *
	FROM casemix_ed
	LEFT JOIN casemix_ed_diag ON casemix_ed.ED_ID = casemix_ed_diag.ED_ID
	LEFT JOIN casemix_ed_proc ON casemix_ed_diag.ED_ID = casemix_ed_proc.ED_ID;
QUIT;

DATA casemix (KEEP = ID oud_casemix);
	SET casemix (KEEP = ID oud_cm_ed_proc oud_cm_ed_diag oud_cm_ed);
	IF SUM(oud_cm_ed_proc, oud_cm_ed_diag, oud_cm_ed) > 0
	THEN oud_ed = 1;
	ELSE oud_ed = 0;
	
	IF oud_casemix = 0 THEN DELETE;
RUN;

PROC SQL;
	CREATE TABLE casemix AS
	SELECT DISTINCT ID, oud_casemix
	FROM casemix;
QUIT;

/* HD DATA */
DATA hd (KEEP = ID oud_hd);
	SET PHDCM.HD (KEEP = ID HD_DIAG1 HD_PROC1 HD_ADMIT_YEAR);
					WHERE (HD_ADMIT_YEAR = &year);
	IF HD_DIAG1 in &ICD OR HD_PROC1 in &ICD
	THEN oud_hd_raw = 1;
	ELSE oud_hd_raw = 0;
RUN;

PROC SQL;
	CREATE TABLE hd AS
	SELECT DISTINCT ID, oud_hd_raw
	FROM hd;
QUIT;

/* HD DIAG DATA */
DATA hd_diag (KEEP = ID oud_hd_diag);
	SET PHDCM.HD_DIAG (KEEP = ID HD_DIAG HD_ADMIT_YEAR);
						WHERE (HD_ADMIT_YEAR &=year);
	IF HD_DIAG in &ICD
	THEN oud_hd_diag = 1;
	ELSE oud_hd_diag = 0;
RUN;

PROC SQL;
	CREATE TABLE hd_diag AS
	SELECT DISTINCT ID, oud_hd_diag
	FROM hd_diag;
QUIT;

/* HD MERGE */
PROC SQL;
	CREATE TABLE hd AS 
	SELECT *
	FROM hd
	LEFT JOIN hd_diag ON hd.ID = hd_diag.ID;
QUIT;

DATA hd (KEEP = ID, oud_hd);
	SET hd;
	IF SUM(oud_hd_diag, oud_hd_raw) > 0
	THEN oud_hd = 1;
	ELSE oud_hd = 0;
	
	IF oud_hd = 0 THEN DELETE;
RUN;

/* OO */
DATA oo (KEEP = ID oud_oo);
    SET PHDCM.OO (KEEP = ID OO_DIAG1-6 OO_PROC1-4 OO_ADMIT_YEAR
                    WHERE = (OO_ADMIT_YEAR = &year));
    ARRAY vars2 {*} OO_DIAG1-6 OO_PROC1-4;
        DO k = 1 TO dim(vars2);
        IF vars2[k] IN &ICD
        THEN oud_oo = 1;
        ELSE oud_oo = 0;
RUN;

PROC SQL;
    CREATE TABLE oo AS
    SELECT DISTINCT ID, oud_oo 
    FROM oo;
QUIT;

/* MERGE ALL CM */
PROC SQL;
    CREATE TABLE casemix AS
    SELECT *
    FROM casemix
    FULL JOIN hd ON casemix.ID = hd.ID
    FULL JOIN  ON hd.ID = oo.ID
QUIT;

DATA casemix (KEEP = ID oud_casemix);
    SET casemix;
    IF sum(oud_ed, oud_hd, oud_oo) > 0 
    THEN oud_casemix = 1;
    ELSE oud_casemix = 0;
    IF oud_casemix = 0 THEN DELETE;
RUN;

/* BSAS */
DATA bsas (KEEP = ID oud_bsas);
    SET PHDBSAS.BSAS (KEEP = ID CLT_ENR_OVERDOSES_LIFE
                             CLT_ENR_PRIMARY_DRUG
                             CLT_ENR_SECONDARY_DRUG
                             CLT_ENR_TERTIARY_DRUG
                             PDM_PRV_SERV_CAT,
                             ENR_YEAR_BSAS
                      WHERE = (ENR_YEAR_BSAS = &year));
    IF (CLT_ENR_OVERDOSES_LIFE > 0 AND CLT_ENR_OVERDOSES_LIFE ^= 999)
        OR CLT_ENR_PRIMARY_DRUG in &bsas_drugs
        OR CLT_ENR_SECONDARY_DRUG in &bsas_drugs
        OR CLT_ENR_TERTIARY_DRUG in &bsas_drugs
        OR PHD_PRV_SERV_CAT = 7
    THEN oud_bsas = 1;
    ELSE oud_bsas = 0;
    IF oud_bsas = 0 THEN DELETE;
RUN;

PROC SQL;
    CREATE TABLE bsas AS
    SELECT DISTINCT ID, oud_bsas
    FROM bsas;
QUIT;

/* MATRIS */
DATA matris (KEEP = ID oud_matris);
SET PHDEMS.MATRIS (KEEP = ID OPIOID_ORI_MATRIS
                          OPIOID_ORISUBCAT_MATRIS
                          inc_year_matris
                    WHERE = (inc_year_matris = &year));
    IF OPIOID_ORI_MATRIS = 1 
        OR OPIOID_ORISUBCAT_MATRIS in (1-5)
    THEN oud_matris = 1;
    ELSE oud_matris = 0;
    IF oud_matris = 0 THEN DELETE;
RUN;

PROC SQL;
    CREATE TABLE matris AS
    SELECT DISTINCT ID, oud_matris
    FROM matris;
QUIT;

/* DEATH */
DATA death (KEEP = ID oud_death);
    SET PHDDEATH.DEATH (KEEP = ID OPIOID_DEATH YEAR_DEATH
                        WHERE = (YEAR_DEATH = &year));
    IF OPIOID_DEATH = 1 THEN oud_death = 1;
    ELSE oud_death = 0;
    IF oud_death = 0 THEN DELETE;
RUN;

PROC SQL;
    CREATE TABLE death AS
    SELECT DISTINCT ID, oud_death 
    FROM death;
QUIT;

/* PMP */
DATA pmp (KEEP = ID oud_pmp);
    SET PHDPMP.PMP (KEEP = ID BUPRENORPHINE_PMP, date_filled_year
                    WHERE = (date_filled_year = &year));
    IF BUPRENORPHINE_PMP = 1 
    THEN oud_pmp = 1;
    ELSE oud_pmp = 0;
    IF oud_pmp = 0 THEN DELETE;
RUN;

PROC SQL;
    CREATE TABLE pmp AS
    SELECT DISTINCT ID, oud_pmp
    FROM pmp;
QUIT;

/*===========================*/
/*      MAIN MERGE           */
/*===========================*/

PROC SQL;
    CREATE TABLE oud AS
    SELECT * FROM demographics
    LEFT JOIN apcd ON apcd.ID = demographics.ID
    LEFT JOIN casemix ON casemix.ID = apcd.ID
    LEFT JOIN bsas ON bsas.ID = casemix.ID
    LEFT JOIN matris ON matris.ID = bsas.ID
    LEFT JOIN death ON death.ID = matris.ID
    LEFT JOIN pmp ON pmp.ID = death.ID;
QUIT;

DATA oud;
    SET oud (KEEP = ID, agegrp, FINAL_RE, FINAL_SEX);
    oud_cnt = sum(oud_apcd, oud_casemix, oud_death, oud_matris, oud_pmp);
    IF oud_cnt > 0 
    THEN oud_master = 1;
    ELSE oud_master = 0;
    IF oud_master = 0 THEN DELETE;
RUN;

ODS CSV FILE = cat(%year, "_OUDCount.csv");
PROC SQL;
    CREATE TABLE oud_stratified AS
    SELECT DISTINCT *
    IFN(COUNT(DISTINCT ID) > 0 AND COUNT(DISTINCT ID) < 11, 
    -1,
    COUNT(DISTINCT ID) AS N_ID_RSA)
    FROM oud
    GROUP BY agegrp, FINAL_RE, FINAL_SEX;
ODS CSV CLOSE;