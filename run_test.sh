#!/bin/bash

source ./paths.sh       # Read in paths

num=$$

skip_profile=$1

echo "------------- Testing build profile ------------------"

mkdir test.$num
cp tests_clean/*.pdb test.$num/
cp tests_clean/target.fasta test.$num/

if [[ "$skip_profile" == "-skip" || "$skip_profile" == "--skip" || "$skip_profile" == "skip" ]] ; then
    cp tests_clean/target.fasta.* test.$num/
else
    ./run_proq3.sh -fasta test.$num/target.fasta -only-build-profile
fi

echo "------------- Testing ProQ3 ------------------"

./run_proq3.sh test.$num/1e12A_0001.pdb -profile test.$num/target.fasta -repack no --debug_mode yes -deep no
./run_proq3.sh test.$num/1e12A_0001.subset.pdb -profile test.$num/target.fasta -repack yes --debug_mode yes -deep no

if [[ ! -f test.$num/1e12A_0001.pdb.proq3.sscore.local || ! -f test.$num/1e12A_0001.pdb.proq3.sscore.global || ! -f test.$num/1e12A_0001.subset.pdb.proq3.sscore.local || ! -f test.$num/1e12A_0001.subset.pdb.proq3.sscore.global ]] ; then
    echo "ERROR: ProQ3 failed to run. The output files don't exist"
    exit 1
else
    check1=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001.pdb.proq3.sscore.local tests_clean/1e12A_0001.pdb.proq3.sscore.local test.$num/1e12A_0001.pdb.proq3.sscore.global tests_clean/1e12A_0001.pdb.proq3.sscore.global 2>&1`
    check2=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001.subset.pdb.proq3.sscore.local tests_clean/1e12A_0001.subset.pdb.proq3.sscore.local test.$num/1e12A_0001.subset.pdb.proq3.sscore.global tests_clean/1e12A_0001.subset.pdb.proq3.sscore.global 2>&1`
fi

if [[ $DEEP_INSTALLED == "yes" ]] ; then
    echo "------------- Testing ProQ3D (deep learning version) ------------------"

    ./run_proq3.sh test.$num/1e12A_0001_deep.pdb -profile test.$num/target.fasta -repack no --debug_mode yes -deep yes
    ./run_proq3.sh test.$num/1e12A_0001_deep.subset.pdb -profile test.$num/target.fasta -repack yes --debug_mode yes -deep yes

    if [[ ! -f test.$num/1e12A_0001_deep.pdb.proq3d.sscore.local || ! -f test.$num/1e12A_0001_deep.pdb.proq3d.sscore.global ]] ; then
        echo "ERROR: ProQ3D failed to run. The output files don't exist"
        exit 1
    else
        check1d=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001_deep.pdb.proq3d.sscore.local tests_clean/1e12A_0001_deep.pdb.proq3d.sscore.local test.$num/1e12A_0001_deep.pdb.proq3d.sscore.global tests_clean/1e12A_0001_deep.pdb.proq3d.sscore.global 2>&1`
        check2d=`$R_SCRIPT ./ProQ3_scripts/test_verify.R test.$num/1e12A_0001_deep.subset.pdb.proq3d.sscore.local tests_clean/1e12A_0001_deep.subset.pdb.proq3d.sscore.local test.$num/1e12A_0001_deep.subset.pdb.proq3d.sscore.global tests_clean/1e12A_0001_deep.subset.pdb.proq3d.sscore.global 2>&1`
    fi

fi

echo "------------- Results of test run ------------------"

if [[ $check1 != "" || $check2 != "" ]] ; then
    echo "ProQ3 (SVM version) completed successfully, but the results in the output files don't match the sample results in tests_clean directory. Check your installation carefully..."
else
    echo "================ Congrats! Test run for ProQ3 (SVM version) has passed without any problems! ===================="
fi


if [[ $DEEP_INSTALLED == "yes" ]] ; then
    if [[ $check1d != "" || $check2d != "" ]] ; then
        echo "ProQ3D (Deep Learning version) completed successfully, but the results in the output files don't match the sample results in tests_clean directory. Check your installation carefully..."
    else
        echo "================ Congrats! Test run for ProQ3D (Deep Learning version) has passed without any problems! ===================="
    fi
fi

