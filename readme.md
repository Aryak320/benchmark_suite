# Benchmark Suite

This is a companion repository for the paper *ProvSQL: A General System for Keeping
Track of the Provenance and Probability of Data*.

We provide an [extended version of this paper](techreport.pdf), including in particular (in appendix)
more details about the benchmark, proofs of all results, and additional
discussion items.

ProvSQL itself can be obtained [from its main repository](https://github.com/PierreSenellart/provsql/).

Formal definitions for the notions introduced in the paper, as well as
formal proofs for the Lean 4 proof assistant are available [in a separate
repository](https://github.com/PierreSenellart/provenance-lean/).

The rest of this repository contains instructions on how to reproduce our
benchmark of different systems.

## Prerequisites

1. Install DSQGEN from [TPC-DS](https://www.tpc.org/TPC_Documents_Current_Versions/download_programs/tools-download-request5.asp?bm_type=TPC-DS&bm_vers=4.0.0&mode=CURRENT-ONLY).
2. Add DSQGEN to the PATH environment variable (the scripts assume this, otherwise full path to dsqgen will be needed everywhere there is dsqgen in the scripts).
3. Install TPCH from [TPC-H](https://www.tpc.org/TPC_Documents_Current_Versions/download_programs/tools-download-request5.asp?bm_type=TPC-H&bm_vers=3.0.1&mode=CURRENT-ONLY).
4. Install ProvSQL from  [ProvSQL](https://github.com/PierreSenellart/provsql.git).
5. Install GProM from [GProM](https://github.com/IITDBGroup/gprom.git).
6. MayBMS can be obtained from [MayBMS](https://maybms.sourceforge.net/); note that it needs to be installed within a VM for an older version of Linux; we used Ubuntu 10.

## Navigating through the repo

1. Scripts are classified into broadly three groups of experiments:
   1. where we only benchmark ProvSQL on tpch queries and also on our query set measuring overheads with vanilla query runs on postgresql
   2. where we compare running times of GProM and ProvSQL
   3. where we compare running times of MayBMS and ProvSQL

2. For each of the scripts, database details and path to output directories are to be added corresponding to the postgresql setup.

3. Plotting scripts and csv files for the final results that were used in the benchmark are available in the csv_plots directory.
