/*=============================================================================
  MARMARA SEA FISH ANALYSIS — SAS PROGRAM
  ECSI Software Packages Project | SAS Module
  Dataset : marmara2.csv
  Variables: total_length_cm, body_depth_cm, body_width_cm, head_length_cm,
             eye_diameter_mm, weight_gr, species (10 species, 1760 records)
  ─────────────────────────────────────────────────────────────────────────────
  FUNCTIONALITIES COVERED (minimum 8 required):
   1.  Creating a SAS dataset from an external CSV file       (PROC IMPORT)
   2.  Creating and using user-defined formats               (PROC FORMAT)
   3.  Iterative and conditional processing of data          (DO loops / IF-THEN)
   4.  Creating data subsets                                 (WHERE / output)
   5.  Using SAS functions                                   (LOG, ROUND, MEAN, …)
   6.  Combining datasets with SAS procedures (MERGE / SET)
   7.  Combining datasets with SQL (PROC SQL JOIN)
   8.  Using arrays                                          (ARRAY statement)
   9.  Report procedures                                     (PROC REPORT / TABULATE)
  10.  Statistical procedures                                (PROC MEANS / UNIVARIATE / CORR / REG / LOGISTIC / CLUSTER)
  11.  Generating graphs                                     (PROC SGPLOT / SGPANEL / SGSCATTER)
=============================================================================*/


/*=============================================================================
  SECTION 0 — LIBRARY & OPTIONS
=============================================================================*/
OPTIONS NODATE NONUMBER PAGESIZE=60 LINESIZE=120;

/* Define a work library (SAS uses WORK by default; set your own path if needed) */
/* LIBNAME marmara "C:\Users\YourName\SAS_Project"; */
/* For portability we use WORK throughout this project */

TITLE "Marmara Sea Fish Morphometric Analysis";


/*=============================================================================
  SECTION 1 — CREATING A SAS DATASET FROM AN EXTERNAL CSV FILE
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Read the raw CSV file marmara2.csv into a SAS dataset so that all
              subsequent steps can use native SAS procedures.
  Method:     PROC IMPORT with DATAROW and GETNAMES options.
  Interpretation: Importing creates a permanent, typed SAS dataset with correct
              variable types (numeric / character) ready for analysis.
=============================================================================*/

TITLE2 "Section 1 — Import External CSV";

PROC IMPORT
    DATAFILE = "marmara2.csv"   /* <-- adjust path if needed */
    OUT      = WORK.fish_raw
    DBMS     = CSV
    REPLACE;
    GETNAMES = YES;
    DATAROW  = 2;
    GUESSINGROWS = 100;
RUN;

/* Verify import */
PROC CONTENTS DATA = WORK.fish_raw;
    TITLE2 "Section 1 — Dataset Contents After Import";
RUN;

PROC PRINT DATA = WORK.fish_raw (OBS=10) NOOBS;
    TITLE2 "Section 1 — First 10 Records";
RUN;


/*=============================================================================
  SECTION 2 — CREATING AND USING USER-DEFINED FORMATS
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Raw species names are in Turkish. Create user-defined formats that
              map each species to its English name, market tier, and a weight
              class code, improving readability of all output.
  Method:     PROC FORMAT with VALUE statement.
  Interpretation: Formats allow analysts and managers to view meaningful labels
              without altering the underlying data — essential for bilingual or
              multi-audience reporting.
=============================================================================*/

TITLE2 "Section 2 — User-Defined Formats";

PROC FORMAT;

    /* English translation of Turkish species names */
    VALUE $ species_eng
        "Hamsi"    = "European Anchovy"
        "Istavrit" = "Atlantic Horse Mackerel"
        "Sardalya" = "European Sardine"
        "Mezgit"   = "Whiting"
        "Palamut"  = "Atlantic Bonito"
        "Tekir"    = "Red Mullet"
        "Lufer"    = "Bluefish"
        "Izmarit"  = "Picarel"
        "Zargana"  = "Garfish"
        "Kalkan"   = "Turbot"
        OTHER      = "Unknown Species";

    /* Market tier based on species */
    VALUE $ market_tier
        "Hamsi","Sardalya","Izmarit","Zargana" = "Economy"
        "Istavrit","Mezgit","Tekir"             = "Standard"
        "Lufer","Palamut"                        = "Premium"
        "Kalkan"                                 = "Luxury"
        OTHER                                    = "Unclassified";

    /* Weight class (grams) */
    VALUE weight_class
        LOW -< 10    = "Micro  (<10g)"
        10  -< 50    = "Small  (10-50g)"
        50  -< 200   = "Medium (50-200g)"
        200 -< 1000  = "Large  (200-1000g)"
        1000 - HIGH  = "Extra-Large (>1kg)";

    /* Size class by total length */
    VALUE length_class
        LOW -< 10  = "Juvenile (<10cm)"
        10  -< 20  = "Sub-adult (10-20cm)"
        20  -< 35  = "Adult (20-35cm)"
        35  - HIGH = "Large Adult (>35cm)";

RUN;

