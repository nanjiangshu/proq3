#!/bin/bash

# Filename: run_proq3.sh
# Description: Run Proq3 by given the PDB model
# Authors: Nanjiang Shu (nanjiang.shu@scilifelab.se), Karolis Uziela (karolis.uziela@scilifelab.se), Björn Wallner (bjornw@ifm.liu.se)

SCRIPT_PATH=`readlink -f ${BASH_SOURCE[0]}`
rundir=`dirname $SCRIPT_PATH`
progname=`basename $0`
size_progname=${#progname}
wspace=`printf "%*s" $size_progname ""` 
usage="
Usage:  $progname PDB-model [PDB-model ...] [-l PDB-model-LISTFILE ...] 
        $wspace [-fasta seqfile]
        $wspace [-profile pathprofile]
        $wspace [-outpath DIR]
        $wspace [-only-build-profile]
        $wspace [-q] [-verbose] [-h]
        $wspace [-r] [-t] [-k]

Description:
    Run ProQ3 given one or several PDB-models 
    When the sequence file of the target is given, the sequence profile will be
    calculated only once based on this given sequences, the sequences of all
    PDB-models should be a subset of this target sequence.

Options:
  -l       FILE        Set the file containing paths of PDB-models, one model per line
  -fasta   FILE        Set the target sequence in FASTA format
  -profile  STR        Path for pre-built profile
  -outpath  DIR        Set output path, (default: the same as model file)
  -only-build-profile  Build sequence profile without running ProQ3
  -q                   Quiet mode
  -verbose             Run script in verbose mode
  -h, --help           Print this help message and exit

ProQ3 options:
  -r  yes|no           Whether to perform the side chain repacking (default: yes)
  -t     INT           Set the target length (default: length of the target sequence or model)
  -k  yes|no           Whether keep repacked models and SVM output (default: no)

Examples:
   # run ProQ3 for given just a model structure
   $progname test/1e12A_0001.pdb -outpath test/out1

   # run ProQ3 for two model structures by given the amino acid sequence of the target
   $progname -fasta test/1e12A.fasta test/1e12A_0001.pdb test/1e12A_0001.subset.pdb -outpath test/out2

   # run ProQ3 for two model structures with pre-built profile
   $progname -profile test/profile/1e12A.fasta test/1e12A_0001.pdb test/1e12A_0001.subset.pdb -outpath test/out4

Created 2016-01-28, updated 2016-04-26
Authors: Nanjiang Shu (nanjiang.shu@scilifelab.se), Karolis Uziela (karolis.uziela@scilifelab.se), Björn Wallner (bjornw@ifm.liu.se)


"
PrintHelp(){ #{{{
    echo "$usage"
}
#}}}
IsProgExist(){ #{{{
    # usage: IsProgExist prog
    # prog can be both with or without absolute path
    type -P $1 &>/dev/null \
        || { echo The program \'$1\' is required but not installed. \
        Aborting $0 >&2; exit 1; }
    return 0
}
#}}}
IsPathExist(){ #{{{
# supply the effective path of the program 
    if ! test -d "$1"; then
        echo Directory \'$1\' does not exist. Aborting $0 >&2
        exit 1
    fi
}
#}}}
exec_cmd(){ #{{{
    if [ "$verbose" -eq "1" ];then
        echo "$*"
    fi
    eval "$*"
}
#}}}
RunProQ3_with_profile(){ 
    # not finished
    local modelfile="$1"
    if [ ! -s "$modelfile" ];then
        echo "modelfile \"$modelfile\" is empty or does not exist. Ignore" >&2
        return 1
    fi
    modelfile=`readlink -f $modelfile`
    basename_modelfile=`basename $modelfile`
    local path_modelfile=`dirname $modelfile`
    local outpath=
    if [ "$g_outpath" != "" ];then
        outpath=$g_outpath
    else
        outpath=$path_modelfile
    fi

    if [ "$outpath" != "$path_modelfile" ];then
        exec_cmd "cp -f $modelfile $outpath/"
        modelfile=$outpath/$basename_modelfile
    fi
    exec_cmd "$rundir/bin/copy_features_from_master.pl $modelfile $workingseqfile"
    cmd="$rundir/ProQ3 -m $modelfile -r $isRepack -k $isKeepFiles"
    if [ "$targetlength" == "" ];then
        targetlength=`tail -n +2 $workingseqfile | tr -d "\n" | wc -c`
    fi
    cmd="$cmd -t $targetlength"
    exec_cmd "$cmd"
    echo "ProQ3 run finished for $modelfile"
}

RunProQ3_without_profile(){ 
    local modelfile="$1"
    if [ ! -s "$modelfile" ];then
        echo "modelfile \"$modelfile\" is empty or does not exist. Ignore" >&2
        return 1
    fi
    modelfile=`readlink -f $modelfile`
    basename_modelfile=`basename $modelfile`
    local path_modelfile=`dirname $modelfile`
    local outpath=
    if [ "$g_outpath" != "" ];then
        outpath=$g_outpath
    else
        outpath=$path_modelfile
    fi

    if [ "$outpath" != "$path_modelfile" ];then
        cp -f $modelfile $outpath/
        modelfile=$outpath/$basename_modelfile
    fi
    exec_cmd "$rundir/bin/run_all_external.pl -pdb $modelfile"

    if [ $isOnlyBuildProfile -eq 0 ]; then
        cmd="$rundir/ProQ3 -m $modelfile -r $isRepack -k $isKeepFiles"
        if [ "$targetlength" != "" ];then
            cmd="$cmd -t $targetlength"
        fi
        exec_cmd "$cmd"
    fi
    echo "ProQ3 run finished for $modelfile"
}


if [ $# -lt 1 ]; then
    PrintHelp
    exit
fi

isQuiet=0
g_outpath=
outfile=
modelListFile=
modelList=()
targetseqfile=
isRepack=yes
isKeepFiles=no
targetLength=
verbose=0
pathprofile=
isOnlyBuildProfile=0

isNonOptionArg=0
while [ "$1" != "" ]; do
    if [ $isNonOptionArg -eq 1 ]; then 
        modelList+=("$1")
        isNonOptionArg=0
    elif [ "$1" == "--" ]; then
        isNonOptionArg=1
    elif [ "${1:0:1}" == "-" ]; then
        case $1 in
            -h | --help) PrintHelp; exit;;
            -outpath|--outpath) g_outpath=$2;shift;;
            -fasta|--fasta) targetseqfile=$2;shift;;
            -profile|--profile) pathprofile=$2;shift;;
            -l|--l|-list|--list) modelListFile=$2;shift;;
            -q|-quiet|--quiet) isQuiet=1;;
            -r|-repack|--repack)optstr=$2;
                if [ "$optstr" == "yes" ]; then
                    isRepack=yes
                elif [ "$optstr" == "no" ];then
                    isRepack=no
                else
                    echo "Bad argument \"$optstr\" after the option -r, should be yes or no" >&2
                    exit 1
                fi
                shift;;
            -k|-keep-files|--keep-files)optstr=$2;
                if [ "$optstr" == "yes" ]; then
                    isKeepFiles=yes
                elif [ "$optstr" == "no" ];then
                    isKeepFiles=no
                else
                    echo "Bad argument \"$optstr\" after the option -k, should be yes or no" >&2
                    exit 1
                fi
                shift;;
            -t|-targetlength|--targetlength) targetlength=$2;shift;;
            -verbose|--verbose) verbose=1;;
            -only-build-profile|--only-build-profile) isOnlyBuildProfile=1;;
            -*) echo Error! Wrong argument: $1 >&2; exit;;
        esac
    else
        modelList+=("$1")
    fi
    shift
