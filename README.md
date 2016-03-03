ProQ3

Authors: Karolis Uziela (karolis.uziela@scilifelab.se), Björn Wallner (bjornw@ifm.liu.se)
Last updated: 2015-09-14

====================================== REQUIREMENTS ===============================================

1) Any of recent Rosetta weekly releases (week 36, 2013 or newer)
2) R 2.15.1 or newer with "zoo" package installed
3) EMBOSS package (http://emboss.sourceforge.net/download/)
4) Any Linux system. At the moment, ProQ3 is not supported on Mac or Windows.
5) ProQ3 also uses SSpro4, Psipred, Blast and SVM_light programs. For the convenience we have 
included these into the ProQ3 package, so you don't have to download it to use ProQ3. However, you 
should make sure that you have the appropriate licences before using the programs. The original 
packages are available here:
SSpro4 http://download.igb.uci.edu/sspro4.tar.gz
Psipred http://bioinfadmin.cs.ucl.ac.uk/downloads/psipred/old/psipred25.tar.gz
Blast ftp://ftp.ncbi.nlm.nih.gov/blast/executables/release/2.2.26/blast-2.2.26-x64-linux.tar.gz
SVM_light http://download.joachims.org/svm_light/current/svm_light_linux64.tar.gz

====================================== INSTALLATION ===============================================

