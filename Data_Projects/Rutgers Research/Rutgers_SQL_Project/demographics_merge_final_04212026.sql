-- BAA demo data (clean)
With baa_dem as
(select
sub_id as ID6,
nullif(D_1, '') as age,
null as height,
null as weight,
nullif(D_6, '') as race,
case
    when D_6 = 1 then "American Indian or Alaska Native"
    when D_6 = 2 then "Asian"
    when D_6 = 3 then "Black or African American"
    when D_6 = 4 then "Native Hawaiian or Other Pacific Islander"
    when D_6 = 5 then "White"
    when D_6 = 6 then "Other"
    else null
    end as race_text,
nullif(D_7, '') as ethnicity,
case
    when D_8 = 1 then 'yes'
    when D_8= 2 then 'no'
    ELSE NULL
end as hispanic
FROM BAA.dem),
baa_gender as (
select
ID6,
GENDER as sex
from BAA.import_alcdrug
),
baa_dem_combined as (
select
COALESCE(d.ID6, g.ID6) AS ID6,
'baa' as from_study,
d.age,
d.height,
d.weight,
g.sex,
d.race,
d.race_text,
d.ethnicity,
d.hispanic
from baa_dem d
left join baa_gender g on d.ID6 = g.ID6
union
select
COALESCE(d.ID6, g.ID6) AS ID6,
'baa' as from_study,
d.age,
d.height,
d.weight,
g.sex,
d.race,
d.race_text,
d.ethnicity,
d.hispanic
from baa_dem d
right join baa_gender g on d.ID6 = g.ID6
),
-- CGE demo data (clean but find Height and weight data)
cge_dem as (
SELECT
ID as ID6,
'CGE' as from_study,
CGED5 as age,
null as height,
null as weight,
-- height (ft + inches) = RUBIC10, weight (lbs) RUBIC11...RUBIC table is empty, find the data.
'F' as sex,
CGED10 as race,
case
    when CGED10 = 1 then "American Indian or Alaska Native"
    when CGED10 = 2 then "Asian"
    when CGED10 = 3 then "Black or African American"
    when CGED10 = 4 then "Native Hawaiian or Other Pacific Islander"
    when CGED10 = 5 then "White"
    when CGED10 = 6 then "Other"
    else null
    end as race_text,
CGED11 as ethnicity,
case
when CGED11 = 0 then 'no'
when CGED11 in (1,2,3,4) then 'yes'
else null
end as hispanic
FROM CGE.CGE_dem_TG),
-- Stress_pic demo data
stress_pic_dem as (
SELECT 
sub_id as ID6,
D_1 as age,
D_7 as race,
case
    when D_7 = 1 then 'American Indian or Alaska Native'
    when D_7 = 2 then 'Asian'
    when D_7 = 3 then 'Native Hawaiian or Other Pacific Islander'
    when D_7 = 4 then 'Black or African American'
    when D_7 = 5 then 'White'
    when D_7 = 6 then 'Other'
    else Null
    end as race_text,
D_8 as ethnicity,
case
	when D_8 = 1 then 'yes'
    when D_8 = 2 then 'no'
    else Null
    end as hispanic
FROM stress_pic.dem),

stress_pic_gender as (
SELECT
ID6,
Gender as sex
FROM stress_pic.import_physio_pictword
where Task = 'B1' and session = 1),

stress_pic_dem_gender as (
SELECT
    COALESCE(d.ID6, g.ID6) AS ID6,
    d.age,
     d.race,
     d.race_text,
     d.ethnicity,
     d.hispanic,
    g.sex
    FROM stress_pic_dem d
    LEFT JOIN stress_pic_gender g ON d.ID6 = g.ID6

    UNION

    SELECT
        COALESCE(d.ID6, g.ID6),
        d.age,
        d.race,
        d.race_text,
        d.ethnicity,
        d.hispanic,
        g.sex
    FROM stress_pic_dem d
    RIGHT JOIN stress_pic_gender g ON d.ID6 = g.ID6
),
stress_pic_dem_combined as (
SELECT
COALESCE(d.ID6, ht.ID6) as ID6,
'stress_pic' as from_study,
d.age,
ROUND(ht.HEIGHT*.01,2) as height,
ht.WEIGHT as weight,
d.sex,
d.race,
d.race_text,
d.ethnicity,
d.hispanic
from stress_pic_dem_gender d
left join stress_pic.stress_pic_dem_TG ht on d.ID6 = ht.ID6
union
SELECT
COALESCE(d.ID6, ht.ID6) as ID6,
'stress_pic' as from_study,
d.age,
ROUND(ht.HEIGHT*.01,2) as height,
ht.WEIGHT as weight,
d.sex,
d.race,
d.race_text,
d.ethnicity,
d.hispanic
from stress_pic_dem_gender d
right join stress_pic.stress_pic_dem_TG ht on d.ID6 = ht.ID6),
-- stress_prevention demo data (clean)
stress_prevention_dem as (
SELECT 
sub_id as ID6,
D_1 as age,
D_7 as race,
case
    when D_7 = 1 then 'American Indian or Alaska Native'
    when D_7 = 2 then 'Asian'
    when D_7 = 3 then 'Native Hawaiian or Other Pacific Islander'
    when D_7 = 4 then 'Black or African American'
    when D_7 = 5 then 'White'
    when D_7 = 6 then 'Other'
    else Null
    end as race_text,
D_8 as ethnicity,
case
	when D_8 = 1 then 'yes'
    when D_8 = 2 then 'no'
    else Null
    end as hispanic
FROM stress_prevention.dem),

