WITH baa_resp AS ( -- BAA resp measures for B1
    SELECT
        sub_id AS ID6,
        'BAA' AS from_study,
        'B1' AS timepoint,
        RVFMean,
        RVFDev
    FROM BAA.resp_mes
    WHERE sub_task = 'B1'
),
baa_hrv AS ( -- BAA HRV measures for B1
    SELECT
        sub_id AS ID6,
        RRIMin, RRImax, RRImean,
        RRIRmssd, RRIPnn50, RRIDev,
        RRICvs, HRMin, HRMax, HRMean,
        HRDev, RRISTot, RRISUlf, RRISVlf,
        RRISLf, RRISHf, RRISLfHF,
        RRISnLf, RRISnHf, RRI, RRIWMean
    FROM BAA.HEART_RATE
    WHERE sub_task = 'B1'
),
-- combine BAA HRV for B1
BAA_combined AS (
    SELECT
        h.ID6,
        'BAA' AS from_study,
        'B1' AS timepoint,
        h.RRIMin, h.RRImax, h.RRImean,
        h.RRIRmssd, h.RRIPnn50, h.RRIDev,
        h.RRICvs, h.HRMin, h.HRMax, h.HRMean,
        h.HRDev, h.RRISTot, h.RRISUlf, h.RRISVlf,
        h.RRISLf, h.RRISHf, h.RRISLfHF,
        h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM baa_hrv h
    LEFT JOIN baa_resp r ON h.ID6 = r.ID6
    
    union
        SELECT
        h.ID6,
        'BAA' AS from_study,
        'B1' AS timepoint,
        h.RRIMin, h.RRImax, h.RRImean,
        h.RRIRmssd, h.RRIPnn50, h.RRIDev,
        h.RRICvs, h.HRMin, h.HRMax, h.HRMean,
        h.HRDev, h.RRISTot, h.RRISUlf, h.RRISVlf,
        h.RRISLf, h.RRISHf, h.RRISLfHF,
        h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM baa_hrv h
    RIGHT JOIN baa_resp r ON h.ID6 = r.ID6
),
-- CGE HRV and resp measures together for B1
CGE_hrv as ( -- CGE HRV measures for B1
select
ID as ID6,
'CGE' as from_study,
'B1' as timepoint,
RRIMin, RRImax,RRImean,RRIRmssd,
RRIPnn50,RRIDev,RRICvs,HRMin,
HRMax, HRMean, HRDev, RRISTot,
RRISUlf, RRISVlf, RRISLf, RRISHf,
RRISLfHF, RRISnLf, RRISnHf, RRI,
RRIWMean
FROM CGE.Import_physio
where 
session = 1 and VAR216 = 'B1'
),
-- CGE resp measures for B1
CGE_resp as (
SELECT
sub_id as ID6,
'CGE' as from_study,
'B1' as timepoint,
RVFMean,
RVFDev
FROM CGE.RESP_mes
where session = 1 AND sub_task = 0
),
-- combine CGE HRV and resp for B1
CGE_combined AS (
SELECT
h.ID6,
'CGE' AS from_study,
'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
r.RVFMean, r.RVFDev
FROM CGE_hrv h
LEFT JOIN CGE_resp r ON h.ID6 = r.ID6
union
SELECT
h.ID6,
'CGE' AS from_study,
'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
r.RVFMean, r.RVFDev
FROM CGE_hrv h
RIGHT JOIN CGE_resp r ON h.ID6 = r.ID6
),
-- Stress_pic HRV data for B1
stress_pic_hrv as (
select
sub_id as ID6,
'stress_pic' as from_study,
'B1' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
from
stress_pic.HRV
where sub_task = 'B1' and session = 1
),
stress_pic_resp as (
SELECT
sub_id as ID6,
'stress_pic' as from_study,
'B1' as time_point,
RVFMean,
RVFDev
FROM stress_pic.resp_mes
where sub_task = 'B1' and session = 1
),
-- stress_pic combined
stress_pic_combined AS (
    SELECT
        h.ID6,
        'stress_pic' AS from_study,
        'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM stress_pic_hrv h
    LEFT JOIN stress_pic_resp r ON h.ID6 = r.ID6
UNION
    SELECT
        h.ID6,
        'stress_pic' AS from_study,
        'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM stress_pic_hrv h
    RIGHT JOIN stress_pic_resp r ON h.ID6 = r.ID6
),
-- stress_prevention HRV data for B1
stress_prevention_hrv as (
select
sub_id as ID6,
'stress_prevention' as from_study,
'B1' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
from stress_prevention.HEART_RATE
where sub_task = 'B1' and session = 1
),
-- stress_prevention resp data for B1
stress_prevention_resp as (
SELECT
sub_id as ID6,
'stress_prevention' as from_study,
'B1' as timepoint,
RVFMean,
RVFDev
from stress_prevention.resp_mes
where sub_task = 'B1' and session = 1
),
-- stress_prevention combined for B1
stress_prevention_combined AS (
    SELECT
        h.ID6,
        'stress_prevention' AS from_study,
        'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM stress_prevention_hrv h
    LEFT JOIN stress_prevention_resp r ON h.ID6 = r.ID6
UNION
    SELECT
        h.ID6,
        'stress_prevention' AS from_study,
        'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM stress_prevention_hrv h
    RIGHT JOIN stress_prevention_resp r ON h.ID6 = r.ID6
),
-- stress_suppl HRV data for B1
stress_suppl_hrv as (
select
sub_id as ID6,
'stress_suppl' as from_study,
'B1' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
FROM stress_suppl.HRV
where sub_task = 'B1'
),
-- stress_suppl resp data for B1
stress_suppl_resp as (
SELECT
sub_id as ID6,
'stress_suppl' as from_study,
'B1' as timepoint,
RVFMean,
RVFDev
FROM stress_suppl.resp_mes
where sub_task = 'B1'
),
-- stress_suppl combined for B1
stress_suppl_combined AS (
SELECT
    h.ID6,
    'stress_suppl' AS from_study,
    'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM stress_suppl_hrv h
    LEFT JOIN stress_suppl_resp r ON h.ID6 = r.ID6
UNION
SELECT
    h.ID6,
    'stress_suppl' AS from_study,
    'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM stress_suppl_hrv h
    RIGHT JOIN stress_suppl_resp r ON h.ID6 = r.ID6
),
-- VT1 HRV data for B1
vt1_hrv as (
select
sub_id as ID6,
'VT1' as from_study,
'B1' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
FROM VT1.HRV
where sub_task = 'B1' -- and stimul = 'PH'
),
-- VT1 resp data for B1
vt1_resp as (
SELECT
sub_id as ID6,
'VT1' as from_study,
'B1' as timepoint,
RVFMean,
RVFDev
FROM VT1.resp_mes
where sub_task = 'B1' -- and stimul = 'PH'
),
-- VT1 combined for B1
vt1_combined AS (
SELECT
    h.ID6,
    'VT1' AS from_study,
    'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM vt1_hrv h
    LEFT JOIN vt1_resp r ON h.ID6 = r.ID6
UNION
SELECT
    h.ID6,
    'VT1' AS from_study,
    'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM vt1_hrv h
    RIGHT JOIN vt1_resp r ON h.ID6 = r.ID6
),
-- VT2 hrv data for B1
vt2_hrv as (
select
sub_id as ID6,
'VT2' as from_study,
'B1' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
FROM VT2.HRV
where sub_task = 'B1' and stimul = 'BR'
),
-- VT2 resp data for B1
vt2_resp as (
SELECT
sub_id as ID6, 
'VT2' as from_study,
'B1' as timepoint,
RVFMean,
RVFDev
FROM VT2.resp_mes
where sub_task = 'B1' and stimul = 'BR'
),
-- VT2 combined for B1
vt2_combined AS (
SELECT
    h.ID6,
    'VT2' AS from_study,
    'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM vt2_hrv h
    LEFT JOIN vt2_resp r ON h.ID6 = r.ID6
UNION
SELECT
    h.ID6,
    'VT2' AS from_study,
    'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM vt2_hrv h
    RIGHT JOIN vt2_resp r ON h.ID6 = r.ID6
),
-- WTP hrv data for B1
wtp_hrv as (
select
ID6,
'WTP' as from_study,
'B1' as time_point,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
from WTP.HRV
where sub_task = 'B1' and session = 1
),
-- WTP resp data for B1
wtp_resp as (
SELECT
ID6,
'WTP' as from_study,
'B1' as time_point,
RVFMean,
RVFDev
from WTP.resp_mes
where sub_task = 'B1' and session = 1
),
-- WTP combined for B1
WTP_combined AS (
SELECT
    COALESCE(h.ID6, r.ID6) as ID6,
    'WTP' AS from_study,
    'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM wtp_hrv h
    LEFT JOIN wtp_resp r ON h.ID6 = r.ID6
UNION
SELECT
    COALESCE(h.ID6, r.ID6) as ID6,
    'WTP' AS from_study,
    'B1' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM wtp_hrv h
    RIGHT JOIN wtp_resp r ON h.ID6 = r.ID6
),
P6_baa_resp AS ( -- BAA resp measures for 6P
    SELECT
        sub_id AS ID6,
        'BAA' AS from_study,
        '6P' AS timepoint,
        RVFMean,
        RVFDev
    FROM BAA.resp_mes
    WHERE sub_task = 'P6'
),
P6_baa_hrv AS ( -- BAA HRV measures for 6P
    SELECT
        sub_id AS ID6,
        RRIMin, RRImax, RRImean,
        RRIRmssd, RRIPnn50, RRIDev,
        RRICvs, HRMin, HRMax, HRMean,
        HRDev, RRISTot, RRISUlf, RRISVlf,
        RRISLf, RRISHf, RRISLfHF,
        RRISnLf, RRISnHf, RRI, RRIWMean
    FROM BAA.HEART_RATE
    WHERE sub_task = 'P6'
),
-- combine BAA HRV for 6P
P6_BAA_combined AS (
    SELECT
        h.ID6,
        'BAA' AS from_study,
        '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM P6_baa_hrv h
    LEFT JOIN P6_baa_resp r ON h.ID6 = r.ID6
UNION
    SELECT
        h.ID6,
        'BAA' AS from_study,
        '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM P6_baa_hrv h
    RIGHT JOIN P6_baa_resp r ON h.ID6 = r.ID6
),
-- CGE HRV and resp measures together for 6P
P6_CGE_hrv as ( -- CGE HRV measures for 6P
select
ID as ID6,
'CGE' as from_study,
'6P' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
FROM CGE.Import_physio
where 
session = 1 and VAR216 = '6P'
),
-- CGE resp measures for 6P
P6_CGE_resp as (
SELECT
sub_id as ID6,
'CGE' as from_study,
'6P' as timepoint,
RVFMean,
RVFDev
FROM CGE.RESP_mes
where session = 1 AND sub_task = 2
),
-- combine CGE HRV and resp for 6P
P6_CGE_combined AS (
SELECT
h.ID6,
'CGE' AS from_study,
'6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
r.RVFMean, r.RVFDev
FROM P6_CGE_hrv h
LEFT JOIN P6_CGE_resp r ON h.ID6 = r.ID6
UNION
SELECT
h.ID6,
'CGE' AS from_study,
'6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
r.RVFMean, r.RVFDev
FROM P6_CGE_hrv h
RIGHT JOIN P6_CGE_resp r ON h.ID6 = r.ID6
),
-- Stress_pic HRV data for 6P
P6_stress_pic_hrv as (
select
sub_id as ID6,
'stress_pic' as from_study,
'6P' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
from stress_pic.HRV
where sub_task = '6P' and session = 1
),
P6_stress_pic_resp as (
SELECT
sub_id as ID6,
'stress_pic' as from_study,
'6P' as time_point,
RVFMean,
RVFDev
FROM stress_pic.resp_mes
where sub_task = '6P' and session = 1
),
-- stress_pic combined
P6_stress_pic_combined AS (
    SELECT
        h.ID6,
        'stress_pic' AS from_study,
        '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM P6_stress_pic_hrv h
    LEFT JOIN P6_stress_pic_resp r ON h.ID6 = r.ID6
UNION
    SELECT
        h.ID6,
        'stress_pic' AS from_study,
        '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM P6_stress_pic_hrv h
    RIGHT JOIN P6_stress_pic_resp r ON h.ID6 = r.ID6
),
-- stress_prevention HRV data for 6P
P6_stress_prevention_hrv as (
select
sub_id as ID6,
'stress_prevention' as from_study,
'6P' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
nullif(RRISnLf, '') as RRISnLf,
nullif(RRISnHf, '') as RRISnHf,
RRI,
RRIWMean
from stress_prevention.HEART_RATE
where sub_task = '6P' and session = 1
),
-- stress_prevention resp data for 6P
P6_stress_prevention_resp as (
SELECT
sub_id as ID6,
'stress_prevention' as from_study,
'6P' as timepoint,
RVFMean,
RVFDev
from stress_prevention.resp_mes
where sub_task = '6P' and session = 1
),
-- stress_prevention combined for 6P
P6_stress_prevention_combined AS (
    SELECT
        h.ID6,
        'stress_prevention' AS from_study,
        '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM P6_stress_prevention_hrv h
    LEFT JOIN P6_stress_prevention_resp r ON h.ID6 = r.ID6
UNION
    SELECT
        h.ID6,
        'stress_prevention' AS from_study,
        '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
        r.RVFMean, r.RVFDev
    FROM P6_stress_prevention_hrv h
    RIGHT JOIN P6_stress_prevention_resp r ON h.ID6 = r.ID6
),
-- stress_suppl HRV data for 6P
P6_stress_suppl_hrv as (
select
sub_id as ID6,
'stress_suppl' as from_study,
'6P' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
FROM stress_suppl.HRV
where sub_task = '6P'
),
-- stress_suppl resp data for 6P
P6_stress_suppl_resp as (
SELECT
sub_id as ID6,
'stress_suppl' as from_study,
'6P' as timepoint,
RVFMean,
RVFDev
FROM stress_suppl.resp_mes
where sub_task = '6P'
),
-- stress_suppl combined for 6P
P6_stress_suppl_combined AS (
SELECT
    h.ID6,
    'stress_suppl' AS from_study,
    '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM P6_stress_suppl_hrv h
    LEFT JOIN P6_stress_suppl_resp r ON h.ID6 = r.ID6
UNION
SELECT
    h.ID6,
    'stress_suppl' AS from_study,
    '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM P6_stress_suppl_hrv h
    RIGHT JOIN P6_stress_suppl_resp r ON h.ID6 = r.ID6
),
-- VT1 HRV data for 6P
P6_vt1_hrv as (
select
sub_id as ID6,
'VT1' as from_study,
'6P' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
FROM VT1.HRV
where sub_task = '6P' and stimul = 'BR'
),
-- VT1 resp data for 6P
P6_vt1_resp as (
SELECT
sub_id as ID6,
'VT1' as from_study,
'6P' as timepoint,
RVFMean,
RVFDev
FROM VT1.resp_mes
where sub_task = '6P' and stimul = 'BR'
),
-- VT1 combined for 6P
P6_vt1_combined AS (
SELECT
    h.ID6,
    'VT1' AS from_study,
    '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM P6_vt1_hrv h
    LEFT JOIN P6_vt1_resp r ON h.ID6 = r.ID6
UNION
SELECT
    h.ID6,
    'VT1' AS from_study,
    '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM P6_vt1_hrv h
    RIGHT JOIN P6_vt1_resp r ON h.ID6 = r.ID6
),
-- VT2 hrv data for 6P
P6_vt2_hrv as (
select
sub_id as ID6,
'VT2' as from_study,
'6P' as timepoint,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
FROM VT2.HRV
where sub_task = '6P' and stimul = 'BR'
),
-- VT2 resp data for 6P
P6_vt2_resp as (
SELECT
sub_id as ID6, 
'VT2' as from_study,
'6P' as timepoint,
RVFMean,
RVFDev
FROM VT2.resp_mes
where sub_task = '6P' and stimul = 'BR'
),
-- VT2 combined for 6P
P6_vt2_combined AS (
SELECT
    h.ID6,
    'VT2' AS from_study,
    '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM P6_vt2_hrv h
    LEFT JOIN P6_vt2_resp r ON h.ID6 = r.ID6
UNION
SELECT
    h.ID6,
    'VT2' AS from_study,
    '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM P6_vt2_hrv h
    RIGHT JOIN P6_vt2_resp r ON h.ID6 = r.ID6
),
-- WTP hrv data for 6P
P6_wtp_hrv as (
select
ID6,
'WTP' as from_study,
'6P' as time_point,
RRIMin,
RRImax,
RRImean,
RRIRmssd,
RRIPnn50,
RRIDev,
RRICvs,
HRMin,
HRMax,
HRMean,
HRDev,
RRISTot,
RRISUlf,
RRISVlf,
RRISLf,
RRISHf,
RRISLfHF,
RRISnLf,
RRISnHf,
RRI,
RRIWMean
from WTP.HRV
where sub_task = '6P' and session = 1
),
-- WTP resp data for 6P
P6_wtp_resp as (
SELECT
ID6,
'WTP' as from_study,
'6P' as time_point,
RVFMean,
RVFDev
from WTP.resp_mes
where sub_task = '6P' and session = 1
),
-- WTP combined for 6P
P6_WTP_combined AS (
SELECT
    COALESCE(h.ID6, r.ID6) as ID6,
    'WTP' AS from_study,
    '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM P6_wtp_hrv h
    LEFT JOIN P6_wtp_resp r ON h.ID6 = r.ID6
UNION
SELECT
    COALESCE(h.ID6, r.ID6) as ID6,
    'WTP' AS from_study,
    '6P' AS timepoint,
h.RRIMin, h.RRImax,h.RRImean,h.RRIRmssd,
h.RRIPnn50,h.RRIDev,h.RRICvs,h.HRMin,
h.HRMax, h.HRMean, h.HRDev, h.RRISTot,
h.RRISUlf, h.RRISVlf, h.RRISLf, h.RRISHf,
h.RRISLfHF, h.RRISnLf, h.RRISnHf, h.RRI, h.RRIWMean,
    r.RVFMean, r.RVFDev
    FROM P6_wtp_hrv h
    RIGHT JOIN P6_wtp_resp r ON h.ID6 = r.ID6
),
athlete_combined as (
SELECT
ID as ID6,
'Athlete' as from_study,
'B1' as timepoint,
Null as RRIMin,
NULL as RRImax,
NULL as RRImean,
vRRIRmssd as RRIRmssd,
vRRIPnn50 as RRIPnn50,
vRRIDev as RRIDev,
Null as RRICvs,
NULL as HRMin,
NULL as HRMax,
vHRMean as HRMean,
Null as HRDev,
vRRISTot as RRISTot,
NULL as RRISUlf,
NULL as RRISVlf, 
vRRISLf as RRISLf, 
vRRISHf as RRISHf,
NULL as RRISLfHF, 
NULL as RRISnLf,
NULL as RRISnHf,
NULL as RRI,
NULL as RRIWMean,
NULL AS RVFMean,
NULL As RVFDev
FROM Athlete.Athlete_RRI_demo_TG

UNION ALL 

SELECT
ID as ID6,
'Athlete' as from_study,
'6P' as timepoint,
Null as RRIMin,
NULL as RRImax,
NULL as RRImean,
pRRIRmssd as RRIRmssd,
pRRIPnn50 as RRIPnn50,
pRRIDev as RRIDev,
Null as RRICvs,
NULL as HRMin,
NULL as HRMax,
pHRMean as HRMean,
Null as HRDev,
pRRISTot as RRISTot,
NULL as RRISUlf,
NULL as RRISVlf, 
pRRISLf as RRISLf, 
pRRISHf as RRISHf,
NULL as RRISLfHF, 
NULL as RRISnLf,
NULL as RRISnHf,
NULL as RRI,
NULL as RRIWMean,
NULL AS RVFMean,
NULL As RVFDev
FROM Athlete.Athlete_RRI_demo_TG
),
dem_merged_full as (
-- final combined table for 6P HRV and resp measures
SELECT * FROM BAA_combined
UNION ALL
SELECT * FROM CGE_combined
union all 
select * from stress_pic_combined
union all
select * from stress_prevention_combined
union all
select * from stress_suppl_combined
union all
select * from vt1_combined
union all
select * from vt2_combined
union all
select * from WTP_combined
union all
SELECT * FROM P6_BAA_combined
UNION ALL
SELECT * FROM P6_CGE_combined
union all 
select * from P6_stress_pic_combined
union all
select * from P6_stress_prevention_combined
union all
select * from P6_stress_suppl_combined
union all
select * from P6_vt1_combined
union all
select * from P6_vt2_combined
union all
select * from P6_WTP_combined
union all
select *
from athlete_combined
),
-- final query to return proper physio_df
physio_df_clean as (
select *
from dem_merged_full
where ID6 in (
    select ID6
    from dem_merged_full
    where timepoint in ('B1', '6P')
    group by ID6
    having count(distinct timepoint) = 2)
)
select *
from physio_df_clean
;



-- where from_study = 'WTP'
-- ORDER BY from_study ASC, ID6 ASC

