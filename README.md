#ProQ3/ProQ3D

###Authors: 
Karolis Uziela (karolis.uziela@gmail.com)

David Menéndez Hurtado (david.menendez.hurtado@scilifelab.se)

Nanjiang Shu (nanjinag.shu@scilifelab.se)

Björn Wallner (bjornw@ifm.liu.se)

Arne Elofsson (arne@bioinfo.se)

Last updated: 2016-10-05

## Installation and usage with Docker
To simplify installing ProQ3/ProQ3D locally, we have made a Docker image and
two assisting scripts [install_blastdb.sh](./install_blastdb.sh) and [install_rosetta.sh](./install_rosetta.sh).
Please also refer to https://docs.docker.com/engine/installation/ for the
installation of Docker.

1. Get Docker image 

    `docker pull nanjiang/proq3`

2. Prepare BLAST database. If you do not have `uniref90.fasta` BLAST database
   available, please use the script [install_blastdb.sh](./install_blastdb.sh) provided in this git repo 
   Suppose you want to install the BLAST database at `/data/blastdb`, run

    `./install_blastdb.sh /data/blastdb`

3. Prepare the Rosetta package. If you do not have a local copy of the Rosetta
   package, please use the script [install_rosetta.sh](./install_rosetta.sh)
   provided in this git repo. For Academic User, you can obtain a free license
   from https://www.rosettacommons.org/software/license-and-download. And you
   will be given a `PASSWORD` by email. Suppose you want to install the Rosetta package
   at `/data/rosetta`, run

    `./install_rosetta.sh /data/rosetta PASSWORD`

4. Start the docker container (in background, remote the option `-it` if you
   want to run in foreground) assuming you have the BLAST database installed at
   `data/blastdb` and Rosetta installed at `/data/rosetta`. The Docker
   container starts with your local user `$USER` in the following command, but
   can be started with any user to your preference. We also mount the dir
   `/scratch` on localhost to the `/scratch` within the container.

    `docker run  -e USER_ID=$(id -u $USER) -v /data/blastdb:/home/app/proq3/database/blastdb -v /data/rosetta/rosetta_2014.16.56682_bundle:/home/app/proq3/apps/rosetta -v /scratch:/scratch  -it --name proq3 -d  nanjiang/proq3`

5. Now you can test run the ProQ3 command 

* Run ProQ3 for the model `1e12A_0001.pdb` with prebuilt profile and output the result to `/scratch/outproq3-1`

    `docker exec  proq3 script /dev/null -c "/home/app/proq3/run_proq3.sh --profile /home/app/proq3/tests_clean/target.fasta /home/app/proq3/tests_clean/1e12A_0001.pdb -outpath /scratch/outproq3-1"`

* Run ProQ3 for the model `1e12A_0001.pdb` with from scratch (blastpgp will be run) and output the result to `/scratch/outproq3-2`

    `docker exec  proq3 script /dev/null -c "/home/app/proq3/run_proq3.sh /home/app/proq3/tests_clean/1e12A_0001.pdb -outpath /scratch/outproq3-2"`

* Run ProQ3 with your own model structure, e.g. at `/scratch/yourmodel.pdb` and output the result to `/scratch/out-yourmodel`

    `docker exec  proq3 script /dev/null -c "/home/app/proq3/run_proq3.sh /scratch/yourmodel.pdb -outpath /scratch/out-yourmodel"`


### More details of the ProQ3/ProQ3D package are described below

## Requirements

1. Any of recent Rosetta weekly releases (week 36, 2013 or newer)

2. R 2.15.1 or newer with "zoo" package installed

