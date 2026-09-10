# 🐟 Marmara Sea Fish Analysis

A data analysis and machine learning project focused on the **morphometric characteristics of fish species from the Marmara Sea**.

The project combines **SAS**, **Python**, and **Streamlit** to analyze biological characteristics, identify natural size groups, predict commercial value, estimate fish weight, and explore applications for fishery management and digital seafood markets.

## 📊 Dataset

The project uses the `marmara2.csv` dataset containing:

- **1,760 observations**
- **10 fish species**
- **6 morphometric features**
- No missing values detected

### Features

- `total_length_cm`
- `body_depth_cm`
- `body_width_cm`
- `head_length_cm`
- `eye_diameter_mm`
- `weight_gr`
- `species`

Fish are also classified into commercial groups, including a **High-Value** category containing **Palamut, Lüfer, and Kalkan**.

## 🎯 Project Objectives

The main objectives of the project are to:

- Analyze morphometric differences between fish species
- Perform data cleaning and statistical analysis
- Identify natural fish size groups
- Predict High-Value vs. Standard market tiers
- Estimate fish weight using physical measurements
- Integrate biological data with market and conservation information
- Support automated fish sorting and market-grade pricing
- Create an interactive dashboard for exploring the results

## 🛠️ Technologies Used

### SAS

SAS is used for structured data processing and statistical analysis, including:

- CSV data import
- User-defined formats
- DATA step processing
- Conditional and iterative processing
- Dataset subsets
- SAS functions
- Arrays
- `MERGE` and `SET`
- SQL joins
- `PROC REPORT`
- `PROC TABULATE`
- Descriptive statistics
- Correlation analysis
- Regression
- Logistic regression
- Clustering
- Graph generation
- Macro-based automated reporting

### Python

The Python application uses:

- **Pandas** — data manipulation and aggregation
- **NumPy** — numerical processing
- **Matplotlib** — visualization
- **Seaborn** — statistical visualization
- **Scikit-learn** — preprocessing, clustering and classification
- **Statsmodels** — statistical regression
- **Streamlit** — interactive dashboard

## 🖥️ Streamlit Application

The project includes an interactive Streamlit dashboard:

```text
python_app/marmara_fish_app.py
```

The dashboard is divided into nine main sections.

### 1. Data Overview & Missing Values

Provides:

- Dataset preview
- Descriptive statistics
- Missing-value analysis
- Duplicate detection
- Z-score outlier detection
- Species distribution

### 2. Encoding Methods

Demonstrates categorical encoding using:

- Label Encoding
- One-Hot Encoding

These transformations prepare the species variable for machine learning models.

### 3. Scaling Methods

Compares:

- StandardScaler
- MinMaxScaler

Scaling prevents variables with large numerical ranges, particularly fish weight, from dominating distance-based machine learning algorithms.

### 4. Statistical Processing & Aggregation

Includes:

- Pandas `groupby()`
- Aggregation
- Pivot tables
- Correlation analysis
- Skewness
- Kurtosis
- Species-level comparisons

### 5. Merge / Join Operations

The biological dataset is enriched with additional information such as:

- Market prices
- English species names
- Market tiers
- Conservation status

Different join strategies are demonstrated using `pd.merge()`.

### 6. Data Visualisation

The application generates several visualizations, including:

- Scatter plots
- Histograms
- Bar charts
- Violin plots
- Bubble charts
- Correlation visualizations

These graphs help reveal relationships between fish length, weight, species, and other morphometric characteristics.

## 🤖 Machine Learning

### K-Means Clustering

K-Means clustering is used to discover natural groups of morphologically similar fish without using species labels.

The analysis uses:

- Standardized morphometric features
- Elbow Method
- Silhouette Score
- PCA visualization

The analysis identifies an optimal solution of:

**4 natural fish clusters**

These clusters can represent different size grades and could potentially support automated fish-sorting systems.

### Logistic Regression

A Logistic Regression model predicts whether a fish belongs to:

```text
High-Value
```

or:

```text
Standard
```

using only morphometric measurements.

High-Value species are defined as:

- Palamut
- Lüfer
- Kalkan

Model evaluation includes:

- Accuracy
- Classification report
- Confusion matrix
- Feature coefficients

Weight and body depth are among the strongest predictors of commercial tier.

### Statsmodels Multiple Regression

Ordinary Least Squares regression is used to estimate fish weight from physical measurements.

Predictors include:

- Length
- Body depth
- Body width
- Head length
- Eye diameter

Both raw and log-transformed models are investigated.

The log-transformed model explains **more than 97% of the variation in fish weight**, demonstrating that morphometric measurements can provide highly accurate weight estimates.

## 📈 Main Findings

The analysis produced several important observations:

- The dataset contains **1,760 usable observations across 10 species**.
- **Hamsi** represents the largest commercial class in the dataset.
- Large species such as **Kalkan and Palamut** contain many of the extreme weight observations.
- Fish length measurements show very strong correlations, supporting expected biological allometric growth.
- K-Means identifies **four natural size groups**.
- Logistic Regression can distinguish High-Value fish using morphometric characteristics.
- Weight and body depth are particularly useful predictors of commercial value.
- Log-transformed regression can explain **over 97% of fish weight variance**.
- Biological information can be combined with market prices and conservation information to create business-oriented indicators.

## 💼 Business Applications

The project demonstrates how data analytics could support real-world fishery operations.

Possible applications include:

- 🐟 Automated fish sorting
- ⚖️ Weight estimation without physical scales
- 💰 Market-grade pricing
- 📦 Processing-line classification
- 📊 Fish stock assessment
- 🚨 Detection of undersized catches
- 🌊 Fishery regulation compliance
- 🏪 Digital seafood marketplaces
- 📈 Commercial value prediction

For example, morphometric measurements captured from cameras could potentially be used to estimate fish weight and automatically route high-value catches toward premium processing lines.

## 📁 Project Structure

```text
Marmara-Sea-Fish-Analysis/
│
├── marmara2.csv
│
├── sas/
│   └── marmara_fish_analysis.sas
│
├── python_app/
│   └── marmara_fish_app.py
│
└── README.md
```

## 🚀 Running the Streamlit Application

Install the required Python packages:

```bash
pip install streamlit pandas numpy matplotlib seaborn scikit-learn statsmodels
```

Then start the application:

```bash
streamlit run python_app/marmara_fish_app.py
```

The Streamlit interface should automatically open in your browser.

## 📌 SAS Analysis

The SAS component can be found at:

```text
sas/marmara_fish_analysis.sas
```

Make sure the path to `marmara2.csv` is configured correctly before running the SAS script.

The SAS analysis demonstrates data preparation, user-defined formats, arrays, SQL joins, reporting procedures, statistical procedures, visualizations, and automated reporting.

## 🔮 Potential Applications

The combined SAS and Python workflow could form the basis of a **smart fishery management system**.

Morphometric measurements could potentially be collected directly at docks and processing facilities, allowing systems to:

1. Estimate fish weight
2. Determine size grades
3. Identify high-value catches
4. Check regulatory compliance
5. Estimate market value
6. Automatically route fish through processing lines


## 📚 Project Context

This project demonstrates an end-to-end analytical workflow combining traditional statistical analysis with modern interactive data science and machine learning techniques.

SAS provides structured enterprise-level data preparation, reporting, statistical analysis, and automation, while Python and Streamlit provide interactive visualization and predictive modeling.