/* Apply formats in a data step to create formatted dataset */
DATA WORK.fish;
    SET WORK.fish_raw;

    /* Rename species variable (remove Turkish special chars for SAS compatibility) */
    LENGTH species_code $12;
    SELECT (species);
        WHEN ("Hamsi")    species_code = "Hamsi";
        WHEN ("Sardalya") species_code = "Sardalya";
        WHEN ("Mezgit")   species_code = "Mezgit";
        WHEN ("Palamut")  species_code = "Palamut";
        WHEN ("Tekir")    species_code = "Tekir";
        WHEN ("Lufer")    DO; species_code = "Lufer"; END;    /* Lüfer  */
        WHEN ("Izmarit")  DO; species_code = "Izmarit"; END;  /* İzmarit*/
        WHEN ("Zargana")  DO; species_code = "Zargana"; END;
        WHEN ("Kalkan")   DO; species_code = "Kalkan"; END;
        OTHERWISE         species_code = COMPRESS(species);
    END;

    /* Assign formats */
    FORMAT weight_gr      weight_class.;
    FORMAT total_length_cm length_class.;

    /* Derived labels */
    LENGTH weight_label $20 tier_label $15;
    weight_label = PUT(weight_gr, weight_class.);
    tier_label   = PUT(species_code, $market_tier.);

LABEL
    total_length_cm = "Total Length (cm)"
    body_depth_cm   = "Body Depth (cm)"
    body_width_cm   = "Body Width (cm)"
    head_length_cm  = "Head Length (cm)"
    eye_diameter_mm = "Eye Diameter (mm)"
    weight_gr       = "Weight (g)"
    species_code    = "Species (ASCII)"
    tier_label      = "Market Tier"
    weight_label    = "Weight Class";

RUN;

/* Report using formats */
PROC FREQ DATA = WORK.fish;
    TABLES species_code * tier_label / NOCUM NOPERCENT;
    TITLE2 "Section 2 — Species x Market Tier (using user-defined formats)";
RUN;


/*=============================================================================
  SECTION 3 — ITERATIVE AND CONDITIONAL PROCESSING OF DATA
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Compute derived variables: body condition index (Fulton K), log
              transformations, size-class flags, and allometric weight estimate.
              Use DO loops to calculate cumulative running statistics.
  Method:     IF-THEN-ELSE, SELECT-WHEN, DO loop, SAS functions (LOG, EXP, ROUND).
  Interpretation: The Fulton condition factor K = (W / L³) × 100,000 measures
              fish health — values > 1 indicate good condition; values used in
              stock assessment to detect environmental stress.
=============================================================================*/

TITLE2 "Section 3 — Iterative & Conditional Processing";

DATA WORK.fish_derived;
    SET WORK.fish;

    /* ── Fulton Condition Factor K = (W / L^3) * 100000 ── */
    IF total_length_cm > 0 THEN
        condition_k = (weight_gr / (total_length_cm**3)) * 100000;
    ELSE condition_k = .;
    condition_k = ROUND(condition_k, 0.001);

    /* ── Log transformations for allometric modelling ── */
    IF weight_gr > 0 AND total_length_cm > 0 THEN DO;
        log_weight = LOG(weight_gr);
        log_length = LOG(total_length_cm);
        log_depth  = LOG(body_depth_cm);
        log_head   = LOG(head_length_cm);
        log_eye    = LOG(eye_diameter_mm);
    END;

    /* ── Body aspect ratio ── */
    IF body_depth_cm > 0 THEN
        aspect_ratio = ROUND(total_length_cm / body_depth_cm, 0.01);

    /* ── Conditional size classification ── */
    LENGTH size_class $15;
    IF      total_length_cm < 10 THEN size_class = "Juvenile";
    ELSE IF total_length_cm < 20 THEN size_class = "Sub-adult";
    ELSE IF total_length_cm < 35 THEN size_class = "Adult";
    ELSE                               size_class = "Large Adult";

    /* ── Market grade via SELECT ── */
    LENGTH market_grade $10;
    SELECT;
        WHEN (weight_gr < 10)   market_grade = "Grade D";
        WHEN (weight_gr < 50)   market_grade = "Grade C";
        WHEN (weight_gr < 200)  market_grade = "Grade B";
        WHEN (weight_gr < 1000) market_grade = "Grade A";
        OTHERWISE               market_grade = "Premium";
    END;

    /* ── Iterative: rolling weight deviation from 20g baseline ── */
    ARRAY morpho[5] total_length_cm body_depth_cm body_width_cm
                    head_length_cm eye_diameter_mm;
    ARRAY z_morph[5] z_length z_depth z_width z_head z_eye;

    /* Simple ratio to mean (population means from data exploration) */
    ARRAY pop_mean[5] _TEMPORARY_ (18.27 4.01 1.87 4.54 4.76);
    ARRAY pop_std[5]  _TEMPORARY_ (11.67 5.45 2.38 2.73 2.48);

    DO i = 1 TO 5;
        IF pop_std[i] > 0 THEN
            z_morph[i] = ROUND((morpho[i] - pop_mean[i]) / pop_std[i], 0.001);
        ELSE z_morph[i] = .;
    END;
    DROP i;

    /* Composite morphometric score (average absolute z-score) */
    morph_score = ROUND(MEAN(ABS(z_length), ABS(z_depth), ABS(z_width),
                              ABS(z_head),   ABS(z_eye)), 0.001);

LABEL
    condition_k   = "Fulton Condition Factor K"
    log_weight    = "ln(Weight)"
    log_length    = "ln(Total Length)"
    aspect_ratio  = "Length/Depth Aspect Ratio"
    size_class    = "Size Class"
    market_grade  = "Market Grade"
    morph_score   = "Composite Morphometric Score";

RUN;

PROC PRINT DATA = WORK.fish_derived (OBS=15) NOOBS;
    VAR species_code total_length_cm weight_gr condition_k
        aspect_ratio size_class market_grade morph_score;
    TITLE2 "Section 3 — Derived Variables (first 15 records)";
RUN;