stress_prevention_gender as (
SELECT
ID6,
Gender as sex
FROM stress_prevention.import_physio
where Task = 'B1' and session = 1),

stress_prevention_dem_combined as (
select
d.ID6,
'stress_prevention' as from_study,
d.age,
null as height,
null as weight,
g.sex,
d.race,
d.race_text,
nullif(d.ethnicity, '') as ethnicity,
d.hispanic
from stress_prevention_dem d
left join stress_prevention_gender g on d.ID6 = g.ID6

union

select
d.ID6,
'stress_prevention' as from_study,
d.age,
null as height,
null as weight,
g.sex,
d.race,
d.race_text,
nullif(d.ethnicity, '') as ethnicity,
d.hispanic
from stress_prevention_dem d
right join stress_prevention_gender g on d.ID6 = g.ID6
),
-- stress_suppl demo data
stress_suppl_dem as (
SELECT 
sub_id as ID6,
D_1 as age,
D_7 as race,
case
    when D_7 = 1 then 'American Indian or Alaska Native'
    when D_7 = 2 then 'Asian'
    when D_7 = 3 then 'Native Hawaiian or Other Pacific Islander'
    when D_7 = 4 then 'Black or African American'
    when D_7 = 5 then 'White'
    when D_7 = 6 then 'Other'
    else Null
    end as race_text,
D_8 as ethnicity,
case
	when D_8 = 1 then 'yes'
    when D_8 = 2 then 'no'
    else Null
    end as hispanic
FROM stress_suppl.dem),

stress_suppl_gender as (
SELECT
ID6,
Gender as sex
FROM stress_suppl.import_physio_suppl
where Task = 'B1' and session = 1),

stress_suppl_dem_combined as (
select
d.ID6,
'stress_suppl' as from_study,
d.age,
null as height,
null as weight,
g.sex,
d.race,
d.race_text,
d.ethnicity,
d.hispanic
from stress_suppl_dem d
left join stress_suppl_gender g on d.ID6 = g.ID6

union

select
d.ID6,
'stress_suppl' as from_study,
d.age,
null as height,
null as weight,
g.sex,
d.race,
d.race_text,
d.ethnicity,
d.hispanic
from stress_suppl_dem d
right join stress_suppl_gender g on d.ID6 = g.ID6
),
-- VT1 demo data
vt1_dem as (
SELECT
ID6,
Gender as sex,
Age as age
FROM VT1.import_alcdrugpsych_vt1),

vt1_htwt as (
select
(ID + 150000) as ID6,
WEIGHT as weight,
CAST(ROUND(HEIGHT*0.01,2) AS DECIMAL(5,2)) as height
FROM VT1.vt1_htwt_TG),

vt1_dem_combined as (
select
d.ID6,
'VT1' as from_study,
d.age,
ht.height,
ht.weight,
d.sex,
null as race,
null as race_text,
null as ethnicity,
null as hispanic
from vt1_dem d
left join vt1_htwt ht on ht.ID6 = d.ID6

union

select
d.ID6,
'VT1' as from_study,
d.age,
ht.height,
ht.weight,
d.sex,
null as race,
null as race_text,
null as ethnicity,
null as hispanic
from vt1_dem d
right join vt1_htwt ht on ht.ID6 = d.ID6
),
-- VT2 demo data (clean, I think)
vt2_dem as (
SELECT *
FROM (
    SELECT
    ID6,
    weight,
    CAST(ROUND(height*0.01,2) AS DECIMAL(5,2)) as height,
    CONVERT(CAST(race AS CHAR) USING utf8) as race,
    case
        when race = 1 then 'American Indian or Alaska Native'
        when race = 2 then 'Asian'
        when race = 3 then 'Black or African American'
        when race = 4 then 'Native Hawaiian or Other Pacific Islander'
        when race = 5 then 'White'
        when race = 6 then 'Other'
        else null
    end as race_text,
    CONVERT(CAST(ethnicity AS CHAR) USING utf8) as ethnicity,
    CASE
        WHEN ethnicity = 1 THEN 'yes'
        when ethnicity = 0 then 'no'
        ELSE NULL
    END AS hispanic
FROM (
    SELECT
        ID6,
		CONVERT(CAST(Weight AS CHAR) USING utf8) as weight,
		CONVERT(CAST(Height AS CHAR) USING utf8) as height,
        CASE
            WHEN Race_1 = 1 THEN 1
            WHEN Race_2 = 1 THEN 2
            WHEN Race_3 = 1 THEN 3
            WHEN Race_4 = 1 THEN 4
            WHEN Race_5 = 1 THEN 5
            WHEN Race_6 = 1 THEN 6
            ELSE NULL
        END AS race,
        CASE
            WHEN Eth2012_1 = 1 THEN 0
            WHEN Eth2012_2 = 1 THEN 1
            WHEN Eth2012_3 = 1 THEN 1
            WHEN Eth2012_4 = 1 THEN 1
            WHEN Eth2012_5 = 1 THEN 1
            ELSE 0
        END AS ethnicity,
        ROW_NUMBER() OVER (
            PARTITION BY ID6
            ORDER BY ID6
        ) AS rn
    FROM VT2.import_alcdrugpsych_vt2
        ) t
    where rn = 1
) AS subquery),

