# Proteomics Data

The **purpose** of this pilot investigation was to examine the proteome's response to chronic high-intensity training in recreationally active adult females (n=7) following a three-week training protocol under laboratory conditions.

Based on previous exercise-based proteomics research, **we hypothesized that, following the exercise intervention, there would be a proteomic response associated with an increase in acute-phase immune system activity.** 

## Executive summary
Using Python, Microsoft Excel, and the [String database](https://string-db.org/), I examined a set of 380 proteins and determined which proteins were up and downregulated after three weeks of high-intensity exercise training, and then after three weeks of recovery. 
- 206 proteins were present among all 21 plasma samples (7 subjects, 3 timepoints); 209 proteins were present from baseline (BL) to post-training (MID); 219 proteins were identified between BL and post-recovery (END) timepoints.
- 39 unique proteins were upregulated (n=33) or downregulated (n=6) at MID or END timepoints (P<0.1). 
- 19 of the upregulated proteins at either MID and/or END timepoints were associated with the acute-phase immune system response. 
- These findings support our hypothesis that chronic high-intensity exercise may cause a prolonged increase in the acute-phase immune response. 
  - Additionally, our results support findings from previous exercise-based proteomics studies that found altered acute-phase response-related proteins in overtrained athletes. 
  
**Proteins upregulated after training (MID) and after recovery (END):**
![All upregulated proteins](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/All_upregulated_PRO.png)

**Example of STRING pathways**
![STRING pathways](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/STRING_pathways_example.png)

**Protein-Protein Interaction Network of acute-phase immune-related proteins:**
![Immune PPI network](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/Immune_PRO_PPI.png) 

## Next steps
- Use results of this pilot investigation as preliminary data for larger grants to fund future proteomics research with larger sample sizes. 
- Re-examine the existing dataset to look at proteins that did not have 100% retention rate in all samples (i.e., consider proteins present in >85% of samples). 
- Build advanced PPI networks and visuals using [Cytoscape](https://www.youtube.com/watch?v=Ohf9IPUJ82w).

## The problem
Overtraining is an adverse physiological response caused by excessive training and inadequate recovery. The pathophysiological mechanisms of overtraining are unknown and there remains an absence of sensitive objective diagnostic criteria to identify overtraining or predict its impending occurence. 

Large-scale top-down proteomics has the potential to identify upstream biomarkers of overtraining; however, few studies have used large-scale proteomics in exercise-based, human research. 

- **The purpose of this pilot investigation was to examine the proteome's response to chronic high-intensity training in recreationally active adult females (n=7) following a three-week training protocol under laboratory conditions.**

## Data analysis methodology (Python)
1. Performed data wrangling and cleaning of proteomics dataset using Python; calculated log2 fold change of proteins at different timepoints 
2. Using Python, conducted statistical analyses of up- and down-regulated proteins between 2-3 different timepoints using the Friedman test (non-parametric repeat-measures ANOVA) and the Wilcoxon Signed-Rank test (non-parametric dependent samples T-test).
3. Built protein-protein interaction (PPI) networks using [String database](https://string-db.org/) to examine relationships of up- and down-regulated proteins to identify biological mechanisms potentially affected by exercise.

```python
df= pd.read_csv("Gooding Proteomics dataset 1.17.24.csv")

df.columns=df.columns.str.lower()

df.head()

```
### Visual of original dataframe to see how it's not structured properly for analysis
![Origianl proteomics df](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/original_PRO_table.png)

```python
df_transposed = df.drop(columns=['accession']).T.copy()
df_transposed.reset_index()
df_transposed.columns = col_names

df_transposed.reset_index(inplace=True)

df_transposed.rename(columns={'index':'subject_id'}, inplace=True)
df_transposed.columns = df_transposed.columns.str.lower()

df_transposed['subject_id'] = df_transposed['subject_id'].str.replace('.1', '').str.replace('.2', '')

df_transposed.head()
```
Data is organized and ready for analysis.
```python
### isolate cols of all proteins in dataset
protein_cols = np.array(df_transposed.columns[2:])

protein_cols

df_transposed[protein_cols]=df_transposed[protein_cols].apply(pd.to_numeric, errors='coerce')

### isolate DFs of each timepoint. will determine log2 foldchange from BL_df abundance values
df_BL= df_transposed[df_transposed['time']=='BL'].copy()
df_Rec2=df_transposed[df_transposed['time']=='Rec2'].copy()
df_Rec21=df_transposed[df_transposed['time']=='Rec21'].copy()

### keep proteins with at least 85% samples (6/7)
df_BL_cleaned = df_BL.loc[:, df_BL.nunique(dropna=True) >= 6].copy().reset_index(drop=True)
df_BL_cleaned['time'] = ['baseline']*7

# cols_to_keep
cols_to_keep = list(set(df_BL_cleaned.columns) & set(df_Rec2_cleaned.columns))

df_BL_Rec2_cleaned = pd.concat([df_BL_cleaned[cols_to_keep], df_Rec2_cleaned[cols_to_keep]], ignore_index=True)

df_BL_Rec2_cleaned = pd.concat([df_BL_cleaned[cols_to_keep], df_Rec2_cleaned[cols_to_keep]], ignore_index=True)

### reset columns to have subject_id and time be first two cols
first_cols = ['subject_id', 'time']
other_cols = [col for col in df_BL_Rec2_cleaned.columns if col not in first_cols]

ordered_cols = [col for col in first_cols if col in df_BL_Rec2_cleaned.columns] + other_cols

df_BL_Rec2_cleaned = df_BL_Rec2_cleaned[ordered_cols]

df_BL_Rec2_cleaned.head(15)
```
![Wrangled data table](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/wrangled_PRO_table_rec2.png)
### Calculate log2 fold change

```python
## Calculate log2 fold change BL to rec2
df_BL_Rec2_cleaned_BL = df_BL_Rec2_cleaned[df_BL_Rec2_cleaned['time']=='baseline'].copy().reset_index(drop=True)
df_BL_Rec2_cleaned_rec2 = df_BL_Rec2_cleaned[df_BL_Rec2_cleaned['time']=='rec2'].copy().reset_index(drop=True)
df_BL_Rec2_cleaned_rec2.head(15)

df_BL_Rec2_cleaned_BL_FC = df_BL_Rec2_cleaned_BL.copy().reset_index(drop=True)
df_BL_Rec2_cleaned_rec2_FC = df_BL_Rec2_cleaned_rec2.copy()

### calculating fold change for each timepoint, based on baseline abundance values
df_BL_Rec2_cleaned_BL_FC[test_cols] = np.log2(df_BL_Rec2_cleaned[test_cols]/ df_BL_Rec2_cleaned[test_cols])
df_BL_Rec2_cleaned_rec2_FC[test_cols] = np.log2(df_BL_Rec2_cleaned_rec2[test_cols]/ df_BL_Rec2_cleaned[test_cols])

df_BL_Rec2_cleaned_rec2_FC.head(15)
df_log2FC_merged = pd.concat([df_BL_Rec2_cleaned_BL_FC, df_BL_Rec2_cleaned_rec2_FC], ignore_index=True)

df_log2FC_merged.head()
```
![Rec2 fold change table](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/bl_rec2_df_FC_table.png)
### Visually inspect proteins that were most up- or down-regulated.
```python
# identify unique timepoints
unique_timepoints = ['Rec2']

# Create a DataFrame to store average values and standard errors
# visuals_df = pd.DataFrame(columns=['Protein', 'Time', 'Average', 'SEM'])

## isolate relevant protein cols for this visual
df_Rec2_log2FC = df_Rec2_log2_fold_change.columns[2:]

## create empty list for calculated fold change mean + sem values for each protein 
new_rows = []
# Iterate over each protein column
for protein in df_Rec2_log2FC:
    # Iterate over each timepoint
    for timepoint in unique_timepoints:
        # Calculate the average and standard error for the current protein and timepoint
        subset = df_Rec2_log2_fold_change[df_Rec2_log2_fold_change['time']==timepoint]

        avg_val = subset[protein].mean()
        sem_val = subset[protein].sem()
        
        # Concatenate the result to the new_rows DataFrame to be concatenated with visuals_df
        new_rows.append({
            'Protein': protein,
            'Time': timepoint,
            'Average': avg_val,
            'SEM': sem_val
        })

        visuals_df = pd.DataFrame(new_rows)

# Select the 50 proteins with the **highest average values**
top_proteins = visuals_df.groupby('Protein')['Average'].mean().nlargest(50).index

# Filter the DataFrame for only those proteins and timepoints
filtered_df_top = visuals_df[
    (visuals_df['Protein'].isin(top_proteins)) &
    (visuals_df['Time'].isin(unique_timepoints))
].sort_values(by='Average', ascending=False)

# --- PLOTTING SECTION ---
for timepoint in unique_timepoints:
    plt.figure(figsize=(12, 15))

    # Barplot without built-in error bars
    ax = sns.barplot(
        x='Average', y='Protein',
        data=filtered_df_top[filtered_df_top['Time'] == timepoint],
        errorbar=None
    )

    # Add error bars manually
    for i, row in enumerate(filtered_df_top[filtered_df_top['Time'] == timepoint].itertuples()):
        plt.errorbar(x=row.Average, y=i, xerr=row.SEM, color='black', capsize=5)

    plt.title(f'Top 50 Upregulated Proteins - Average (±SEM) at {timepoint}')
    plt.xlabel('Average Value')
    plt.ylabel('Protein')

    # Visual formatting
    ax.set_ylim(bottom=ax.get_ylim()[0] - 0.5, top=ax.get_ylim()[1] + 1)
    ax.tick_params(axis='y', labelsize=12)
    plt.axvline(x=0, ls='--', color='red', lw=2)

    plt.show()
```
### I visualized the 50 most upregulated proteins
![Upregulated Rec2 Proteins](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/Upregulated_PRO_rec2.png)
### I also visualized the downregulated proteins
![Downregulated Rec2 proteins](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/Downregulated_PRO_rec2.png)

### Calculate significant differences in protein abundance for each protein from BL to MID (rec2) using Wilcoxon signed rank test (SciPy)
```python
import pandas as pd
from scipy.stats import wilcoxon

# Assuming you have a dataframe with protein abundance values (df_Log2_BL_Rec2_FC) and protein_cols defined

# Extract the relevant columns for the paired observations (e.g., 'BL' and 'Rec2' timepoints)
column_BL = 'BL'
column_Rec2 = 'Rec2'

# Create an empty list to store the results
wilcoxon_results = []

# Iterate over each protein column
for protein in df_Rec2_log2FC:
    # Select the data for the paired observations using loc
    data_BL = df_Log2_BL_Rec2_FC.loc[df_Log2_BL_Rec2_FC['time'] == column_BL, protein]
    data_Rec2 = df_Log2_BL_Rec2_FC.loc[df_Log2_BL_Rec2_FC['time'] == column_Rec2, protein]

    # Perform Wilcoxon signed-rank test
    statistic, p_value = wilcoxon(data_BL, data_Rec2)
    
    rounded_p_value = round(p_value, 3)

    # Append the results to the list
    wilcoxon_results.append({
        'Protein': protein,
        'Wilcoxon Statistic': statistic,
        'P-value': rounded_p_value
    })

# Create a DataFrame from the list of results
wilcoxon_df_BL_to_Rec2 = pd.concat([pd.DataFrame([result]) for result in wilcoxon_results], ignore_index=True)

print("Wilcoxon Signed-Rank Test Results:")
wilcoxon_df_BL_to_Rec2
```
![Wilcoxon results](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/rec2_wilcoxon_results_table.png)

### Add protein descriptions and average fold change values to Wilcoxon results table. 
```python
p_vals = wilcoxon_df_BL_to_Rec2['P-value'].values.tolist()

reject, corrected_pvals= smm.fdrcorrection(p_vals,
                 alpha=0.5,
                 is_sorted=False)

# Add the 'reject' and 'corrected_pvals' columns to the statistics DF
wilcoxon_df_BL_to_Rec2['reject'] = reject
wilcoxon_df_BL_to_Rec2['corrected_p_value'] = corrected_pvals

wilcoxon_df_BL_to_Rec2

## Isolate which proteins had a signficant log2 FC from BL to rec2 (P-val <=0.1)
bl_rec2_sig_pro = wilcoxon_df_BL_to_Rec2[wilcoxon_df_BL_to_Rec2['P-value']<=0.1].copy().reset_index(drop=True)

df_Rec2_log2_FC_prot = df_Rec2_log2_fold_change.columns[2:]

df_rec2_FC = df_Rec2_log2_fold_change[df_Rec2_log2_FC_prot].mean().reset_index().rename(columns={'index':'Protein', 0:'AVG_FC'
                                                                                                })

## merge fold change average to each significant protein in a single DF
bl_rec2_sig_pro_FC = pd.merge(bl_rec2_sig_pro, df_rec2_FC[['Protein', 'AVG_FC']], how='inner', on='Protein')

## Add in df of protein accession number and description (name) of each protein
protein_names_df = pd.read_excel('/Users/thomasgooding/Desktop/2025 proteomics data/Gooding Proteomics 10.30.23 (original dataset).xlsx', usecols=['Accession', 'Description'])
protein_names_df['Accession'] = protein_names_df['Accession'].str.lower()

protein_names_df.head()

```
![Protein descriptions](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/protein_description_table.png)
```python
### Adding protien descriptions to each final results of BL to Rec2 df
bl_rec2_sig_pro_FC_final = pd.merge(bl_rec2_sig_pro_FC,protein_names_df[['Accession','Description']], left_on='Protein', right_on='Accession', how='inner' )

bl_rec2_sig_pro_FC_final['time'] = 'MID'

### Adding protien descriptions to each final results of BL to rec21 df
bl_rec21_sig_pro_FC_final = pd.merge(bl_rec21_sig_pro_FC,protein_names_df[['Accession','Description']], left_on='Protein', right_on='Accession', how='inner' )

bl_rec21_sig_pro_FC_final['time'] = 'END'

## merge Wilcoxon results from BL_rec2_df and BL_rec21_df results together

all_FC_df = pd.concat([bl_rec2_sig_pro_FC_final,bl_rec21_sig_pro_FC_final], ignore_index=True)

all_FC_df
```
![Wilcoxon results table](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/merged_wilcoxon_results.png)

### Run Friedman analysis of protein fold change from BL to MID and END timepoints (1x3 RM ANOVA, non-parametric).

```Python
### isolate proteins that show up at all 3 timepoints in 100% of samples (21 samples, n=7 participants, 3 timepoints each)
protein_cols_3tp = np.array(df_three_visits.columns[2:])

len(protein_cols_3tp)
## 206 proteins present in all samples

df_BL_3tp= df_three_visits[df_three_visits['time']=='BL'].copy().reset_index(drop=True)

df_Rec2_3tp= df_three_visits[df_three_visits['time']=='Rec2'].copy().reset_index(drop=True)

df_Rec21_3tp= df_three_visits[df_three_visits['time']=='Rec21'].copy().reset_index(drop=True)

df_BL_3tp_log2_fold_change = df_BL_3tp.copy()
df_BL_3tp_log2_fold_change[protein_cols_3tp] = np.log2(df_BL_3tp[protein_cols_3tp]/ df_BL_3tp[protein_cols_3tp])

# Calculate log2 fold change for df_Rec2 (log2(B/A))
df_Rec2_3tp_log2_fold_change = df_Rec2_3tp.copy()
df_Rec2_3tp_log2_fold_change[protein_cols_3tp] = np.log2(df_Rec2_3tp[protein_cols_3tp] / df_BL_3tp[protein_cols_3tp])

# Calculate log2 fold change for df_Rec21 (log2(C/A))
df_Rec21_3tp_log2_fold_change = df_Rec21_3tp.copy()
df_Rec21_3tp_log2_fold_change[protein_cols_3tp] = np.log2(df_Rec21_3tp[protein_cols_3tp] / df_BL_3tp[protein_cols_3tp])

### bring all fold change values back into one df
df_3tp_log2_fold_change= pd.concat([df_BL_3tp_log2_fold_change,
                                    df_Rec2_3tp_log2_fold_change,
                                    df_Rec21_3tp_log2_fold_change],
                                  ).reset_index(drop=True)

### plotted most up- and down-regulated proteins for these two timepoints (Skipped here but present in full Python code)
```
### Run Friedman Test
```python
import pingouin as pg

# Get unique timepoints (not strictly needed for pg.friedman but fine to keep)
unique_timepoints = df_3tp_log2_fold_change['time'].unique()

friedman_results = []

for protein in protein_cols_3tp:
    results = pg.friedman(
        data=df_3tp_log2_fold_change,
        dv=protein,
        within='time',
        subject='subject_id',
        method='f'
    )

    # Ensure the index is numeric (fixes the KeyError: 0 issue)
    results = results.reset_index(drop=True)

    # Extract F and p values safely
    f_val = results.loc[0, 'F']
    p_val = results.loc[0, 'p-unc']

    friedman_results.append({
        'Protein': protein,
        'F-statistic': f_val,
        'P-value': p_val
    })

# Combine all results into one DataFrame
friedman_df = pd.DataFrame(friedman_results)

### sort by p-values for False Discovery Rate (FDR) adjustment
friedman_df.sort_values(by='P-value', ascending=True, inplace=True)

### adjust p-value for multiple comparisons using Benjamini-Hochberg method
p_vals_3tp = friedman_df['P-value'].values.tolist()

reject, corrected_pvals_3tp = smm.fdrcorrection(p_vals_3tp,
                                                alpha=0.5,
                                                is_sorted=True)
friedman_df['reject'] = reject
friedman_df['p-adj'] = corrected_pvals_3tp

## adding protein descriptions
visuals_df_3tp_grouped = visuals_df_3tp.groupby(['Protein', 'Time'], as_index=False, observed=True)['Average'].mean()

three_tp_df = pd.merge(visuals_df_3tp, protein_names_df[['Accession','Description']],
                       left_on='Protein', right_on='Accession', how='left').drop(columns='Accession')
### add relative fold change from BL values for each protein at both Rec2 and Rec21 timepoints
three_tp_df_rec2 = three_tp_df[three_tp_df['Time']=='Rec2'].copy().reset_index()
three_tp_df_rec21 = three_tp_df[three_tp_df['Time']=='Rec21'].copy().reset_index()

## Map average fold change for each protein timepoint to the friedman_df
rec2_protein_to_avg = three_tp_df_rec2.set_index('Protein')['Average']
rec21_protein_to_avg = three_tp_df_rec21.set_index('Protein')['Average']

friedman_df['Rec2_FC_avg'] = friedman_df['Protein'].map(rec2_protein_to_avg)
friedman_df['Rec21_FC_avg'] = friedman_df['Protein'].map(rec21_protein_to_avg)

### 
friedman_df['Protein'] = friedman_df['Protein'].str.lower()
friedman_df_final = pd.merge(friedman_df,protein_names_df[['Accession', 'Description']],
                             left_on='Protein', right_on='Accession', how='inner').drop(columns='Accession')

### isolate proteins with significant fold change from BL (P<0.1) determined during Friedman Test

friedman_df_final.sort_values(by='P-value', ascending=True, inplace=True)

friedman_df_final_sig = friedman_df_final[friedman_df_final['P-value']<=0.1].copy().reset_index(drop=True)

friedman_df_final_sig
```
![Friedman final results table](https://raw.githubusercontent.com/Tom-Gooding/Portfolio/main/Data_Projects/proteomics_analysis/proteomics_figures/Friedman_sig_PRO_results_table.png)


## Additional Study methodology

### Experimental design 
- Study participants (n=7 females) underwent a three-week high-intensity training protocol exercising six days per week under laboratory conditions. An overview of the training protocol is shown below. Training sessions weere a mix of long-duration, interval, and sprint-like training sessions on a cycle ergometer. Workloads for all training sessions were calculated as a percentage of each individual's peak workload (PWL) achieved during performance testing. 

### Exercise testing
- A graded exercise test (GXT) until volitional exhaustion served as the performance test. Warm-up included cycling for five minutes at 25% PWL from the GXT first performed during the intake visit. The GXT began immediately following warm-up with starting workload set at 75W (females) or 100W (males). Workload increased every two minutes by 30W (females) or 45W (males) until volitional exhaustion, or until participants were unable to maintain a cadence greater than 60rpm. Subjects then proceeded through a five-minute cooldown using the same power output as the warm-up.

### Dried Blood Spot Collection and high-performance liquid chromatography mass spectrometry
- Dried blood spots (DBS) samples were collected via finger prick onto standard blood spot cards (Whatman protein saver cards, Sigma-Aldrich, St. Louis, MO, USA). DBS Samples were collected at BL, MID, and END timepoints.
- Proteomic analysis of processed DBS samples were performed using an ultra-HPLC system (Easy nanoLC 1000, Thermo Scientific) coupled to a Fusion Orbitrap Tribrid mass spectrometer (Thermo Scientific) in data-dependent acquisition (DDA) mode. A Fusion Orbitrap Tribrid mass spectrometer (Thermo Scientific) was used for peptide MS/MS analysis. Raw data was processed using Proteome Discoverer (v2.2) and searched against the human proteome (downloaded from UniProt on December 28, 2020) using the SEQUEST HT engine.

### Proteomic Analysis
- Whole blood was collected via fingerprick on dried blood spot cards and proteome analysis was conducted using liquid chromatography-mass spectrometry.
- Relative abundance of each protein was provided by a third-party research lab who conducted the chromatography. 
- calculating log2 fold-change ratios with abundance values at BL serving as the reference period. Not all proteins were identified at all three timepoints in all samples. 
- The Friedman test (non-parametric repeat-measures ANOVA) was used to compare protein abundance for all proteins shared among the three timepoints. 
- Wilcoxon signed-rank tests (non-parametric dependent samples T-tests) were used to compare protein abundance for all proteins shared between BL and MID timepoints, and between BL and END timepoints. 
- In line with previous systems biology approaches, unadjusted P-values (p≤0.1) were used to determine significant fold change. All data analysis was conducted using Statsmodels (v0.13.2) SciPy (v11.1.4) and Pingouin (0.5.4) libraries in Python.

### Protein-Protein Interaction Network Analysis 
- Proteins with significant changes in abundance across time were mapped onto STRING v12 (search tool for the retrieval of interacting genes and proteins) to build and investigate protein-protein interaction (PPI) networks. STRING v12 is a database of known and predicted physical functional protein associations based on data mining, genomic context, high-throughput experimentation co-expression, and previous knowledge (https://string-db.org/).

## Results

### Proteomics Analysis
- A total of 380 unique proteins were identified from the proteomics
procedures. 206 proteins were identified among all 21 samples (seven subjects, three timepoints), resulting in a recovery rate of 54.2%. The recovery rate between BL and MID timepoints and BL and END timepoints was 55% (209 proteins) and 58% (219 proteins), respectively. 
- A total of 39 proteins were up- or downregulated from BL to MID or END timepoints. All upregulated proteins (n=33) from the three tests were grouped together to construct an upregulated protein-protein interaction (PPI) network.
- Six proteins were downregulated from BL at either MID (P43487, P07195, P22061), END (P07451, P55072) or both (Q9BTM1) timepoints. As such, there was an insufficient number of downregulated proteins to construct a downregulated PPI network.

### Upregulated Proteins from Baseline to 48-hours post-training (MID) and post-recovery (END) timepoints
 - Of these 39 proteins, 19 were immune-related and entered into STRING. The mean log2-fold change for upregulated immune-related proteins was 0.456 ± 0.213 at MID and 0.572 ± 0.306 at END, with an average local cluster coefficient of 0.706 (P<0.001). 
 - Reactome Pathway terms from STRING supported an increase in proteins related to the innate immune system, fibrin clot formation, regulation of complement system, platelet degranulation, and neutrophil degranulation (Table 4.5, Figure 4.4).

### Conclusion 
- This study investigated the proteome in seven recreationally active females, who underwent a three-week high-intensity training protocol. To our knowledge, this study is the first study to examine how chronic high-intensity exercise may influence the proteome using large-scale proteomics. Multiple proteins related to the innate immune system (complement activation, neutrophil degranulation, platelet degranulation, and fibrin clot formation) were upregulated immediately following the training phase (MID) and three weeks after the cessation of training (END). 
- Together, the findings of this study suggest that excessive or recurring high-intensity exercise may generate a chronic inflammatory response and supports the findings of previous exercise-based proteomics research, which has found similar evidence of immune dysfunction following exhaustive exercise or ultra-endurance events. Future studies with larger samples sizes are warranted to further investigate the effects of prolonged or excessive exercise/physical activity on the immune system in a variety of populations.