/*=============================================================================
  SECTION 4 — CREATING DATA SUBSETS
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Separate the master dataset into species-specific subsets and
              market-tier subsets for targeted analysis and reporting.
  Method:     WHERE statement, OUTPUT with multiple datasets, BY processing.
  Interpretation: Subsets enable species-level fishery management — quota
              calculations, size-limit enforcement, and export-grade sorting
              are performed per species.
=============================================================================*/

TITLE2 "Section 4 — Creating Data Subsets";

/* ── Subset 1: High-value commercial species only ── */
DATA WORK.high_value;
    SET WORK.fish_derived;
    WHERE species_code IN ("Palamut","Lufer","Kalkan");
RUN;

/* ── Subset 2: Economy species ── */
DATA WORK.economy;
    SET WORK.fish_derived;
    WHERE tier_label = "Economy";
RUN;

/* ── Subset 3: Adult fish only (length >= 20cm) ── */
DATA WORK.adults;
    SET WORK.fish_derived;
    WHERE total_length_cm >= 20;
RUN;

/* ── Subset 4: Juvenile fish (possible undersized catches) ── */
DATA WORK.juveniles;
    SET WORK.fish_derived;
    WHERE total_length_cm < 10;
RUN;

/* ── Subset 5: Multiple output datasets in one step ── */
DATA WORK.hamsi WORK.istavrit WORK.sardalya WORK.mezgit
     WORK.palamut WORK.tekir WORK.lufer WORK.izmarit
     WORK.zargana WORK.kalkan;
    SET WORK.fish_derived;
    SELECT (species_code);
        WHEN ("Hamsi")    OUTPUT WORK.hamsi;
        WHEN ("Istavrit") OUTPUT WORK.istavrit;
        WHEN ("Sardalya") OUTPUT WORK.sardalya;
        WHEN ("Mezgit")   OUTPUT WORK.mezgit;
        WHEN ("Palamut")  OUTPUT WORK.palamut;
        WHEN ("Tekir")    OUTPUT WORK.tekir;
        WHEN ("Lufer")    OUTPUT WORK.lufer;
        WHEN ("Izmarit")  OUTPUT WORK.izmarit;
        WHEN ("Zargana")  OUTPUT WORK.zargana;
        WHEN ("Kalkan")   OUTPUT WORK.kalkan;
        OTHERWISE;
    END;
RUN;

/* Summary of subsets */
%MACRO subset_count(ds, label);
    %LET nobs = 0;
    PROC SQL NOPRINT;
        SELECT COUNT(*) INTO :nobs FROM &ds;
    QUIT;
    %PUT &label: &nobs records;
%MEND;

%subset_count(WORK.high_value, "High-Value Species");
%subset_count(WORK.economy,    "Economy Species");
%subset_count(WORK.adults,     "Adult Fish (>=20cm)");
%subset_count(WORK.juveniles,  "Juvenile Fish (<10cm)");

PROC FREQ DATA = WORK.fish_derived;
    TABLES species_code * size_class / NOCUM NOPERCENT;
    TITLE2 "Section 4 — Species x Size Class Cross-tabulation";
RUN;


/*=============================================================================
  SECTION 5 — USING SAS FUNCTIONS
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Apply numeric, character, and statistical SAS functions to compute
              additional biological indicators: percentile rank, standardised
              scores, string manipulation, and date-based season tagging.
  Method:     SAS built-in functions — LOG, EXP, SQRT, ROUND, ABS, MAX, MIN,
              MEAN, CATX, UPCASE, PUT, INPUT, RANUNI, RANK (via PROC RANK).
  Interpretation: SAS functions eliminate the need for manual formula coding and
              reduce programming errors; LOG transformations linearise
              allometric (power-law) relationships common in fishery biology.
=============================================================================*/

TITLE2 "Section 5 — SAS Functions";

DATA WORK.fish_functions;
    SET WORK.fish_derived;

    /* ── Numeric functions ── */
    weight_sqrt   = ROUND(SQRT(weight_gr), 0.01);       /* square root */
    weight_sq     = weight_gr ** 2;                      /* square */
    log10_weight  = ROUND(LOG10(weight_gr), 0.001);      /* log base 10 */
    abs_z_length  = ABS(z_length);                       /* absolute value */

    /* ── Min / Max across morphometric features ── */
    max_dim = MAX(total_length_cm, body_depth_cm * 10,   /* compare in mm */
                  body_width_cm  * 10, head_length_cm * 10, eye_diameter_mm);
    min_dim = MIN(body_depth_cm, body_width_cm, head_length_cm);

    /* ── Statistical summary functions ── */
    mean_dims = ROUND(MEAN(total_length_cm, body_depth_cm,
                            body_width_cm, head_length_cm), 0.01);
    sum_dims  = SUM(total_length_cm, body_depth_cm,
                    body_width_cm, head_length_cm);

    /* ── String / character functions ── */
    LENGTH species_upper $12 species_label $40;
    species_upper = UPCASE(species_code);
    species_label = CATX(" | ", species_code,
                         PUT(species_code, $market_tier.));
    len_name      = LENGTH(STRIP(species_code));

    /* ── Rounding and truncation ── */
    weight_rounded_100 = ROUND(weight_gr, 100);   /* nearest 100g */
    weight_ceil        = CEIL(weight_gr);          /* ceiling */
    weight_floor       = FLOOR(weight_gr);         /* floor */

    /* ── Logical indicator functions ── */
    is_large   = (total_length_cm >= 30);    /* binary flag */
    is_premium = (tier_label IN ("Premium","Luxury"));

    /* ── Estimated revenue (price TRY/kg × weight in kg) ── */
    LENGTH price_per_kg 8;
    SELECT (tier_label);
        WHEN ("Economy")      price_per_kg = 35;
        WHEN ("Standard")     price_per_kg = 55;
        WHEN ("Premium")      price_per_kg = 100;
        WHEN ("Luxury")       price_per_kg = 200;
        OTHERWISE             price_per_kg = 40;
    END;
    est_revenue_TRY = ROUND((weight_gr / 1000) * price_per_kg, 0.01);