vt2_gender_age as (
SELECT *
from (
    SELECT
    DISTINCT UniqID + 150000 as ID6,
    CONVERT(CAST(Gender AS CHAR) USING utf8) as sex,
    CONVERT(CAST(Age AS CHAR) USING utf8) as age,
    ROW_NUMBER() OVER (
        PARTITION BY UniqID + 150000
        ORDER BY UniqID
    ) AS rn
    FROM VT2.vt2_gender_age_TG
    ) t
WHERE rn = 1
    ),

vt2_dem_combined as (
select
COALESCE(d.ID6, ga.ID6) AS ID6,
'VT2' as from_study,
ga.age,
d.height,
d.weight,
ga.sex,
d.race,
d.race_text,
d.ethnicity,
d.hispanic
from vt2_dem d
left join 
vt2_gender_age ga on d.ID6 = ga.ID6

union

select
COALESCE(d.ID6, ga.ID6) AS ID6,
'VT2' as from_study,
ga.age,
d.height,
d.weight,
ga.sex,
d.race,
d.race_text,
d.ethnicity,
d.hispanic
from vt2_dem d
right join 
vt2_gender_age ga on d.ID6 = ga.ID6
),
-- VT3 demo data
vt3_c1s1_dem as ( -- C1S1 data
SELECT
ID6,
-- 'c1s1' as cohort,
'VT3' as from_study,
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
-- 'c4s1' as cohort,
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
vt3_dem_combined1 as ( -- made this here since I need to remove 1 ID
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
)),
-- WTP demo data
wtp_dem_combined as (
select 
ID6,
from_study,
age,
height,
weight,
sex,
race,
case
when race = 1 then 'American Indian or Alaska Native'
when race = 2 then 'Asian'
when race = 3 then 'Black or African American'
when race = 4 then 'Native Hawaiian or Other Pacific Islander'
when race = 5 then 'White'
when race = 6 then 'Other'
else null
end as race_text,
ethnicity,
hispanic
From (
    SELECT
    IDNUM as ID6,
    'WTP' as from_study,
    IN1 as age,
    ROUND(HEIGHT*0.0254, 2) as height,
    ROUND(IN3/2.2,2) as weight,
    'F' as sex,
    case
        when IN7 = 1 then 5
        when IN7 = 2 then 3
        when IN7 = 3 then 1
        when IN7 = 4 then 4
        when IN7 = 5 then 2
        when IN7 = 6 then 6
        else null
        end as race,
    IN6 as ethnicity,
    case when IN6 = 1 then 'yes'
        when IN6 = 2 then 'no'
        else null end as hispanic
    from WTP.WTP_dem_TG
) as subquery
),
-- union all demo data here
all_dem_combined as (
select *
from baa_dem_combined
union all
select *
from cge_dem
union all
select *
from stress_pic_dem_combined
union all
select *
from stress_prevention_dem_combined
union all
select *
from stress_suppl_dem_combined
union all
select *
from vt1_dem_combined
union all
select *
from vt2_dem_combined
union all
select *
from vt3_dem_combined
union all
select *
from wtp_dem_combined
),
full_demographics_df as (
SELECT
ID6,
from_study,
age,
height,
weight,
bmi,
sex,
race,
race_text,
case
when race_text = 'American Indian or Alaska Native' then 1
when race_text = 'Asian' then 2
when race_text = 'Black or African American' then 3
when race_text = 'Native Hawaiian or Other Pacific Islander' then 4
when race_text = 'White' then 5
when race_text = 'Other' then 6
else null
end as race_code_cleaned,
ethnicity,
hispanic
FROM (
select 
ID6, 
from_study,
age,
height,
weight,
ROUND(weight / POWER(height,2),2) as bmi,
sex,
race,
race_text,
ethnicity,
hispanic
from all_dem_combined) as subquery)
select *
from full_demographics_df
order by from_study ASC, ID6 ASC
;






-- Athlete demo data