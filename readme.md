This contains scripts which were used to benchmark ProvSQL for overheads and against other related systems like GProM and MaybMS.
Prerequisites:
1. Install DSQGEN from 
3. Add DSQGEN as path variable
4. Install TPCH from 
Navigating throught the repo:
1. Scripts are classified into broadly three groups of experiments : 1. where we only benchmark ProvSQL on tpch queries and also on our query set measuring overheads with vanilla query runs on postgresql 2. where we compare running times of GProM and ProvSQL and 3. where we compare running times of MayBMS and ProvSQL
2. For each of the scritps database details and path to output directories are to be added corresponding to the postgresql setup.
3. csv files and plotting scripts for the final results that were used in the benchmark are available in the csv_plots directory.



