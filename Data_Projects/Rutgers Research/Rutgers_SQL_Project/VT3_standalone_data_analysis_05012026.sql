-- unioning VT3 cohort demographic data
-- C1S1
with vt3_c1s1_dem as (
select
ID6,
'VT3' as from_study,
'C1S1' as cohort,
Age_S1 as age, 
CAST(ROUND(Height_S1A*0.01, 2) AS DECIMAL(5,2)) as height,
Weight_S1A as weight,
case
when Sex_S1 = 1 then 'M'
when Sex_S1 = 2 then 'F'
else null end as sex,
Race_S1 as race,
case
when Race_S1 = 1 then 'American Indian or Alaska Native'
when Race_S1 = 2 then 'Asian'
when Race_S1 = 3 then 'Black or African American'
when Race_S1 = 4 then 'Native Hawaiian or Other Pacific Islander'
when Race_S1 = 5 then 'White'
when Race_S1 = 6 then 'Other'
else null end as race_text,
Ethnicity_S1 as ethnicity,
-- verify the codebook I am looking at is correct for race classification
case
when Ethnicity_S1 = 1 then 'no'
when Ethnicity_S1 in (2,3,4,5) then 'yes'
else null
end as hispanic
FROM VT3.import_vtc1s1final),

vt3_c3s1_dem as ( -- C3S1 data
SELECT
ID6,
'VT3' as from_study,
'C3S1' as cohort,
-- 'c3s1' as cohort,
Age_S1 as age,
CAST(ROUND(Height_S1A*0.01, 2) AS DECIMAL(5,2)) as height,
Weight_S1A as weight,
case
when Sex_S1 = 1 then 'M'
when Sex_S1 = 2 then 'F'
else null end as sex,
Race_S1 as race,
case
when Race_S1 = 1 then 'American Indian or Alaska Native'
when Race_S1 = 2 then 'Asian'
when Race_S1 = 3 then 'Black or African American'
when Race_S1 = 4 then 'Native Hawaiian or Other Pacific Islander'
when Race_S1 = 5 then 'White'
when Race_S1 = 6 then 'Other'
else null end as race_text,
Ethnicity_S1 as ethnicity,
-- verify the codebook I am looking at is correct for race classification
case
when Ethnicity_S1 = 1 then 'no'
when Ethnicity_S1 in (2,3,4,5) then 'yes'
else null
end as hispanic
FROM VT3.import_vtc3s1final),
-- C4s1 dem data
vt3_c4s1_dem as (
SELECT
ID6,
'VT3' as from_study,
'C4S1' as cohort,
Age_S1 as age,
CAST(ROUND(Height_S1A*0.01, 2) AS DECIMAL(5,2)) as height,
Weight_S1A as weight,
case
when Sex_S1 = 1 then 'M'
when Sex_S1 = 2 then 'F'
else null
end as sex,
Race_S1 as race,
case
when Race_S1 = 1 then 'American Indian or Alaska Native'
when Race_S1 = 2 then 'Asian'
when Race_S1 = 3 then 'Black or African American'
when Race_S1 = 4 then 'Native Hawaiian or Other Pacific Islander'
when Race_S1 = 5 then 'White'
when Race_S1 = 6 then 'Other'
else null end as race_text,
Ethnicity_S1 as ethnicity,
-- verify the codebook I am looking at is correct for race classification
case
when Ethnicity_S1 = 1 then 'no'
when Ethnicity_S1 in (2,3,4,5) then 'yes'
else null
end as hispanic
FROM VT3.import_vtc4s1final),
-- union all cohort dem data
vt3_dem_combined1 as ( -- made this here since I need to remove a few IDs
select *
from vt3_c1s1_dem
union all
select * from
vt3_c3s1_dem
union all
select * from 
vt3_c4s1_dem),

vt3_dem_combined as (
select *
from vt3_dem_combined1
where ID6 not in ('30sec sigh inhaled by nose at 3:35',
'SC sometimes went out of range',
'Participant sometimes had trouble with 6P',
'6P: BP noisy at 4:50',
'30sec sigh: sometimes yawning',
'6P: sometimes stuttered inhale',
'Some yawning in baseline breathing task & 6P',
'Sometimes yawned or inhaled by nose in both sighing tasks',
'ECG briefly became noisy during sighs in both sighing tasks'
))
-- union all cohort dem data
select *
from vt3_c1s1_dem
union all
select * from
vt3_c3s1_dem
union all
select * from 
vt3_c4s1_dem;


-- VT3 combining health checklist data
With all_vt_hlth_chk_lst as (
SELECT * 
FROM VT3.C1S1_VT_HLTH_CHK_LST
union all 
select *
from VT3.C3S1_VT_HLTH_CHK_LST
union all 
select *
from 
VT3.C4S1_VT_HLTH_CHK_LST
union all
select *
from VT3.C5S1_VT_HLTH_CHK_LST)
select *
from all_vt_hlth_chk_lst
;

-- Arrival protocol joins
SELECT * 
from VT3.C1S1_Arr_ptcl
union all
select *
from VT3.C3S1_Arr_ptcl
where EXCLUDE != NULL
;


