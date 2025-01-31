<<<<<<< HEAD
# Benchmark Suite

This contains scripts which were used to benchmark ProvSQL for overheads and against other related systems like GProM and MaybMS.

## Prerequisites

1. Install DSQGEN from [TPC-DS](https://www.tpc.org/TPC_Documents_Current_Versions/download_programs/tools-download-request5.asp?bm_type=TPC-DS&bm_vers=4.0.0&mode=CURRENT-ONLY)
2. Add DSQGEN to the PATH environment variable. (the scripts assume this, otherwise full path to dsqgen will be needed everywhere there is dsqgen in the scripts)
3. Install TPCH from [TPC-H](https://www.tpc.org/TPC_Documents_Current_Versions/download_programs/tools-download-request5.asp?bm_type=TPC-H&bm_vers=3.0.1&mode=CURRENT-ONLY)

## Navigating through the repo

1. Scripts are classified into broadly three groups of experiments:
   1. where we only benchmark ProvSQL on tpch queries and also on our query set measuring overheads with vanilla query runs on postgresql
   2. where we compare running times of GProM and ProvSQL
   3. where we compare running times of MayBMS and ProvSQL

2. For each of the scripts, database details and path to output directories are to be added corresponding to the postgresql setup.

=======
This contains scripts which were used to benchmark ProvSQL for overheads and against other related systems like GProM and MaybMS.
Prerequisites:
1. Install DSQGEN from 
3. Add DSQGEN as path variable
4. Install TPCH from 
Navigating throught the repo:
1. Scripts are classified into broadly three groups of experiments : 1. where we only benchmark ProvSQL on tpch queries and also on our query set measuring overheads with vanilla query runs on postgresql 2. where we compare running times of GProM and ProvSQL and 3. where we compare running times of MayBMS and ProvSQL
2. For each of the scritps database details and path to output directories are to be added corresponding to the postgresql setup.
>>>>>>> 9c788d76afc9c07d199ae0f918f8aad507b5e668
3. csv files and plotting scripts for the final results that were used in the benchmark are available in the csv_plots directory.