done

IsProgExist readlink

if [ "$modelListFile" != ""  ]; then 
    if [ -s "$modelListFile" ]; then 
        while read line
        do
            modelList+=("$line")
        done < $modelListFile
    else
        echo listfile \'$modelListFile\' does not exist or empty. >&2
    fi
fi

numModel=${#modelList[@]}
if [ $isOnlyBuildProfile -eq 0 -a $numModel -eq 0  ]; then
    echo Input not set! Exit. >&2
    exit 1
fi

if [ "$g_outpath" != "" ] ; then
    if [ ! -d "$g_outpath" ];then
        mkdir -p "$g_outpath"
    fi
    if [ ! -d "$g_outpath" ];then
        echo "Failed to create outpath \"$g_outpath\". exit."   >&2
        exit 1
    fi
    g_outpath=`readlink -f $g_outpath`
fi

source $rundir/paths.sh

if [ "$targetseqfile" != "" -o "$pathprofile" != ""  ];then
    if [ "$targetseqfile" != "" ];then
        targetseqfile=`readlink -f $targetseqfile`
        if [ ! -s "$targetseqfile" ];then
            echo "The target sequence file \"$targetseqfile\" is supplied, but it does not exist or empty. " >&2
            exit 1
        fi
        basename_targetseqfile=`basename $targetseqfile`
        rootname_targetseqfile=${basename_targetseqfile%.*}
        path_targetseqfile=`dirname $targetseqfile`
        if [ "$g_outpath" != ""  ];then
            workingseqfile=$g_outpath/${rootname_targetseqfile}.fasta
        else
            workingseqfile=$path_targetseqfile/${rootname_targetseqfile}.fasta
        fi

        if [ "$workingseqfile" != "$targetseqfile" ];then
            exec_cmd "cp -f $targetseqfile $workingseqfile"
        fi
    else
        if [ ! -s "$pathprofile.psi" ];then
            echo "The pathprofile \"$pathprofile\" is supplied, but profile info is empty. " >&2
            exit 1
        fi
        workingseqfile=$pathprofile
    fi

    exec_cmd "$rundir/bin/run_all_external.pl -fasta $workingseqfile"

    if [ $isOnlyBuildProfile -eq 0 ] ;then
        for ((i=0;i<numModel;i++));do
            modelfile=${modelList[$i]}
            RunProQ3_with_profile "$modelfile"
        done
    fi

else
    for ((i=0;i<numModel;i++));do
        modelfile=${modelList[$i]}
        RunProQ3_without_profile "$modelfile"
    done
fi

