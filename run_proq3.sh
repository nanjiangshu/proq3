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
        $wspace [-only-build-profile]
        $wspace [-outpath DIR]
        $wspace [-keep_files] [-debug_mode]
        $wspace [-deep] [-repack] [-target_length]
        $wspace [-verbose] [-h]

Description:
    Run ProQ3 given one or several PDB-models 
    When the sequence file of the target is given, the sequence profile will be
    calculated only once based on this given sequences, the sequences of all
    PDB-models should be a subset of this target sequence.

Input/Output options:
  -l       FILE        Set the file containing paths of PDB-models, one model per line
  -fasta   FILE        Set the target sequence in FASTA format
  -profile  STR        Path for pre-built profile
  -only-build-profile  Build sequence profile without running ProQ3
  -outpath  DIR        Set output path, (default: the same as model file)
  -output_pdbs yes|no  Whether to output pdb files with ProQ3 local scores in B-factor field (default: no)
  -keep_files  yes|no  Whether to keep repacked models and SVM output (default: no)
  -debug_mode  yes|no  Whether to keep all temporary files

ProQ3 predictor options:
  -deep  yes|no                Whether to use Deep Learning (Theano) instead of SVM. If 'yes' runs ProQ3D (default: yes)
  -repack  yes|no              Whether to perform the side chain repacking (default: yes)
  -use_constant_seed yes|no    Whether to use a constant seed when runing Rosetta for side chain repacking (default: yes)
  -quality  STR                Which quality measure should be used as the target value in training? Possible options: sscore, tmscore, cad, lddt. Default: sscore
                               Note that quality measures other than sscore are only available when running with -deep yes and -repack yes options.
  -target_length  INT          Set the target length by which the global scores will be normalized (default: length of the target sequence or model)

Other options:
  -ncores              How many CPU cores should be used when building psiblast profile (default: 1)
  -verbose             Run script in verbose mode
  -h, --help           Print this help message and exit
    
Examples:
   # run ProQ3 (SVM version) for a given model structure and the full target protein sequence in fasta format (see note below)
   $progname tests_clean/1e12A_0001.pdb -fasta tests_clean/target.fasta -outpath test_out1 -deep no

   # run ProQ3 (SVM version) for two model structures with a given the amino acid sequence of the target
   $progname -fasta tests_clean/target.fasta tests_clean/1e12A_0001.pdb tests_clean/1e12A_0001.subset.pdb -outpath test_out2 -deep no

   # run ProQ3D for two model structures with pre-built profile
   $progname -profile tests_clean/target.fasta tests_clean/1e12A_0001.pdb tests_clean/1e12A_0001.subset.pdb -outpath test_out3 -deep yes

   # run ProQ3D for two model structures with pre-built profile and using CAD as the quality measure (target function)
   $progname -profile tests_clean/target.fasta tests_clean/1e12A_0001.pdb tests_clean/1e12A_0001.subset.pdb -outpath test_out3 -deep yes -quality cad
   
   # run ProQ3D for a list of models with pre-built profile and without repacking
   $progname -profile tests_clean/target.fasta -l tests_clean/model_list.txt -outpath test_out4 -deep yes -repack no

NOTE: If you don't provide target protein amino acid sequence in fasta format, the sequence will be extracted from the model. However, please,
always provide the target protein fasta sequence, unless you are sure that the model has a full amino acid sequence as in the target protein. 
Otherwise, ProQ3 results will not be accurate.
  
Created 2016-01-28, updated 2017-10-08

Authors: Karolis Uziela (karolis.uziela@gmail.com), David Menéndez Hurtado (david.menendez.hurtado@scilifelab.se), Nanjiang Shu (nanjiang.shu@scilifelab.se), Björn Wallner (bjornw@ifm.liu.se), Arne Elofsson (arne@bioinfo.se)

Cite: 
Uziela K, Shu N, Wallner B, Elofsson A (2016) 'ProQ3: Improved model quality assessments using Rosetta energy terms.' SciRep 6, 33509
Uziela K, Menéndez Hurtado D, Shu N, Wallner B, Elofsson A (2017) 'ProQ3D: improved model quality assessments using deep learning' Bioinformatics, doi: 10.1093/bioinformatics/btw819, PMID: 28052925.

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
    cmd="$rundir/ProQ3 -m $modelfile -r $isRepack -k $isKeepFiles -d $isDeep --debug_mode $isDebug --quality $quality --output_pdbs $isOutputPDB --use_constant_seed $isConstantSeed"
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
    exec_cmd "$rundir/bin/run_all_external.pl -pdb $modelfile -ncores $ncores"

    if [ $isOnlyBuildProfile -eq 0 ]; then
        cmd="$rundir/ProQ3 -m $modelfile -r $isRepack -k $isKeepFiles -d $isDeep --debug_mode $isDebug --quality $quality --output_pdbs $isOutputPDB --use_constant_seed $isConstantSeed"
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

