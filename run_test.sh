#!/bin/bash

source ./paths.sh       # Read in paths

num=$$

echo "------------- Testing build profile ------------------"

mkdir test.$num
cp tests_clean/*.pdb test.$num/
cp tests_clean/target.fasta* test.$num/
#bin/run_all_external.pl -pdb test.$num/1e12A_0001.pdb 
#cp tests_clean/1e12A_0001.subset.pdb test.$num/
#bin/copy_features_from_master.pl test.$num/1e12A_0001.subset.pdb test.$num/1e12A_0001.pdb

#./run_proq3.sh -fasta test.$num/target.fasta -only-build-profile

echo "------------- Testing ProQ3 ------------------"

#./ProQ3 -m test.$num/1e12A_0001.pdb -r no --debug_mode yes
#./ProQ3 -m test.$num/1e12A_0001.subset.pdb -r yes --debug_mode yes -t 62

./run_proq3.sh test.$num/1e12A_0001.pdb -profile test.$num/target.fasta -repack no --debug_mode yes
./run_proq3.sh test.$num/1e12A_0001.subset.pdb -profile test.$num/target.fasta -repack yes --debug_mode yes

if [[ ! -f test.$num/1e12A_0001.pdb.proq3.local || ! -f test.$num/1e12A_0001.pdb.proq3.global || ! -f test.$num/1e12A_0001.subset.pdb.proq3.local || ! -f test.$num/1e12A_0001.subset.pdb.proq3.global ]] ; then
    echo "ERROR: ProQ3 failed to run. The output files don't exist"
    exit 1
else
    check1=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001.pdb.proq3.local tests_clean/1e12A_0001.pdb.proq3.local test.$num/1e12A_0001.pdb.proq3.global tests_clean/1e12A_0001.pdb.proq3.global 2>&1`
    check2=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001.pdb.proq3.local tests_clean/1e12A_0001.pdb.proq3.local test.$num/1e12A_0001.pdb.proq3.global tests_clean/1e12A_0001.pdb.proq3.global 2>&1`
    check3=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001.subset.pdb.proq3.local tests_clean/1e12A_0001.subset.pdb.proq3.local test.$num/1e12A_0001.subset.pdb.proq3.global tests_clean/1e12A_0001.subset.pdb.proq3.global 2>&1`
    check4=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001.subset.pdb.proq3.local tests_clean/1e12A_0001.subset.pdb.proq3.local test.$num/1e12A_0001.subset.pdb.proq3.global tests_clean/1e12A_0001.subset.pdb.proq3.global 2>&1`
fi

if [[ $DEEP_INSTALLED == "yes" ]] ; then
    echo "------------- Testing ProQ3D (deep learning version) ------------------"

    #./ProQ3 -m test.$num/1e12A_0001_deep.pdb -r no --debug_mode yes --deep yes
    #./ProQ3 -m test.$num/1e12A_0001_deep.subset.pdb -r yes --debug_mode yes -t 62 --deep yes
    ./run_proq3.sh test.$num/1e12A_0001_deep.pdb -profile test.$num/target.fasta -repack no --debug_mode yes -deep yes
    ./run_proq3.sh test.$num/1e12A_0001_deep.subset.pdb -profile test.$num/target.fasta -repack yes --debug_mode yes -deep yes

    if [[ ! -f test.$num/1e12A_0001_deep.pdb.proq3.local || ! -f test.$num/1e12A_0001_deep.pdb.proq3.global ]] ; then
        echo "ERROR: ProQ3D failed to run. The output files don't exist"
        exit 1
    else
        check1d=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001_deep.pdb.proq3.local tests_clean/1e12A_0001_deep.pdb.proq3.local test.$num/1e12A_0001_deep.pdb.proq3.global tests_clean/1e12A_0001_deep.pdb.proq3.global 2>&1`
        check2d=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001_deep.pdb.proq3.local tests_clean/1e12A_0001_deep.pdb.proq3.local test.$num/1e12A_0001_deep.pdb.proq3.global tests_clean/1e12A_0001_deep.pdb.proq3.global 2>&1`
        check3d=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001_deep.subset.pdb.proq3.local tests_clean/1e12A_0001_deep.subset.pdb.proq3.local test.$num/1e12A_0001_deep.subset.pdb.proq3.global tests_clean/1e12A_0001_deep.subset.pdb.proq3.global 2>&1`
        check4d=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001_deep.subset.pdb.proq3.local tests_clean/1e12A_0001_deep.subset.pdb.proq3.local test.$num/1e12A_0001_deep.subset.pdb.proq3.global tests_clean/1e12A_0001_deep.subset.pdb.proq3.global 2>&1`
    fi

fi

echo "------------- Results of test run ------------------"

if [[ $check1 != "" || $check2 != "" || $check3 != "" || $check4 != "" ]] ; then
    echo "ProQ3 (SVM version) completed successfully, but the results in the output files don't match the sample results in tests_clean directory. Check your installation carefully..."
else
    echo "================ Congrats! Test run for ProQ3 (SVM version) has passed without any problems! ===================="
fi


if [[ $DEEP_INSTALLED == "yes" ]] ; then
    if [[ $check1d != "" || $check2d != "" || $check3d != "" || $check4d != "" ]] ; then
        echo "ProQ3D (Deep Learning version) completed successfully, but the results in the output files don't match the sample results in tests_clean directory. Check your installation carefully..."
    else
        echo "================ Congrats! Test run for ProQ3D (Deep Learning version) has passed without any problems! ===================="
    fi
fi