Steps you need to do to install ProQ3 (order does not matter):
1) Set paths to Rosetta binary directory and Rosetta database in ./paths.sh (you can skip this step 
if $ROSETTA3 and $ROSETTA3_DB evnironment variables are already set)
2) Set path to Rscript binary in ./paths.sh (you can skip this step if Rscript is already in your 
path)
3) Set the $DB variable in ./bin/run_all_external.pl to a formated sequence database e.g. uniref90. 
If you don't have a formatted sequence database follow these steps:
  a) Download the database into an empty directory using command `wget 
ftp://ftp.ebi.ac.uk/pub/databases/uniprot/uniref/uniref90/uniref90.fasta.gz`
  b) Extract the files using command `gunzip uniref90.fasta.gz`
  c) Format the sequence database using command `<ProQ3_dir>/apps/blast-2.2.26/bin/formatdb -i 
uniref90.fasta
  d) Set $DB variable in ./bin/run_all_external.pl to your uniref90.fasta file
4) If you don't have "zoo" package, install it by launching R and typing install.packages("zoo")
5) Download and install EMBOSS package. Make sure that "needle" program is in your path.
6) Run ./configure.pl

======================================== TEST RUN =================================================

Go to ProQ3 installation directory and type ./run_test.sh to perform the test run. It should 
complete without any errors. The tests are run with -k/--keep_files option, so they output a little 
bit more files than usual. The most interesting output is in *.local and *.global files as 
explained below.

## Easy run of ProQ3
The simplest way to run ProQ3 is using the script `run_proq3.sh`
before running this script, copy the file `set_env.example.sh` to `set_env.sh`
and set the environmental variables accordingly. That is

    $ cp set_env.example.sh set_env.sh

and then change variables `rosetta_path` and and `BLAST_DATABASE` to the actual
locations in your system.

After that, you can run the script `run_proq3.sh` given your model files in PDB format
The syntax of `run_proq3.sh` is

<pre>
Usage:  run_proq3.sh PDB-model [PDB-model ...] [-l PDB-model-LISTFILE] 
                     [-fasta seqfile]
                     [-profile pathprofile]
                     [-outpath DIR]  [-q]
                     [-only-build-profile]

Description:
    Run ProQ3 given one or several PDB-models 
    When the sequence file of the target is given, the sequence profile will be
    calculated only once based on this given sequences, the sequences of all
    PDB-models should be a subset of this target sequence.

Options:
  -fasta   FILE     Set the target sequence in FASTA format
  -profile  STR     Path for pre-built profile
  -outpath  DIR     Set output path, (default: the same as model file)
  -l       FILE     Set the file containing paths of PDB-models, one model per line
  -q                Quiet mode
  -verbose          Run script in verbose mode
  -h, --help        Print this help message and exit

ProQ3 options:
  -r  yes|no        Whether to perform the side chain repacking (default: yes)
  -t     INT        Set the target length (default: length of the target sequence or model)
  -k  yes|no        Whether keep repacked models and SVM output (default: no)
</pre>

###Example commands for the `run_proq3.sh` script
   * run ProQ3 given just a model structure
        $ run_proq3.sh test/1e12A_0001.pdb -outpath test/out1

   * run ProQ3 for two model structures by given the amino acid sequence of the target
        $ run_proq3.sh -fasta test/1e12A.fasta test/1e12A_0001.pdb test/1e12A_0001.subset.pdb -outpath test/out2

   * run ProQ3 for two model structures with pre-built profile
        $ run_proq3.sh -profile test/profile/1e12A.fasta test/1e12A_0001.pdb test/1e12A_0001.subset.pdb -outpath test/out4



================================== BEFORE RUNING PROQ3 ============================================

ProQ3 is Model Quality Assessment Program that predictis the quality of individual models. To do 
this ProQ3 uses both information that can be calculated from the 3D coordinates of the model as 
well as information that can be predicted from the sequence. Of course the information that comes 
from the sequence is the same for all models of the same sequence. Thus, before scoring models the 
sequence specific features needs to be calculated.

A) The PDB model spans the whole target sequence
If your pdb model spans the whole sequence of the target protein then you can simply run:
./bin/run_all_external.pl -pdb [pdb-model]

The above will create [pdb-model].ss2, [pdb-model].acc, [pdb-model].psi and [pdb-model].mtx files.  
These files contain sequence-specific information that is needed to run ProQ3.

B) The PDB model covers only part of the target sequence
PDB models often have "missing residues" - not all of the residues in the target sequence are 
modelled. In that case it is better to extract sequence-specific features from the full target 
sequence and then copy them to the model.

./bin/run_all_external.pl -fasta [target-sequence-fasta]

./ProQ3/bin/copy_features_from_master.pl [pdb-model] [target-sequence-fasta]

After you run run_all_external.pl on [target-sequence-fasta] it will create 
[target-sequence-fasta].ss2, [target-sequence-fasta].acc, [target-sequence-fasta].psi and 
[target-sequence-fasta].mtx files. The script copy_features_from_master.pl will take relevant parts 
of these files and copy them to [pdb-model].ss2, [pdb-model].acc, [pdb-model].psi and 
[pdb-model].mtx files.

C) If you have several PDB models of the same target protein (which is often the case), you should 
run run_all_external.pl only once (which is the time consuming part). After that you can just use 
copy_features_from_master.pl to copy the sequence-specific features to all of the PDB models. This 
will work regardless whether your PDB models cover the whole or only part of the target sequence!

So basically, this is what you want to do most of the time:
./bin/run_all_external.pl -fasta [target-sequence-fasta]
./ProQ3/bin/copy_features_from_master.pl [first-pdb-model] [target-sequence-fasta]
./ProQ3/bin/copy_features_from_master.pl [second-pdb-model] [target-sequence-fasta]
./ProQ3/bin/copy_features_from_master.pl [third-pdb-model] [target-sequence-fasta]
etc.

====================================== RUNING PROQ3 ===============================================


Now you are ready to run ProQ3. Type ./ProQ3 without parameters to see the usage.

Usage: ProQ3 [parameters]

-m/--model               [pdb-model]
                             PDB model file to be evaluated
-r/--repack              [yes/no] default=yes
                             Should we perform the side chain repacking step?  
-t/--target_length       [Number_of_residues] default='model_length'
                             The global score is calculated as sum_of_local/target_length
-k/--keep_files          [yes/no] default=no 
                             Should we keep the repacked models and svm input files?
-l/--local_output        [output_file_local] default=[pdb-model].proq3.local
                             The output file for local predictions
-g/--global_output       [output_file_global] default=[pdb-model].proq3.global
                             The output file for global predictions
-o/--rosetta_log         [rosetta_log_file] default=[pdb-model].rosetta.log
                             The output file with Rosetta logs

The most basic usage is:

./ProQ3 [pdb-model]

This will will perform the side-chain repacking step and run ProQ3 on the input model. 

The default output files are:
[pdb-model].proq3.local - local scores (per residue)
[pdb-model].proq3.local - global scores (the predicted quality of the whole model)

Both local and global score files will contain 4 columns:
1) ProQ2 - ProQ2 prediction (as in the original ProQ2, but retrained on CASP9 data)
2) ProQ_lowres - ProQ predictions that are based on Rosetta low resolution (centroid) energy 
functions
3) ProQ_highres - ProQ predictions that are based on Rosetta high resolution energy functions
4) ProQ3 - ProQ3 predictions that combine all three of the above predictions

Other options explained in more detail:
-r/--repack           Controls whether the side chain rebuilding and energy minimization steps 
should be performed before evaluating the model structure. This takes more time, but the results 
are usually a little bit more accurate.
-t/--target_length    Sets the length of the target sequence by which global scores are normalized. 
By default ProQ3 assumes that the model spans the whole target, i. e. the target length is the same 
as the model length. The global score is calculated as sum_of_local/target_length. If you want to 
get just the sum of local scores, use --target_length 1.
-k/--keep_files       Use this option if you want to keep some of the intermediate files (i.e. 
repacked models and .svm input files), the names of the files are: 
    [pdb-model].repacked              PDB model with rebuilt side chains
    [pdb-model].repacked.minimized    PDB model with rebuilt side chains after short energy 
minimization step in Rosetta
    [pdb-model].proq2.svm             SVM input file for ProQ2
    [pdb-model].lowres.svm            SVM input file for ProQ_lowres
    [pdb-model].highres.svm           SVM input file for ProQ_highres
    [pdb-model].proq3.svm             SVM input file for ProQ3
-l/--local_output     By default ProQ3 outputs local predictions to [pdb-model].proq3.local. Use 
this option if you want to change the output file
-g/--global_output    By default ProQ3 outputs global predictions to [pdb-model].proq3.global. Use 
this option if you want to change the output file
-o/--rosetta_log      The log file where output from Rosetta will be written. Use /dev/null if you 
don't want to keep the logs. The default is [pdb-model].rosetta.log

================================= Thanks for using ProQ3! =========================================