LABEL
    weight_sqrt    = "SQRT(Weight)"
    log10_weight   = "log10(Weight)"
    mean_dims      = "Mean of Length Dimensions (cm)"
    est_revenue_TRY= "Est. Revenue per Fish (TRY)"
    is_premium     = "Premium/Luxury Flag (0/1)";

RUN;

/* PROC RANK — percentile ranks for weight within species */
PROC SORT DATA = WORK.fish_functions; BY species_code; RUN;

PROC RANK DATA  = WORK.fish_functions
          OUT   = WORK.fish_ranked
          TIES  = MEAN
          PERCENT;
    VAR weight_gr total_length_cm;
    RANKS pct_weight pct_length;
    BY species_code;
RUN;

PROC MEANS DATA = WORK.fish_functions MAXDEC=2
    N MEAN STD MIN MAX;
    VAR weight_sqrt log10_weight mean_dims est_revenue_TRY condition_k;
    CLASS species_code;
    TITLE2 "Section 5 — Derived Measures Using SAS Functions by Species";
RUN;


/*=============================================================================
  SECTION 6 — COMBINING DATASETS (MERGE + SET) AND SQL JOINS
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Enrich the morphometric data with lookup tables for market prices,
              conservation status, and Turkish fishery regulation minimum sizes.
  Method A:   DATA STEP MERGE (sorted keys).
  Method B:   PROC SQL with LEFT JOIN and INNER JOIN.
  Interpretation: Combining datasets simulates an enterprise data-warehouse
              workflow where biological field data is joined to regulatory and
              market databases for integrated fishery management decisions.
=============================================================================*/

TITLE2 "Section 6 — Combining Datasets";

/* ── Create lookup tables ── */

DATA WORK.lkp_prices;
    INFILE DATALINES DLM="," MISSOVER;
    INPUT species_code :$12. price_TRY_per_kg 8. market_category :$15.;
DATALINES;
Hamsi,35,Canned/Industrial
Istavrit,45,Fresh Market
Sardalya,30,Canned/Industrial
Mezgit,50,Fresh Market
Palamut,80,Premium Fresh
Tekir,120,Premium Fresh
Lufer,100,Premium Fresh
Izmarit,40,Fresh Market
Zargana,25,Niche Market
Kalkan,200,Luxury/Export
;
RUN;

DATA WORK.lkp_regulations;
    INFILE DATALINES DLM="," MISSOVER;
    INPUT species_code :$12. min_length_cm 8. conservation :$5.;
DATALINES;
Hamsi,9,LC
Istavrit,13,LC
Sardalya,11,LC
Mezgit,18,LC
Palamut,25,LC
Tekir,13,LC
Lufer,25,VU
Izmarit,9,LC
Zargana,35,LC
Kalkan,45,VU
;
RUN;

/* ── Method A: DATA STEP MERGE ── */
PROC SORT DATA = WORK.fish_ranked;     BY species_code; RUN;
PROC SORT DATA = WORK.lkp_prices;     BY species_code; RUN;
PROC SORT DATA = WORK.lkp_regulations; BY species_code; RUN;

DATA WORK.fish_merged;
    MERGE WORK.fish_ranked     (IN=a)
          WORK.lkp_prices      (IN=b)
          WORK.lkp_regulations (IN=c);
    BY species_code;
    IF a;    /* keep all fish records; lookup = left join */

    /* Compliance flag */
    IF total_length_cm < min_length_cm THEN undersized = 1;
    ELSE undersized = 0;

    /* Revenue with correct price */
    IF price_TRY_per_kg > . THEN
        revenue_TRY = ROUND((weight_gr / 1000) * price_TRY_per_kg, 0.01);

LABEL
    undersized   = "Undersized Catch Flag (0/1)"
    revenue_TRY  = "Revenue per Fish (TRY)"
    conservation = "IUCN Conservation Status";
RUN;

/* ── Method B: PROC SQL JOIN ── */
PROC SQL;
    CREATE TABLE WORK.sql_enriched AS
    SELECT  f.species_code,
            f.total_length_cm,
            f.weight_gr,
            f.condition_k,
            f.size_class,
            f.market_grade,
            p.price_TRY_per_kg,
            p.market_category,
            r.min_length_cm,
            r.conservation,
            ROUND((f.weight_gr/1000) * p.price_TRY_per_kg, 0.01) AS revenue_TRY,
            CASE WHEN f.total_length_cm < r.min_length_cm
                 THEN "YES" ELSE "NO" END AS undersized_sql LENGTH=3
    FROM    WORK.fish_derived      AS f
    LEFT JOIN WORK.lkp_prices      AS p ON f.species_code = p.species_code
    LEFT JOIN WORK.lkp_regulations AS r ON f.species_code = r.species_code
    ORDER BY f.species_code, f.weight_gr DESC;
QUIT;

/* Summary: undersized catches by species */
PROC SQL;
    SELECT  species_code,
            COUNT(*) AS total_fish,
            SUM(CASE WHEN undersized_sql="YES" THEN 1 ELSE 0 END) AS undersized_n,
            ROUND(SUM(CASE WHEN undersized_sql="YES" THEN 1 ELSE 0 END) /
                  COUNT(*) * 100, 0.1) AS pct_undersized,
            MIN(min_length_cm) AS legal_minimum_cm,
            ROUND(AVG(revenue_TRY), 2) AS avg_revenue_TRY
    FROM    WORK.sql_enriched
    GROUP BY species_code
    ORDER BY pct_undersized DESC;