3. EMBOSS package (http://emboss.sourceforge.net/download/)

4. Any Linux system. At the moment, ProQ3 is not supported on Mac or Windows.

5. ProQ3 also uses SSpro4, Psipred, Blast and SVM_light programs. For the convenience we have 
included these into the ProQ3 package, so you don't have to download it to use ProQ3. However, you 
should make sure that you have the appropriate licences before using the programs. The original 
packages are available here:

    * SSpro4 http://download.igb.uci.edu/sspro4.tar.gz

    * Psipred http://bioinfadmin.cs.ucl.ac.uk/downloads/psipred/old/psipred25.tar.gz

    * Blast ftp://ftp.ncbi.nlm.nih.gov/blast/executables/release/2.2.26/blast-2.2.26-x64-linux.tar.gz

    * SVM_light http://download.joachims.org/svm_light/current/svm_light_linux64.tar.gz

If you would like to use the deep learning version of the predictor (ProQ3D), there are a few additional requirements:

1. Python installation (Python 2.7-3.5)

2. Python numpy package

3. Python h5py package

4. Python keras package v.2.0 or newer (Theano backend). NOTE: if you want to use keras v.1, you can checkout earlier version of ProQ3D, git tag v3.1.1 (git clone --branch v3.1.1 git@bitbucket.org:ElofssonLab/proq3.git)

Please, note that ProQ3D was trained using Cuda/GPU, but this is not a requirement to run ProQ3D. The prediction
is much faster than training, so you can simply use CPU to make ProQ3D predictions. If Cuda is not installed, 
python will use CPU by default. The prediction itself (excluding feature generation) takes under 1 second for a single
model using either CPU or GPU.

## Installation

Firstly, rename the file ./paths_example.sh to ./paths.sh

Then follow these steps to install ProQ3 (the order does not matter):

1. Set "rosetta_path" variable to point to Rosetta installation direcotry in ./paths.sh

2. Set path to Rscript binary in ./paths.sh (you can skip this step if Rscript is already in your path)

3. Set the $BLAST_DATABASE variable in ./paths.sh to point to a formated sequence database e.g. uniref90. 
If you don't have a formatted sequence database follow these steps:

    1. Download the database into an empty directory using command `wget ftp.ebi.ac.uk/pub/databases/uniprot/uniref/uniref90/uniref90.fasta.gz`

    2. Extract the files using command `gunzip uniref90.fasta.gz`

    3. Format the sequence database using command `<ProQ3_dir>/apps/blast-2.2.26/bin/formatdb -i 
uniref90.fasta

    4. Set $DB variable in ./bin/run_all_external.pl to your uniref90.fasta file

4. If you don't have "zoo" package, install it by launching R and typing install.packages("zoo")

5. Download and install EMBOSS package. Make sure that "needle" program is in your path.

6. Run ./configure.pl

If you would like to use the deep learning version of the predictor (ProQ3D), there are a few additional steps:

1. Set path to python executable in ./paths.sh (you can skip this step if "python" is already in your path)

2. If you don't have "numpy" package, install it by typing `pip install numpy`

3. If you don't have "h5py" package, install it by typing `pip install h5py`

4. If you don't have "keras" package, install it by typing `pip install keras`

##Test run

Go to ProQ3 installation directory and type 

    $ ./run_test.sh

to perform the test run. It should complete without any errors.

If you want to save time and skip the profile generation step that runs psiblast when testing, you can add "-skip" option:

    $ ./run_test.sh -skip

This will use the pre-generated profile in the test run. However, it is recommended you test the whole installation 
including the profile generation step.

The tests are run with `--debug_mode` option, so they output a little 
bit more files than usual. The most interesting output is in `*.local` and `*.global` files as 
explained below.


## Running ProQ3/ProQ3D
The simplest way to run ProQ3 is using the script `run_proq3.sh`

The syntax of `run_proq3.sh` is

```
Usage:  run_proq3.sh PDB-model [PDB-model ...] [-l PDB-model-LISTFILE ...]
                     [-fasta seqfile]
                     [-profile pathprofile]
                     [-only-build-profile]
                     [-outpath DIR]
                     [-keep_files] [-debug_mode]
                     [-deep] [-repack] [-target_length]
                     [-q] [-verbose] [-h]

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
  -keep_files  yes|no  Whether to keep repacked models and SVM output (default: no)
  -debug_mode  yes|no  Whether to keep all temporary files

ProQ3 predictor options:
  -deep  yes|no        Whether to use Deep Learning (Theano) instead of SVM. If 'yes' runs ProQ3D (default: yes)
  -repack  yes|no      Whether to perform the side chain repacking (default: yes)
  -target_length  INT  Set the target length by which the global scores will be normalized (default: length of the target sequence or model)

Other options:
  -ncores              How many CPU cores should be used when building psiblast profile (default: 1)
  -q                   Quiet mode
  -verbose             Run script in verbose mode
  -h, --help           Print this help message and exit
```

###Example commands for using the script `run_proq3.sh`
   * run ProQ3 for a given model structure (see NOTE below)

        $ run_proq3.sh tests_clean/1e12A_0001.pdb -outpath test_out1


   * run ProQ3 for two models structures with a given the amino acid sequence of the target

        $ run_proq3.sh -fasta tests_clean/target.fasta tests_clean/1e12A_0001.pdb tests_clean/1e12A_0001.subset.pdb -outpath test_out2


   * run ProQ3D for two model structures with pre-built profile

        $ run_proq3.sh -profile tests_clean/target.fasta tests_clean/1e12A_0001.pdb tests_clean/1e12A_0001.subset.pdb -outpath test_out3 -deep yes

   * run ProQ3D for a list of models with pre-built profile and without repacking

        $ run_proq3.sh -profile tests_clean/target.fasta -l tests_clean/model_list.txt -outpath test_out4 -deep yes -repack no

NOTE: It is always recommended to provide full target sequence or pre-built target profile (-fasta or -profile) options.
Some of the pdb models do not model all residues in the target. If the model is shorter than the target and you don't provide
the full target sequence, the global scores will be incorrectly normalized and this might also affect psiblast results.
However, if you are sure that the model has full amino acid sequence, or if the full sequence is not available, 
you can run ProQ3 just by providing the pdb model as in the first example.

###Output files

The default output files are:

    * [pdb-model].proq3.local - local scores (per residue)

    * [pdb-model].proq3.global - global scores (the predicted quality of the whole model)

Both local and global score files will contain 4 columns:

1. ProQ2 - ProQ2 prediction (as in the original ProQ2, but retrained on CASP9 data)

2. ProQRosCen - ProQ predictions that are based on Rosetta low resolution (centroid) energy 
functions

3. ProQRosFA - ProQ predictions that are based on Rosetta high resolution (full-atom) energy functions

4. ProQ3 - ProQ3 predictions that combine all three of the above predictions

If you are using the deep learning version of the predictor (-deep option), then your output files will have columns
ProQ2D, ProQRosCenD, ProQRosFAD and ProQ3D which correspond to deep learning version scores.

If you are only interested in ProQ3/ProQ3D scores, you can simply use the 4th column in [pdb-model].proq3.local and [pdb-model].proq3.global files.

###Options explained in more detail

* PDB-model           You can enter one or more PDB models to be evaluated by ProQ3 in the same run if they share the same target sequence.

* -l FILE             Takes text file with a list of pdb files as an input. When you want to run
ProQ3/ProQ3D for many input pdbs with the same target sequence, it is sometimes more convenient have them as a list in a file.
For example, you can create a list with a command `ls --color=never tests_clean/*pdb > tests_clean/model_list.txt`

* -fasta FILE         This is the target sequence of your pdb model. If you don't provide neither
this argument nor -profile argument, the target sequence will be extracted from the pdb model itself.
However, it is always recommended to provide the target sequence. Firstly, if the model does not
have all amino acids of the target, the global scores will not be correctly normalized unless the target
length is known. Secondly, if the model is significantly shorter than the target sequence, this might
affect the psiblast results that are used for RSA, SS and Conservation feature calculation.

* -profile FILE       If you have already run ProQ3 for a model of the same target, you can just enter
the location where the target's profile was stored (.acc, .ss2, .mtx and .psi files). Usually, this is either
a place that you entered for -fasta option in the previous run or -outpath. Building a target's profile
(running psiblast) is the most time consuming step of running ProQ3/ProQ3D, so you shouldn't do that more than
once for the same target.

* -only-build-profile If you want only to build profile (run psi-blast) for the target sequence, you can
run ProQ3 with this option. The next time you can run ProQ3/ProQ3D for models of the same target by
using -profile option to use the profile that you already created.

* -outpath DIR        By default ProQ3/ProQ3D will output files in the same directory as the pdb model. However,
if you want to use another directory for the output, you can use this option.

* -repack             Controls whether the side chain rebuilding and energy minimization steps 
should be performed before evaluating the model structure. This takes more time, but the results 
are usually a little bit more accurate.

* -deep               Controls whether we should use deep learning version of the predictor (ProQ3D) or SVM (ProQ3) 

* -target_length  INT This is a number by which global scores will be normalized. By default, ProQ3/ProQ3D score is
a sum of local scores divided by the target sequence length (or a model length if the target sequence is not provided).
By using this option, you can change this behavior. For example, if you don't have the target sequence, but you know the
target length, you can still enter the length here so that the global scores are correctly normalized. Alternatively, if
you know the native structure and you are comparing ProQ3 score with GDT_TS or TMscore, you might want to enter the length
of the native structure here (which sometimes is shorter than the target sequence), because GDT_TS and TMscore are normalized
by the length of native structure. Finally, if you just want to get the sum of the local scores, you can enter --target_length 1.

* -keep_files         Use this option if you want to keep some of the intermediate files (i.e. 
repacked models and .svm input files), the names of the files are: 

    * [pdb-model].repacked              PDB model with rebuilt side chains
    * [pdb-model].repacked.minimized    PDB model with rebuilt side chains after short energy 
minimization step in Rosetta
    * [pdb-model].proq2.svm             SVM input file for ProQ2
    * [pdb-model].lowres.svm            SVM input file for ProQ_lowres
    * [pdb-model].highres.svm           SVM input file for ProQ_highres
    * [pdb-model].proq3.svm             SVM input file for ProQ3
    * [pdb-model].rosetta.log           Rosetta log file

* -debug_mode         Keeps all temporary files. 

* -ncores             Controls how many CPU cores should be used when building psiblast profile. Recommended to set to at least 4 if you have that many cores available.

Good luck using ProQ3/ProQ3D!