-- VT questionnaire C1S1
With c1s1_vt_health as (
    SELECT
    ID6,
    age,
    sex,
    weight,
    height,
    neuro_hx,
    resp_hx,
    metabolic_hx,
    blood_cond,
    vasc_cond,
    cv_cond,
    psych_cond,
    psych_cond_code
    from
    (
        SELECT
ID6, 
Age_S1 as age,
case
when Sex_S1 = 2 then 'F'
when Sex_S1 = 1 then 'M'
when Sex_S1 = 3 then 'Int'
else null
end as sex,
Weight_S1A as weight,
Height_S1A as height,
case
when abMRI_S1 = 1 then 1
when SeizUnexp_S1 = 1 then 1
when Aneurysm_S1 = 1 then 1
when Tumor_S1 = 1 then 1
When Epilepsy_S1 = 1 then 1
when Migraine_S1 = 1 then 1
when TBI_S1 = 1 then 1
when MS_S1 = 1 then 1
when TIA_S1= 1 then 1
when OtherNeuroText_S1 = 1 then 1
else 0
end as neuro_hx,
case
when Pleurisy_S1 = 1 then 1
when Asthma_S1 = 1 then 1
when ChronBronc_S1 = 1 then 1
when OtherResp_S1 = 1 then 1
else 0 
end as resp_hx,
case
when Thyroid_S1 = 1 then 1
when Adrenal_S1 = 1 then 1
when Diabetes_S1 = 1 then 1
when Gout_S1 = 1 then 1
when Obesity_S1 = 1 then 1
else 0
end as metabolic_hx,
case
when Anemia_S1 = 1 then 1
when SickleCell_S1 = 1 then 1
when Hemo_S1 = 1 then 1
when Clots_S1 = 1 then 1
when OtherBlood_S1 = 1 then 1
else 0 
end as blood_cond,
case
when HiBP_S1 = 1 then 1
when LowBP_S1 = 1 then 1
when Raynaud_S1 = 1 then 1
when PeriphArt_S1 = 1 then 1
when Hichol_S1 = 1 then 1
when OtherVasc_S1 = 1 then 1
else 0 
end as vasc_cond,
case
when MyocardInf_S1 = 1 then 1
when Arrhyth_S1 = 1 then 1
when Pacemaker_S1 = 1 then 1
when HeartDis_S1 = 1 then 1
when OtherHeart_S1 = 1 then 1
else 0 
end as cv_cond,
case
when Anxiety_S1 = 1 then 1
when Depression_S1 = 1 then 1
when AUD_S1 = 1 then 1
when Schizo_S1 = 1 then 1
when ADHD_S1 = 1 then 1
when Eating_S1 = 1 then 1
when OtherPsych_S1 = 1 then 1
else 0 
end as psych_cond,
case
when Anxiety_S1 = 1 then 'anxiety'
when Depression_S1 = 1 then 'depression'
when AUD_S1 = 1 then 'AUD'
when Schizo_S1 = 1 then 'schizophrenia'
when ADHD_S1 = 1 then 'ADHD'
when Eating_S1 = 1 then 'eating disorder'
when OtherPsych_S1 = 1 then 'other psych'
else 0
end as psych_cond_code
FROM VT3.import_vtc1s1final)
as subquery)
select *
from c1s1_vt_health
;


-- VT3 C3S1
With c3s1_vt_health as (
    SELECT
    ID6,
    age,
    sex,
    weight,
    height,
    neuro_hx,
    resp_hx,
    metabolic_hx,
    blood_cond,
    vasc_cond,
    cv_cond,
    psych_cond,
    psych_cond_code
    from
    (
        SELECT
ID6, 
Age_S1 as age,
case
when Sex_S1 = 2 then 'F'
when Sex_S1 = 1 then 'M'
when Sex_S1 = 3 then 'Int'
else null
end as sex,
Weight_S1A as weight,
Height_S1A as height,
case
when abMRI_S1 = 1 then 1
when SeizUnexp_S1 = 1 then 1
when Aneurysm_S1 = 1 then 1
when Tumor_S1 = 1 then 1
When Epilepsy_S1 = 1 then 1
when Migraine_S1 = 1 then 1
when TBI_S1 = 1 then 1
when MS_S1 = 1 then 1
when TIA_S1= 1 then 1
when OtherNeuroText_S1 = 1 then 1
else 0
end as neuro_hx,
case
when Pleurisy_S1 = 1 then 1
when Asthma_S1 = 1 then 1
when ChronBronc_S1 = 1 then 1
when OtherResp_S1 = 1 then 1
else 0 
end as resp_hx,
case
when Thyroid_S1 = 1 then 1
when Adrenal_S1 = 1 then 1
when Diabetes_S1 = 1 then 1
when Gout_S1 = 1 then 1
when Obesity_S1 = 1 then 1
else 0
end as metabolic_hx,
case
when Anemia_S1 = 1 then 1
when SickleCell_S1 = 1 then 1
when Hemo_S1 = 1 then 1
when Clots_S1 = 1 then 1
when OtherBlood_S1 = 1 then 1
else 0 
end as blood_cond,
case
when HiBP_S1 = 1 then 1
when LowBP_S1 = 1 then 1
when Raynaud_S1 = 1 then 1
when PeriphArt_S1 = 1 then 1
when Hichol_S1 = 1 then 1
when OtherVasc_S1 = 1 then 1
else 0 
end as vasc_cond,
case
when MyocardInf_S1 = 1 then 1
when Arrhyth_S1 = 1 then 1
when Pacemaker_S1 = 1 then 1
when HeartDis_S1 = 1 then 1
when OtherHeart_S1 = 1 then 1
else 0 
end as cv_cond,
case
when Anxiety_S1 = 1 then 1
when Depression_S1 = 1 then 1
when AUD_S1 = 1 then 1
when Schizo_S1 = 1 then 1
when ADHD_S1 = 1 then 1
when Eating_S1 = 1 then 1
when OtherPsych_S1 = 1 then 1
else 0 
end as psych_cond,
case
when Anxiety_S1 = 1 then 'anxiety'
when Depression_S1 = 1 then 'depression'
when AUD_S1 = 1 then 'AUD'
when Schizo_S1 = 1 then 'schizophrenia'
when ADHD_S1 = 1 then 'ADHD'
when Eating_S1 = 1 then 'eating disorder'
when OtherPsych_S1 = 1 then 'other psych'
else 0
end as psych_cond_code
FROM VT3.import_vtc3s1final)
as subquery)
select *
from c3s1_vt_health
;