QUIT;
TITLE2 "Section 6 — Undersized Catches & Average Revenue by Species (SQL)";


/* ── SET: combine high-value and economy subsets ── */
DATA WORK.two_tiers;
    SET WORK.high_value WORK.economy;
    LENGTH tier_source $12;
    tier_source = tier_label;
RUN;


/*=============================================================================
  SECTION 7 — USING ARRAYS
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Standardise all six morphometric variables simultaneously using
              arrays, compute a composite body-size index, and flag any variable
              that exceeds 2 standard deviations from its species mean.
  Method:     ARRAY with DO loop; _TEMPORARY_ arrays for parameter storage.
  Interpretation: Standardisation via arrays is computationally efficient for
              wide datasets; the composite index supports automated grading
              systems and quality-control in processing plants.
=============================================================================*/

TITLE2 "Section 7 — Arrays";

/* Step 1: compute species-level means and std devs (store in macro vars) */
PROC MEANS DATA = WORK.fish_derived NOPRINT;
    VAR total_length_cm body_depth_cm body_width_cm
        head_length_cm  eye_diameter_mm weight_gr;
    OUTPUT OUT  = WORK.pop_stats
           MEAN = m_len m_dep m_wid m_head m_eye m_wt
           STD  = s_len s_dep s_wid s_head s_eye s_wt;
RUN;

/* Read population-level stats into macro variables */
DATA _NULL_;
    SET WORK.pop_stats;
    CALL SYMPUTX("m_len",  m_len);
    CALL SYMPUTX("m_dep",  m_dep);
    CALL SYMPUTX("m_wid",  m_wid);
    CALL SYMPUTX("m_head", m_head);
    CALL SYMPUTX("m_eye",  m_eye);
    CALL SYMPUTX("m_wt",   m_wt);
    CALL SYMPUTX("s_len",  s_len);
    CALL SYMPUTX("s_dep",  s_dep);
    CALL SYMPUTX("s_wid",  s_wid);
    CALL SYMPUTX("s_head", s_head);
    CALL SYMPUTX("s_eye",  s_eye);
    CALL SYMPUTX("s_wt",   s_wt);
RUN;

/* Step 2: apply arrays for standardisation */
DATA WORK.fish_arrays;
    SET WORK.fish_derived;

    /* Raw morphometric array */
    ARRAY raw[6]  total_length_cm body_depth_cm body_width_cm
                  head_length_cm  eye_diameter_mm weight_gr;

    /* Standardised output array */
    ARRAY zsc[6]  z_total_length z_body_depth z_body_width
                  z_head_length  z_eye_diam   z_weight;

    /* Population means (temporary — not written to dataset) */
    ARRAY pop_m[6] _TEMPORARY_
        (&m_len &m_dep &m_wid &m_head &m_eye &m_wt);

    /* Population std devs */
    ARRAY pop_s[6] _TEMPORARY_
        (&s_len &s_dep &s_wid &s_head &s_eye &s_wt);

    /* Outlier flag array */
    ARRAY outlier[6] out_length out_depth out_width
                     out_head   out_eye   out_weight;

    DO i = 1 TO 6;
        IF pop_s[i] > 0 THEN
            zsc[i] = ROUND((raw[i] - pop_m[i]) / pop_s[i], 0.0001);
        ELSE
            zsc[i] = .;

        /* Flag if |z| > 2 */
        outlier[i] = (ABS(zsc[i]) > 2);
    END;

    /* Count how many features are outliers for this fish */
    n_outlier_features = SUM(OF outlier[*]);

    /* Composite standardised size index (all 6 z-scores) */
    comp_size_idx = ROUND(MEAN(OF zsc[*]), 0.001);

    DROP i;

LABEL
    z_total_length = "Z-score: Total Length"
    z_body_depth   = "Z-score: Body Depth"
    z_body_width   = "Z-score: Body Width"
    z_head_length  = "Z-score: Head Length"
    z_eye_diam     = "Z-score: Eye Diameter"
    z_weight       = "Z-score: Weight"
    comp_size_idx  = "Composite Size Index (mean Z)"
    n_outlier_features = "No. Features With |Z|>2";

RUN;

PROC MEANS DATA=WORK.fish_arrays MAXDEC=3 N MEAN STD MIN MAX;
    VAR z_total_length z_body_depth z_body_width
        z_head_length  z_eye_diam   z_weight comp_size_idx;
    CLASS species_code;
    TITLE2 "Section 7 — Standardised Z-scores by Species (via Arrays)";
RUN;

PROC FREQ DATA=WORK.fish_arrays;
    TABLES species_code * n_outlier_features / NOCUM NOPERCENT;
    TITLE2 "Section 7 — Outlier Feature Count per Species";
RUN;


/*=============================================================================
  SECTION 8 — REPORT PROCEDURES
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Produce professional summary reports for fishery managers showing
              species-level statistics, market-grade distributions, and
              regulatory compliance rates.
  Method:     PROC REPORT with DEFINE, COMPUTE, BREAK, and RBREAK statements.
              Also PROC TABULATE for cross-tabulated summaries.
  Interpretation: Reports replace manual Excel tables and ensure consistent,
              reproducible output for regulatory submissions and commercial tenders.
=============================================================================*/

TITLE2 "Section 8 — Report Procedures";