g_outpath=
outfile=
modelListFile=
modelList=()
targetseqfile=
isRepack=yes
isDeep=yes
isDebug=no
isKeepFiles=no
isOutputPDB=no
isConstantSeed=yes
targetLength=
verbose=0
pathprofile=
isOnlyBuildProfile=0
ncores=1
quality='sscore'

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
            -r|-repack|--repack)optstr=$2;
                if [ "$optstr" == "yes" ]; then
                    isRepack=yes
                elif [ "$optstr" == "no" ];then
                    isRepack=no
                else
                    echo "Bad argument \"$optstr\" after the option -repack, should be yes or no" >&2
                    exit 1
                fi
                shift;;
            -d|-deep|--deep)optstr=$2;
                if [ "$optstr" == "yes" ]; then
                    isDeep=yes
                elif [ "$optstr" == "no" ];then
                    isDeep=no
                else
                    echo "Bad argument \"$optstr\" after the option -deep, should be yes or no" >&2
                    exit 1
                fi
                shift;; 
            -q|-quality|--quality)optstr=$2;
                if [ "$optstr" != "sscore" ] && [ "$optstr" != "tmscore" ] && [ "$optstr" != "lddt" ] && [ "$optstr" != "cad" ] ; then
                    echo "Bad argument \"$optstr\" after the option -quality, should be sscore, tmscore, lddt or cad"
                else
                    quality="$optstr"
                fi
                shift;;
            -debug_mode|--debug_mode)optstr=$2;
                if [ "$optstr" == "yes" ]; then
                    isDebug=yes
                elif [ "$optstr" == "no" ];then
                    isDebug=no
                else
                    echo "Bad argument \"$optstr\" after the option -debug_mode, should be yes or no" >&2
                    exit 1
                fi
                shift;;  
            -k|-keep_files|--keep_files)optstr=$2;
                if [ "$optstr" == "yes" ]; then
                    isKeepFiles=yes
                elif [ "$optstr" == "no" ];then
                    isKeepFiles=no
                else
                    echo "Bad argument \"$optstr\" after the option -keep_files, should be yes or no" >&2
                    exit 1
                fi
                shift;;
            -output_pdbs|--output_pdbs)optstr=$2;
                if [ "$optstr" == "yes" ]; then
                    isOutputPDB=yes
                elif [ "$optstr" == "no" ];then
                    isOutputPDB=no
                else
                    echo "Bad argument \"$optstr\" after the option -output_pdbs, should be yes or no" >&2
                    exit 1
                fi
                shift;;             
            -use_constant_seed|--use_constant_seed)optstr=$2;
                if [ "$optstr" == "yes" ]; then
                    isConstantSeed=yes
                elif [ "$optstr" == "no" ];then
                    isConstantSeed=no
                else
                    echo "Bad argument \"$optstr\" after the option -output_pdbs, should be yes or no" >&2
                    exit 1
                fi
                shift;;           
            -t|-target_length|--target_length) targetlength=$2;shift;;
            -ncores|--ncores) ncores=$2;shift;;
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
        exit 1
    fi
fi

if [ "$quality" != "sscore" ] ; then
    if [ "$isDeep" != "yes" ] ; then
        echo "Error: Argument -quality $quality can only be used with the deep version of the program, ProQ3D (-deep yes)"
        exit 1
    elif [ "$isRepack" != "yes" ] ; then
        echo "Error: Argument -quality $quality can only be used with repacked models (-repack yes)"
        exit 1
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
        if [ -s "$workingseqfile.psi" ]; then
            echo "Note: found $workingseqfile.psi in the output directory. Using existing profile instead of a building a new one."
            pathprofile=$workingseqfile
        fi
    else
        if [ ! -s "$pathprofile.psi" ];then
            echo "The pathprofile \"$pathprofile\" is supplied, but profile info is empty. " >&2
            exit 1
        fi
        workingseqfile=$pathprofile
    fi

    if [ "$pathprofile" == "" ] ; then
        exec_cmd "$rundir/bin/run_all_external.pl -fasta $workingseqfile -ncores $ncores"
    fi

    if [ $isOnlyBuildProfile -eq 0 ] ;then
        for ((i=0;i<numModel;i++));do
            modelfile=${modelList[$i]}
            RunProQ3_with_profile "$modelfile"
        done
    fi

else
    echo "
NOTE: It is always recommended to provide full target sequence or pre-built target profile (-fasta or -profile) options.
      Some of the pdb models do not have all residues in the target. If the model is shorter than the target and you don't provide
      the full target sequence, the global scores will be incorrectly normalized and this might also affect psiblast results.
      However, if you are sure that the model has full amino acid sequence, or if the full sequence is not available,
      you can run ProQ3 just by providing the pdb model. In this case we will extract fasta sequence from the model.
"
    for ((i=0;i<numModel;i++));do
        modelfile=${modelList[$i]}
        RunProQ3_without_profile "$modelfile"
    done
fi

