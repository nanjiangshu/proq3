#!/bin/bash

source ./paths.sh       # Read in paths

num=$$

echo "------------- Testing run_all_external.pl ------------------"

mkdir test.$num
cp tests_clean/1e12A_0001.pdb test.$num/
bin/run_all_external.pl -pdb test.$num/1e12A_0001.pdb 
cp tests_clean/1e12A_0001.subset.pdb test.$num/
bin/copy_features_from_master.pl test.$num/1e12A_0001.subset.pdb test.$num/1e12A_0001.pdb

echo "------------- Testing ProQ3 ------------------"

./ProQ3 -m test.$num/1e12A_0001.pdb -r no -k yes
./ProQ3 -m test.$num/1e12A_0001.subset.pdb -r yes -k yes -t 62

echo "------------- Checking the output ------------------"


if [[ ! -f test.$num/1e12A_0001.pdb.proq3.local || ! -f test.$num/1e12A_0001.pdb.proq3.global || ! -f test.$num/1e12A_0001.subset.pdb.proq3.local || ! -f test.$num/1e12A_0001.subset.pdb.proq3.global ]] ; then
    echo "ERROR: ProQ3 failed to run. The output files don't exist"
    exit 1
else
    check1=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001.pdb.proq3.local tests_clean/1e12A_0001.pdb.proq3.local test.$num/1e12A_0001.pdb.proq3.global tests_clean/1e12A_0001.pdb.proq3.global 2>&1`
    check2=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001.pdb.proq3.local tests_clean/1e12A_0001.pdb.proq3.local test.$num/1e12A_0001.pdb.proq3.global tests_clean/1e12A_0001.pdb.proq3.global 2>&1`
    check3=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001.subset.pdb.proq3.local tests_clean/1e12A_0001.subset.pdb.proq3.local test.$num/1e12A_0001.subset.pdb.proq3.global tests_clean/1e12A_0001.subset.pdb.proq3.global 2>&1`
    check4=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001.subset.pdb.proq3.local tests_clean/1e12A_0001.subset.pdb.proq3.local test.$num/1e12A_0001.subset.pdb.proq3.global tests_clean/1e12A_0001.subset.pdb.proq3.global 2>&1`
fi

if [[ $check1 != "" || $check2 != "" || $check3 != "" || $check4 != "" ]] ; then
    echo "ProQ3 completed successfully, but the results in the output files don't match the sample results in tests_clean directory. Check your installation carefully..."
else
    echo "================ Congrats! Test run has passed without any problems! ===================="
fi