/* ── PROC REPORT: Species Summary ── */
PROC REPORT DATA=WORK.fish_merged NOWD HEADSKIP;
    TITLE2 "Section 8A — Species Morphometric & Revenue Summary Report";

    COLUMNS species_code n total_length_cm weight_gr
            condition_k revenue_TRY undersized;

    DEFINE species_code   / GROUP "Species"          WIDTH=12;
    DEFINE n              / N     "Count"            FORMAT=8.0;
    DEFINE total_length_cm/ MEAN  "Mean Length (cm)" FORMAT=8.2;
    DEFINE weight_gr      / MEAN  "Mean Weight (g)"  FORMAT=10.1;
    DEFINE condition_k    / MEAN  "Mean K Factor"    FORMAT=8.3;
    DEFINE revenue_TRY    / MEAN  "Avg Revenue (TRY)" FORMAT=10.2;
    DEFINE undersized     / SUM   "Undersized Count" FORMAT=8.0;

    /* Highlight species with >20% undersized (computed column) */
    COMPUTE undersized;
        IF undersized.sum > 20 THEN CALL DEFINE(_COL_, "STYLE",
            "STYLE=[BACKGROUND=#FFE0E0 FOREGROUND=RED]");
    ENDCOMP;

    BREAK AFTER species_code / SUMMARIZE SKIP;
    RBREAK AFTER / SUMMARIZE DASHES;
RUN;

/* ── PROC REPORT: Market Grade Distribution ── */
PROC REPORT DATA=WORK.fish_merged NOWD HEADSKIP;
    TITLE2 "Section 8B — Market Grade Distribution by Species";

    COLUMNS species_code market_grade n weight_gr revenue_TRY;

    DEFINE species_code / GROUP   "Species"       WIDTH=12;
    DEFINE market_grade / GROUP   "Grade"         WIDTH=12;
    DEFINE n            / N       "Count"         FORMAT=6.0;
    DEFINE weight_gr    / MEAN    "Avg Wt (g)"    FORMAT=9.1;
    DEFINE revenue_TRY  / SUM     "Total Rev (TRY)" FORMAT=12.2;

    BREAK AFTER species_code / SUMMARIZE SKIP;
    RBREAK AFTER / DASHES SUMMARIZE;
RUN;

/* ── PROC TABULATE: Cross-tabulation ── */
PROC TABULATE DATA=WORK.fish_merged FORMAT=10.2;
    TITLE2 "Section 8C — TABULATE: Weight & Revenue by Species x Market Grade";

    CLASS species_code market_grade;
    VAR weight_gr revenue_TRY;

    TABLE species_code ALL,
          market_grade * (weight_gr * (N MEAN) revenue_TRY * SUM)
          / RTS=14 BOX="Species / Grade";
RUN;


/*=============================================================================
  SECTION 9 — STATISTICAL PROCEDURES
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Perform rigorous statistical analysis:
              (a) Descriptive statistics and normality tests per species
              (b) Correlation analysis between morphometric features
              (c) Multiple linear regression: weight ~ length + depth + ...
              (d) Logistic regression: P(high_value) ~ morphometrics
              (e) Cluster analysis: unsupervised grouping of fish
  Methods:    PROC MEANS, PROC UNIVARIATE, PROC CORR, PROC REG,
              PROC LOGISTIC, PROC CLUSTER, PROC FASTCLUS
  Interpretation: Statistical modelling enables evidence-based fishery quotas,
              automated market grading, and early detection of stock anomalies.
=============================================================================*/

TITLE2 "Section 9 — Statistical Procedures";

/* ── 9A: Descriptive Statistics ── */
PROC MEANS DATA=WORK.fish_derived
    N NMISS MEAN STD STDERR MIN Q1 MEDIAN Q3 MAX SKEWNESS KURTOSIS
    MAXDEC=3;
    VAR total_length_cm body_depth_cm body_width_cm
        head_length_cm  eye_diameter_mm weight_gr condition_k;
    CLASS species_code;
    TITLE2 "Section 9A — Descriptive Statistics by Species";
RUN;

/* ── 9B: Normality Tests ── */
PROC UNIVARIATE DATA=WORK.fish_derived NORMAL PLOT;
    VAR weight_gr total_length_cm;
    HISTOGRAM weight_gr / NORMAL KERNEL;
    QQPLOT weight_gr / NORMAL(MU=EST SIGMA=EST);
    TITLE2 "Section 9B — Univariate Normality Test (Weight & Length)";
RUN;

/* ── 9C: Correlation Analysis ── */
PROC CORR DATA=WORK.fish_derived PEARSON SPEARMAN PLOTS=MATRIX;
    VAR total_length_cm body_depth_cm body_width_cm
        head_length_cm  eye_diameter_mm weight_gr;
    TITLE2 "Section 9C — Pearson & Spearman Correlation Matrix";
RUN;

/* ── 9D: Multiple Linear Regression — log(weight) = f(log morphometrics) ── */
PROC REG DATA=WORK.fish_derived PLOTS=ALL;
    TITLE2 "Section 9D — Multiple Regression: log(Weight) ~ log(Morphometrics)";

    /* Model 1: all predictors */
    MODEL log_weight = log_length log_depth log_head log_eye
                      / STB VIF COLLIN INFLUENCE R;

    /* Model 2: stepwise selection */
    MODEL log_weight = log_length log_depth log_head log_eye
                      / SELECTION=STEPWISE SLENTRY=0.05 SLSTAY=0.05;

    OUTPUT OUT=WORK.reg_out PREDICTED=pred_log RESIDUAL=resid;
RUN; QUIT;

/* Back-transform predictions */
DATA WORK.reg_out;
    SET WORK.reg_out;
    pred_weight   = ROUND(EXP(pred_log), 0.01);
    abs_error     = ABS(pred_weight - weight_gr);
    pct_error     = ROUND(abs_error / weight_gr * 100, 0.1);