-- VT3 C4S1 VT health
With c4s1_vt_health as (
    SELECT
    ID6,
    age,
    sex,
    weight,
    height,
    neuro_hx,
    resp_hx,
    metabolic_hx,
    blood_cond,
    vasc_cond,
    cv_cond,
    psych_cond,
    psych_cond_code
    from
    (
        SELECT
ID6, 
Age_S1 as age,
case
when Sex_S1 = 2 then 'F'
when Sex_S1 = 1 then 'M'
when Sex_S1 = 3 then 'Int'
else null
end as sex,
Weight_S1A as weight,
Height_S1A as height,
case
when abMRI_S1 = 1 then 1
when SeizUnexp_S1 = 1 then 1
when Aneurysm_S1 = 1 then 1
when Tumor_S1 = 1 then 1
When Epilepsy_S1 = 1 then 1
when Migraine_S1 = 1 then 1
when TBI_S1 = 1 then 1
when MS_S1 = 1 then 1
when TIA_S1= 1 then 1
when OtherNeuroText_S1 = 1 then 1
else 0
end as neuro_hx,
case
when Pleurisy_S1 = 1 then 1
when Asthma_S1 = 1 then 1
when ChronBronc_S1 = 1 then 1
when OtherResp_S1 = 1 then 1
else 0 
end as resp_hx,
case
when Thyroid_S1 = 1 then 1
when Adrenal_S1 = 1 then 1
when Diabetes_S1 = 1 then 1
when Gout_S1 = 1 then 1
when Obesity_S1 = 1 then 1
else 0
end as metabolic_hx,
case
when Anemia_S1 = 1 then 1
when SickleCell_S1 = 1 then 1
when Hemo_S1 = 1 then 1
when Clots_S1 = 1 then 1
when OtherBlood_S1 = 1 then 1
else 0 
end as blood_cond,
case
when HiBP_S1 = 1 then 1
when LowBP_S1 = 1 then 1
when Raynaud_S1 = 1 then 1
when PeriphArt_S1 = 1 then 1
when Hichol_S1 = 1 then 1
when OtherVasc_S1 = 1 then 1
else 0 
end as vasc_cond,
case
when MyocardInf_S1 = 1 then 1
when Arrhyth_S1 = 1 then 1
when Pacemaker_S1 = 1 then 1
when HeartDis_S1 = 1 then 1
when OtherHeart_S1 = 1 then 1
else 0 
end as cv_cond,
case
when Anxiety_S1 = 1 then 1
when Depression_S1 = 1 then 1
when AUD_S1 = 1 then 1
when Schizo_S1 = 1 then 1
when ADHD_S1 = 1 then 1
when Eating_S1 = 1 then 1
when OtherPsych_S1 = 1 then 1
else 0 
end as psych_cond,
case
when Anxiety_S1 = 1 then 'anxiety'
when Depression_S1 = 1 then 'depression'
when AUD_S1 = 1 then 'AUD'
when Schizo_S1 = 1 then 'schizophrenia'
when ADHD_S1 = 1 then 'ADHD'
when Eating_S1 = 1 then 'eating disorder'
when OtherPsych_S1 = 1 then 'other psych'
else 0
end as psych_cond_code
FROM VT3.import_vtc4s1final)
as subquery)
select *
from c4s1_vt_health
;

-- IPAQ questionnaire
with vt3_ipaq_combined as (
SELECT * 
FROM VT3.C1S1_IPAQ
union all
SELECT *
from VT3.C3S1_IPAQ
union all
SELECT *
from VT3.C4S1_IPAQ
union all
SELECT *
from VT3.C5S1_IPAQ
)
SELECT *
from vt3_ipaq_combined
;

