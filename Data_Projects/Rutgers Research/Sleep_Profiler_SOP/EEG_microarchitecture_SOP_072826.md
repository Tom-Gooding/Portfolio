Capturing Sleep Micro-architecture from Sleep Profiler EEG headband.

**Table of Contents**
- [Getting Started.](#getting-started)
  - [Python libraries (dependencies).](#python-libraries-dependencies)
- [Things to know before you begin processing EEG data.](#things-to-know-before-you-begin-processing-eeg-data)
  - [How to export and view EDF files](#how-to-export-and-view-edf-files)
- [Actual Workflow for EEG analysis in Python](#actual-workflow-for-eeg-analysis-in-python)
    - [Step 1 Exporting and viewing the csv study file.](#step-1-exporting-and-viewing-the-csv-study-file)
  - [Step 2- Upload data to Python](#step-2--upload-data-to-python)
  - [Step 3- Pre-processing stage, removing artifact](#step-3--pre-processing-stage-removing-artifact)
- [Aligning Hypnogram with EEG data](#aligning-hypnogram-with-eeg-data)
- [Automatic staging with SleepStaging.](#automatic-staging-with-sleepstaging)
  - [Step 4- Calculate spectral power](#step-4--calculate-spectral-power)
  - [Step 5- Sort brainwave frequencies](#step-5--sort-brainwave-frequencies)
  - [Step 6- Identify sleep microarchitecture](#step-6--identify-sleep-microarchitecture)
- [References](#references)

**Notes on Sleep Profiler X8 EEG headband system:**

The X8 Sleep Profiler system acquires physiological signals including the acquisition of up to five channels of electrophysiological signals: electroencephalographic (EEG), electromyographic (EMG), electrooculographic (EOG, LEOG/REOG), and electrocardiographic (ECG) signals, photoplethysmographic (PPG) signal, sound (e.g., snoring), and [head] movement and position.

Optionally, the device can record two channels of respiratory effort, airflow with a cannula and nasal pressure inducer, and/or oxygen saturation and pulse rate with a pulse oximeter, which can be used with Sleep Profiler software to detect sleep disordered breathing. 

The validation study of the Sleep Profiler headband (considered a "rigid headband") autostaging algorithm demonstrated a Cohen's kappa coefficient of κ = 0.67 (0.61 to 0.80 is considered "substantial agreement"), compared against a panel of five sleep experts' sleep scoring agreement (considered the "gold standard"). This kappa coefficient for Sleep Profiler is similar to other at-home sleep-monitoring devices (range ~0.64 to 0.74 for similar devices).

- **Note:** The kappa coeffient tells you the amount of agreement between two raters/ratings, but not the accuracy. For this project, the SleepProfiler autostaging algorithm output can be compared against the autostaging functions available in the YASA Python package to determine how much agreement there is between the two algorithms for determining sleep stages between any given EEG.edf file. 
- SleepProfiler and YASA use the same AASM criteria to autoscore EEG data; however, SleepProfiler's instructional materials (see Sleep Profiler SOP for details) state that their algorithm has some deviations regarding the staging criteria used vs. AASM standard criteria. As such, this is something to consider when using the scored sleep data from either SleepProfiler or Python (YASA).
- Some items to consider when cleaning this data (to potentially improve agreement):
  - Having humans visually review at least a subset of the EEG.edf data to determine how well SleepProfiler and/or YASA's sleep staging compares to lab personnel's scoring (again, human scoring is considered the "gold standard" for sleep staging determination).
  - During the pre-processing steps, dictate sleep_onset and sleep_offset for both the SleepProfiler Study Editor tool, and in Python when preparing the data. This will improve staging accuracy by cutting out epochs before/after the study observation period for a given night's sleep. **This step will be repeated in the workflow section below.** 
    - Do this by pairing sleep diary data (if captured) and placing sleep start/end markers in the Sleep Profiler portal, or by mapping confirmed sleep_onset & sleep_offset times for each night's sleep in YASA (see below). 

```python

```
You can also crop the hypnogram to a specific time window (e.g., sleep start/end).
```python
## how to crop hypnogram in Python using YASA
hyp = yasa.simulate_hypnogram(tib=480, start="2024-01-15 23:00:00", seed=42)
hyp_night = hyp.crop("2024-01-15 23:30:00", "2024-01-16 06:00:00")
```





# Getting Started. 

## Python libraries (dependencies).

EEG analysis will primarily use YASA and MNE Python libraries. 
```python
## load dependencies
## Not all of these are necessarily required for EEG analysis, (sns, plt) but I like to load a set of standard Python libraries just in case I'll end up using them later on and don't want to import packages in seemingly random places.
import pandas as pd
import numpy as np
import mne
import yasa
import sleepeegpy ## wrapper package (combines YASA + MNE + others, not-essential)
from matplotlib import pyplot as plt
import seaborn as sns
import os
```

# Things to know before you begin processing EEG data. 

## How to export and view EDF files 
From SleepProfiler SOP, export the most recent, processed EEG.edf file of a study participant's night of sleep from the SleepProfiler [website](https://cportal.b-alert.com/sleep-profiler/login). 

**Note:** [EDF](https://www.edfplus.info/) (European Data Format) is the de-facto standard format for EEG and PSG recordings in commercial equipment and multicenter research projects. 

For viewing the raw data from the EEG.edf file, use an EDFBroswer (there are many on the web). The version below is a free, open-source program that the author (TG) of this SOP was able to get running on a Macbook (there are limited options available for Mac users that the time of this writing) and should give PC users little, if any, trouble downloading and accessing

Free, open-source EDF Browser: [EDF Browser Links](https://www.teuniz.net/edfbrowser/)



















# Actual Workflow for EEG analysis in Python

### Step 1 Exporting and viewing the csv study file. 
The epoch-by-epoch csv file should be exported in tandem with the EDF file for subsequent uploading into Python. This csv file has columns A through O which represent the following:

- Column A: Subject number
- Column B: Epoch number
- Column C: Night of the study (1, 2, or 3)
- Column D: Study date
- Column E: Elapsed time from the start of record (hh:mm:ss)
- Column F: Elapsed time (s) from start of record to start of epoch
- Column G: Clock time from real time clock of the start of epoch
- Colum H: Primary stage classification from auto-scoring: 
  - 0 = wake
  - 1 = N1
  - 2 = N2
  - 3 = N3
  - 4 = L2 (light N2)
  - 5 = REM
  - 6 = NOS (sleep not otherwise specified)
  - 9 = INVALID
  - 14 = NRH (Non-REM hypertonia)
  - 33 = Atypical N3
  - 55 = RSWA (REM sleep without atonia)
- Column I: Secondary autostage
  - assigned to epochs when patterns are detected that suggest an alternative stage to the primary stage should be considered. 
- Column J: Tech edit stage
  - stage assigned during technical review (when applicable). Stages are numerically coded the same as the primary stage. 
- Column K: Stage final
  - final stage assigned where tech editing superceded primary stage.
- Column L: Channel staged
  - channel used for staging the epoch; EEG, LEOG, or REOG.
- Column M: ImpLEOG
  - impedence value.for LEOG channels (15 minute intervals)
- Column N: ImpREOG
  - impedence value for REOG channels (15 minute intervals)
- Column O: ImpEEG
  - impedence value for EEG channels (15 minute intervals)

## Step 2- Upload data to Python
There are several Python libraries that may be of use for dealing with EEG/EMG data. 

- [MNE](https://mne.tools/stable/generated/mne.io.read_raw_edf.html) appears to be by far the essential Python library for dealing with EEG data. This can be a standalone library but look at sleepEEGpy down below for a comprehensive library.
- [pyfib](https://github.com/holgern/pyedflib) is another EDFBrowser you can run directly in python. I have not used it before but will use as a back up if I can't get figure out the above-mentioned EDF browser. This library is supposedly good for quick, low-medium grade spectral analysis visuals in real-time.

## Step 3- Pre-processing stage, removing artifact

A 'standard' data pipeline for EEG processing has been established by the National Sleep Research pipeline. [Here](https://pmc.ncbi.nlm.nih.gov/articles/PMC5976521/) is an established publication describing the worfklow or pipeline by:

- Mariani S, Tarokh L, Djonlagic I, et al. Evaluation of an automated pipeline for large-scale EEG spectral analysis: the National Sleep Research Resource. Sleep Med. 2018;47:126-136. doi:10.1016/j.sleep.2017.11.1128

[Here](https://mne.tools/stable/documentation/cookbook.html) is the "typical M/EEG workflow" according to MNE's documentation

Check out [eegFloss](https://arxiv.org/abs/2507.06433) (Python library)

[This manuscript too](https://pubmed.ncbi.nlm.nih.gov/25225154/)
- D'Rozario AL, Dungan GC 2nd, Banks S, Liu PY, Wong KK, Killick R, Grunstein RR, Kim JW. An automated algorithm to identify and reject artefacts for quantitative EEG analysis during sleep in patients with sleep-disordered breathing. Sleep Breath. 2015 May;19(2):607-15. doi: 10.1007/s11325-014-1056-z. Epub 2014 Sep 16. PMID: 25225154.

Pre-processing stage includes:
- removal of artficact prior to computation of the power spectrum. Traditionally, this involves manual inspection of EEG files and is time-consuming/labor intensive and can be prone to human error/bias.

Instead, YASA (Yet Another Sleep Algorithm) a Python library can handle this for us using the [yasa.art_detect ](https://yasa-sleep.org/generated/yasa.art_detect.html#yasa.art_detect) function

**Note:** When passing an integer array of a hypnogram's sleep stage scores, YASA follows this mapping: 
- 2 = Unscored
- 1 = Artefact / Movement
- 0 = Wake
- 1 = N1 sleep
- 2 = N2 sleep
- 3 = N3 sleep
- 4 = REM sleep

The SleepProfiler X8 system has several additional scoring options for their hypnograms including:
  - 0 = wake
  - 1 = N1
  - 2 = N2
  - 3 = N3
  - 4 = L2 (light N2)
  - 5 = REM
  - 6 = NOS (sleep not otherwise specified)
  - 9 = INVALID
  - 14 = NRH (Non-REM hypertonia)
  - 33 = Atypical N3
  - 55 = RSWA (REM sleep without atonia)

As such, these numbers will have to be paired down to be able to pass through yasa.art_detect in order to remove the artifact. 

  - 0 = wake
  - 1 = N1
  - 2 = N2
  - 3 = N3
  - 4 = ~~L2 (light N2)~~ → N2
  - 5 = REM
  - 6 = NOS ~~(sleep not otherwise specified)~~ → Unscored
  - 9 = ~~INVALID~~ → Artifact/movement
  - 14 = NRH ~~(Non-REM hypertonia)~~ → N2
  - 33 = ~~Atypical N3~~ → N3
  - 55 = ~~RSWA (REM sleep without atonia)~~ → REM

When 'hypno' is yasa.Hypnogram, string labels can be used instead of their integer values (e.g., ["N1", "N2", "N3", "REM"]).

Here's how I've updated the sleep stages (reducing the SleepProfiler scoring options) and mapped these sleep stages to hypno

```python
## How I'll revise the stages according to what YASA will accept.
stage_map = {
    0 : 'WAKE',
    1: 'N1',
    2: 'N2',
    3: 'N3',
    4: 'N2', ## Light N2 (Still N2)
    5: 'REM', 
    6: 'UNS', ## sleep not otherwise specified
    9: 'UNS', ## artifact/ INVALID
    14: 'N2',
    33: 'N3', ## atypical N3, mapped to N3
    55: 'REM' ## REM without atonia, mapped to REM
}

## updating the sleep scores
hypno_sorted = hypno.sort_values('epoch_#').copy()
hypno_sorted['yasa_stage'] = hypno_sorted['stage_final'].map(stage_map)

## verify that all epochs were mapped
print(hypno_sorted["yasa_stage"].isna().sum(), "unmapped epochs")
>>Output:
0 unmapped epochs

## map the hypnogram sequence onto hyp
stage_sequence = hypno_sorted["yasa_stage"].values
hyp = yasa.Hypnogram(stage_sequence, freq="30s")
```
**Tip:** YASA documentation recommends to apply yasa.art_detect on pre-staged data and to makue sure to pass the hypnogram. Sleep stages have very different EEG signaturs and the artifact rejection will be much more accurate when applied separately on each sleep stage. 

Additionally, this function only detects major body artifacts present on the EEG channel. It will not detect EKG contamination or eye blinks. For more artifact rejection tools, please refer to the [MNE Python library](https://mne.tools/stable/auto_tutorials/preprocessing/10_preprocessing_overview.html).




```python

hyp.n_epochs     # number of 30-s epochs
hyp.duration     # total recording duration in minutes
hyp.freq         # epoch length as a pandas offset string
hyp.n_stages     # number of sleep stages (2 / 3 / 4 / 5)


```


how to crop/isolate a range of epochs in the sleep hypnogram (could map sleep start/end times onto this when applying sleep diary data or similar.)

```python
hyp = yasa.simulate_hypnogram(tib=480, n_stages=5, seed=42)

# First epoch
hyp[0].hypno.iloc[0]

# Epochs 100 to 199
hyp[100:200]
```

**Use crop to isolate start and end times**
```python
hyp = yasa.simulate_hypnogram(tib=480, start="2024-01-15 23:00:00", seed=42)
hyp_night = hyp.crop("2024-01-15 23:30:00", "2024-01-16 06:00:00")
```

**How to get sleep statistics from hypnogram (YASA)**

```python
import pandas as pd
pd.Series(hyp.sleep_statistics())

>>returns:
TIB         480.0000
SPT         477.5000
WASO         79.5000
TST         398.0000
SE           82.9167
SME          83.3508
SFI           0.7538
SOL           2.5000
SOL_5min      2.5000
Lat_REM      67.0000
WAKE         82.0000
N1           67.0000
N2          240.5000
N3           53.0000
REM          37.5000
%N1          16.8342
%N2          60.4271
%N3          13.3166
%REM          9.4221
dtype: float64

```

# Aligning Hypnogram with EEG data

To use a hypnogram alongside raw EEG data (i.e., the imported EEG.edf file), YASA needs a sample-level label for every EEG sample, not just one per 30-second epoch. Use 'unsample_to_data' which handles this automatically. 

```python
import mne
raw = mne.io.read_raw_edf("recording.edf", preload=True)
hyp = yasa.Hypnogram.from_integers(int_hypno, freq="30s")
hypno_up = hyp.upsample_to_data(raw)

```
**Tip:** YASA v0.7, most detection functions accept a hypnogram object directly, so no manual upsampling is needed. Simply pass 'hypno = hyp'

```python
sp = yasa.spindles_detect(raw, hypno=hyp, include=["N2", "N3"])
```
The behavior of upsample_to_data depends on whether timestamp information is available. By default, YASA assumes the hypnogram and the recording start at the same time. Any length mismatch is resolved by padding or cropping at the end. This mode is always used when data is a NumPy array. It is also used when data is an mne.io.BaseRaw but either hypnogram.start is not set or raw.meas_date is None.

```python
# EDF recorded at 22:11:37 local time
hyp = yasa.Hypnogram(stages, freq="30s")
hypno = hyp.upsample_to_data(raw)
```

**Common Scenarios:**
1. **The hypnogram and EEG recordings cover the same window.**
    - the hypnogram is upsampled and fits the data exactly. Both alignment modes give the same result.
2. **Hypnogram is shorter than EEG recording.**
    - This happens when the hypnogram covers only the Lights Off to Lights On period while the PSG spans a longer window.
      - Length-based: the hypnogram is padded with Unscored ('UNS') epochs at the end.
      - Timestamp-aware: the correct number of 'UNS' epochs is prepended before Lights Off, and any remaining tail is also padded. 

```python
hyp = yasa.Hypnogram(stages, freq="30s", start="2024-01-15 23:00:00")
hypno = hyp.upsample_to_data(raw)
## Epochs before Lights Off and after Lights On become UNS
```

3. **Hypnogram is longer than the recording.**
   - This happens when working with a cropped segment of a full-night recording. 
     - Length-based: the hypnogram is cropped from the end. This is only correct if the segment starts at the very beginning of the recording. 
     - Timestamp-aware: YASA skips the correct leading epochs based on the timestamp offset and selects only the epochs that fall within the recording window. 

```python
## Full-night hypnogram, but only the second half of the night is loaded
hyp = yasa.Hypnogram(stages, freq="30s", start="2024-01-15 23:00:00")
hypno = hyp.upsample_to_data(raw_cropped)  # correct epochs selected automatically
```


# Automatic staging with SleepStaging.
When using SleepStaging, the start is attribute is populated automatically from raw.meas_date when available, so timestamp-aware alignment (should) works out of the box.

```python
sls = yasa.SleepStaging(raw, eeg_name="C4-M1")
hyp = sls.predict()  ## hyp.start set automatically from raw.meas_date
hypno = hyp.upsample_to_data(raw_cropped)
```
**Note:** The SleepProfiler X8 system lists 4 EEG channels (EEG1 through EEG4). This automatic staging relies on conventional 'cap'-based EEG channel lead names (e.g., C4-M1) and it's unclear how well this feature works for forehead wearable EEG devices. F

```python
import yasa
from sklearn.metrics import cohen_kappa_score

## Using the hypnogram as "ground truth" based on "stage_final" col from the X8 device
## 'hyp' was previously called with staged mapped, prior to this step.
ground_truth_int = hyp.as_int().to_numpy()

results = []

for ch in ["EEG1", "EEG2", "EEG3", "EEG4"]:
    print(f"Running SleepStaging on {ch}...")
    
    sls = yasa.SleepStaging(raw, eeg_name=ch)
    hypno_pred = sls.predict()  ## yasa.Hypnogram object
    
    pred_int = hypno_pred.as_int().to_numpy()
    
    ## Align lengths in case of any epoch-count mismatch
    n = min(len(ground_truth_int), len(pred_int))
    
    kappa = cohen_kappa_score(ground_truth_int[:n], pred_int[:n])
    pct_agree = (ground_truth_int[:n] == pred_int[:n]).mean() * 100
    
    results.append({
        "channel": ch,
        "kappa": kappa,
        "pct_agreement": pct_agree,
    })

comparison_df = pd.DataFrame(results).sort_values("kappa", ascending=False)
print(comparison_df)

>>Output: 
Running SleepStaging on EEG4...
  channel     kappa  pct_agreement
3    EEG4  0.665642      76.195773
1    EEG2  0.641412      74.527253
2    EEG3  0.608883      71.968854
0    EEG1  0.146769      34.705228
```
Note the kappa agreement between YASA's sleep auto-staging function and the EEG leads from the SleepProfiler X8 system. EEG channels 2–4 appear to have good kappa agreement with YASA's staging algorithm, but EEG channel 1 has poor agreement (unsure why). This is something worth looking into for the future, but for now I would recommend using whichever channel has the highest agreement if choosing to stage this way. 

```python
sls_eeg4 = yasa.SleepStaging(raw, eeg_name="EEG4")
pred_eeg4 = sls_eeg4.predict()
print(pred_eeg4.hypno.value_counts())

>>Output:
YASA
N2      380
REM     245
N3      197
WAKE     60
N1       18
ART       0
UNS       0
Name: count, dtype: int64
```

**Note:** Running the above code gave some warning about version compabability for the sklearn library. At the time of this SOP's creation, the use of SleepEEGpy required a specific version of Python. So far, only MNE and YASAS have been used independently of SleepEEGPy (which is a Python wrapper that combines both YASA, MNE, and some other libraries into one) so the Python version constraint for using SleepEEGpy may be unnecessary if not using this Python wrapper library. 















## Step 4- Calculate spectral power

Use [YASA](https://yasa-sleep.org/) (Yet Another Sleep Algorithm) to autostage the EEG data and has features (algorithms) to detect sleep spindles and slow-waves. YASA builds works in tandem with MNE. Specifically, 

- MNE's [spectrum frequency analysis](https://mne.tools/stable/auto_tutorials/time-freq/10_spectrum_class.html)

Both of these use Welch/FFT (fast Fourier transform) methods for processing signal

**Note:**

## Step 5- Sort brainwave frequencies

- Bandpower() in YASA returns detected EEG wave frequencies (delta/theta/sigman/alpha/beta)

## Step 6- Identify sleep microarchitecture



# References
- Lacourse K, Delfrate J, Beaudry J, Peppard P, Warby SC. A sleep spindle detection algorithm that emulates human expert spindle scoring. J Neurosci Methods. 2019;316:3-11. doi:10.1016/j.jneumeth.2018.08.014
- Tsanas A, Clifford GD. Stage-independent, single lead EEG sleep spindle detection using the continuous wavelet transform and local weighted smoothing. Front Hum Neurosci. 2015;9:181. Published 2015 Apr 8. doi:10.3389/fnhum.2015.00181
- O'Reilly C, Godbout J, Carrier J, Lina JM. Combining time-frequency and spatial information for the detection of sleep spindles. Front Hum Neurosci. 2015;9:70. Published 2015 Feb 19. doi:10.3389/fnhum.2015.00070
- Lajnef T, Chaibi S, Eichenlaub JB, et al. Sleep spindle and K-complex detection using tunable Q-factor wavelet transform and morphological component analysis. Front Hum Neurosci. 2015;9:414. Published 2015 Jul 28. doi:10.3389/fnhum.2015.00414
- [YASA sleep spindle detection](https://yasa-sleep.org/generated/yasa.spindles_detect.html)
- 