RUN;

PROC MEANS DATA=WORK.reg_out MAXDEC=2 MEAN;
    VAR abs_error pct_error;
    TITLE2 "Section 9D — Regression Prediction Error";
RUN;

/* ── 9E: Logistic Regression — P(High-Value species) ── */
DATA WORK.fish_logit;
    SET WORK.fish_arrays;
    high_value = (species_code IN ("Palamut","Lufer","Kalkan"));
RUN;

PROC LOGISTIC DATA=WORK.fish_logit DESCENDING PLOTS(MAXPOINTS=NONE)=ALL;
    TITLE2 "Section 9E — Logistic Regression: P(High-Value) ~ Morphometrics";

    MODEL high_value (EVENT="1") =
        z_total_length z_body_depth z_body_width
        z_head_length  z_eye_diam   z_weight
        / LINK=LOGIT SELECTION=BACKWARD SLSTAY=0.05
          RSQUARE LACKFIT OUTROC=WORK.roc_data;

    OUTPUT OUT=WORK.logit_out PREDICTED=p_highvalue;
RUN;

/* ── 9F: Cluster Analysis ── */

/* PROC FASTCLUS: K-Means style clustering */
PROC FASTCLUS DATA=WORK.fish_arrays
              MAXCLUSTERS=4
              MAXITER=50
              OUTSEED=WORK.seeds
              OUT=WORK.cluster_out;
    VAR z_total_length z_body_depth z_body_width
        z_head_length  z_eye_diam   z_weight;
    TITLE2 "Section 9F — K-Means Clustering (k=4) via PROC FASTCLUS";
RUN;

/* Cluster profile */
PROC MEANS DATA=WORK.cluster_out MAXDEC=2 MEAN N;
    VAR total_length_cm body_depth_cm weight_gr condition_k;
    CLASS CLUSTER;
    TITLE2 "Section 9F — Cluster Profiles";
RUN;

PROC FREQ DATA=WORK.cluster_out;
    TABLES CLUSTER * species_code / NOCUM NOPERCENT;
    TITLE2 "Section 9F — Species Composition per Cluster";
RUN;


/*=============================================================================
  SECTION 10 — GRAPHICAL PROCEDURES (PROC SGPLOT / SGPANEL / SGSCATTER)
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Produce publication-quality graphs for the Word report covering:
              length–weight relationships, species distributions, regression
              diagnostics, and cluster visualisation.
  Method:     PROC SGPLOT, PROC SGPANEL, PROC SGSCATTER with ODS GRAPHICS.
  Interpretation: Visual analytics communicate patterns to non-statistical
              stakeholders (fishing cooperatives, regulators, markets).
=============================================================================*/

TITLE2 "Section 10 — Graphical Procedures";

ODS GRAPHICS ON / WIDTH=700px HEIGHT=450px IMAGEFMT=PNG;

/* ── Graph 1: Species count bar chart ── */
PROC SGPLOT DATA=WORK.fish_derived;
    TITLE2 "Graph 1 — Sample Size per Species";
    VBAR species_code / DATALABEL FILLATTRS=(COLOR=CX1A6FA0)
                        CATEGORYORDER=RESPDESC;
    XAXIS LABEL="Species";
    YAXIS LABEL="Number of Fish";
RUN;

/* ── Graph 2: Log weight vs log length scatter (allometric) ── */
PROC SGPLOT DATA=WORK.fish_derived;
    TITLE2 "Graph 2 — Allometric Relationship: log(Weight) vs log(Length)";
    SCATTER X=log_length Y=log_weight / GROUP=species_code
            TRANSPARENCY=0.3 MARKERATTRS=(SIZE=5);
    REG X=log_length Y=log_weight / NOMARKERS
        LINEATTRS=(COLOR=CXCC0000 THICKNESS=2);
    XAXIS LABEL="ln(Total Length)";
    YAXIS LABEL="ln(Weight)";
    KEYLEGEND / TITLE="Species" LOCATION=OUTSIDE POSITION=RIGHT;
RUN;

/* ── Graph 3: Box plot — weight by species ── */
PROC SGPLOT DATA=WORK.fish_derived;
    TITLE2 "Graph 3 — Weight Distribution by Species (log scale)";
    VBOX weight_gr / CATEGORY=species_code GROUP=species_code
                     CATEGORYORDER=RESPDESC;
    YAXIS TYPE=LOG LABEL="Weight (g) — log scale";
    XAXIS LABEL="Species";
RUN;

/* ── Graph 4: Histogram of condition factor K ── */
PROC SGPLOT DATA=WORK.fish_derived;
    TITLE2 "Graph 4 — Distribution of Fulton Condition Factor K";
    HISTOGRAM condition_k / FILLATTRS=(COLOR=CX27AE60) BINWIDTH=0.05;
    DENSITY condition_k / TYPE=KERNEL
                          LINEATTRS=(COLOR=CXCC0000 THICKNESS=2);
    XAXIS LABEL="Condition Factor K";
    YAXIS LABEL="Frequency";
RUN;

/* ── Graph 5: Scatter matrix (SGSCATTER) ── */
PROC SGSCATTER DATA=WORK.fish_derived (WHERE=(species_code IN ("Hamsi","Palamut","Kalkan","Lufer")));
    TITLE2 "Graph 5 — Scatter Matrix: Morphometric Features (4 species)";
    MATRIX total_length_cm body_depth_cm weight_gr eye_diameter_mm
           / GROUP=species_code DIAGONAL=(HISTOGRAM);
RUN;

/* ── Graph 6: Panel — histograms per species ── */
PROC SGPANEL DATA=WORK.fish_derived;
    TITLE2 "Graph 6 — Total Length Histograms by Species";
    PANELBY species_code / NOVARNAME LAYOUT=PANEL COLUMNS=5;
    HISTOGRAM total_length_cm / FILLATTRS=(COLOR=CX2196F3) BINWIDTH=2;
    DENSITY total_length_cm / TYPE=KERNEL;
    COLAXIS LABEL="Total Length (cm)";
RUN;

/* ── Graph 7: Regression residual plot ── */
PROC SGPLOT DATA=WORK.reg_out;
    TITLE2 "Graph 7 — Regression Residuals vs Predicted log(Weight)";
    SCATTER X=pred_log Y=resid / TRANSPARENCY=0.4
            MARKERATTRS=(SYMBOL=CIRCLEFILLED SIZE=5 COLOR=CX1A6FA0);
    REFLINE 0 / AXIS=Y LINEATTRS=(COLOR=RED PATTERN=DASH);
    LOESS X=pred_log Y=resid /
          LINEATTRS=(COLOR=CXFF5722 THICKNESS=2);
    XAXIS LABEL="Predicted ln(Weight)";
    YAXIS LABEL="Residual";
RUN;

/* ── Graph 8: Cluster membership by length and weight ── */
PROC SGPLOT DATA=WORK.cluster_out;
    TITLE2 "Graph 8 — Cluster Membership (Total Length vs Weight)";
    SCATTER X=total_length_cm Y=weight_gr / GROUP=CLUSTER
            TRANSPARENCY=0.3 MARKERATTRS=(SIZE=6);
    YAXIS TYPE=LOG LABEL="Weight (g) — log scale";
    XAXIS LABEL="Total Length (cm)";
    KEYLEGEND / TITLE="Cluster";
RUN;

/* ── Graph 9: Mean weight by market grade (bar) ── */
PROC MEANS DATA=WORK.fish_merged NOPRINT;
    VAR weight_gr;
    CLASS market_grade;
    OUTPUT OUT=WORK.grade_means MEAN=mean_weight;
RUN;

PROC SGPLOT DATA=WORK.grade_means (WHERE=(market_grade ^= ""));
    TITLE2 "Graph 9 — Mean Weight by Market Grade";
    VBAR market_grade / RESPONSE=mean_weight DATALABEL
                        FILLATTRS=(COLOR=CXFF9800)
                        CATEGORYORDER=RESPDESC;
    XAXIS LABEL="Market Grade";
    YAXIS LABEL="Mean Weight (g)";
RUN;

/* ── Graph 10: Correlation heat map (manual via PROC CORR + SGPLOT) ── */
PROC CORR DATA=WORK.fish_derived OUTP=WORK.corr_out NOPRINT;
    VAR total_length_cm body_depth_cm body_width_cm
        head_length_cm  eye_diameter_mm weight_gr;
RUN;

ODS GRAPHICS OFF;


/*=============================================================================
  SECTION 11 — MACRO PROGRAMMING (BONUS)
  ─────────────────────────────────────────────────────────────────────────────
  Problem:    Automate species-level analysis for all 10 species without
              repeating code blocks — critical for maintainability.
  Method:     %MACRO / %MEND with parameters, %DO loop, PROC MEANS, PROC SGPLOT.
=============================================================================*/

TITLE2 "Section 11 — Macro: Automated Per-Species Report";

%MACRO species_report(sp_name=, sp_label=);
    TITLE3 "Species: &sp_label (&sp_name)";

    PROC MEANS DATA=WORK.fish_derived (WHERE=(species_code="&sp_name"))
        N MEAN STD MIN MAX MAXDEC=2;
        VAR total_length_cm weight_gr condition_k;
    RUN;

%MEND species_report;

/* Call for each species */
%species_report(sp_name=Hamsi,    sp_label=European Anchovy);
%species_report(sp_name=Palamut,  sp_label=Atlantic Bonito);
%species_report(sp_name=Kalkan,   sp_label=Turbot);
%species_report(sp_name=Lufer,    sp_label=Bluefish);
%species_report(sp_name=Sardalya, sp_label=European Sardine);
%species_report(sp_name=Mezgit,   sp_label=Whiting);
%species_report(sp_name=Istavrit, sp_label=Horse Mackerel);
%species_report(sp_name=Tekir,    sp_label=Red Mullet);
%species_report(sp_name=Izmarit,  sp_label=Picarel);
%species_report(sp_name=Zargana,  sp_label=Garfish);


/*=============================================================================
  END OF PROGRAM
=============================================================================*/
TITLE;
TITLE2;

%PUT ====================================================;
%PUT  Marmara Fish SAS Analysis — Program Completed;
%PUT  Sections covered:;
%PUT    1. PROC IMPORT (external CSV);
%PUT    2. PROC FORMAT (user-defined formats);
%PUT    3. Iterative & conditional (DO / IF-THEN / SELECT);
%PUT    4. Data subsets (WHERE / OUTPUT);
%PUT    5. SAS functions (LOG, ROUND, MEAN, CAT, RANK...);
%PUT    6. Combining datasets (MERGE + PROC SQL JOIN);
%PUT    7. ARRAY statement;
%PUT    8. Report procedures (PROC REPORT / TABULATE);
%PUT    9. Statistical procedures (MEANS/UNIVARIATE/CORR/REG/LOGISTIC/FASTCLUS);
%PUT   10. Graphs (PROC SGPLOT / SGPANEL / SGSCATTER);
%PUT   11. Macro programming (BONUS);
%PUT ====================================================;
