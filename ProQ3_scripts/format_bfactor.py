#!/usr/bin/env python

# Written by Karolis Uziela in 2018

import sys
from math import sqrt

################################ Usage ################################

script_name = sys.argv[0]

usage_string = """
Usage:

    %s [Parameters]
    
Parameters:

    <input-pdb> - input pdb file
    <input-local> - input local score file (one column, no header)
    <output-pdb> - output pdb file with local scores in B-factor column
    <return-dist> - should we return distance in b-factor column instead of a quality score (TRUE/FALSE)
""" % script_name

if len(sys.argv) != 5:
    sys.exit(usage_string)

################################ Functions ################################

def read_pdb(filename, scores):
    
    f = open(filename)
    last_res_seq = ""
    res_n = 0
    out_str = ""
    while True:
        line = f.readline()
        if len(line) == 0: 
            break
        if line[0:4] == "ATOM":
            line = line.rstrip('\n')
            res_seq = line[21:27]
            if res_seq != last_res_seq:
                last_res_seq = res_seq
                res_n += 1
            #bits = line.split("\t")    
            line_formatted = line[:60] + scores[res_n - 1] + line[66:] + "\n"
            out_str += line_formatted
            #print line
            #print line_formatted
            #print res_seq
            #print res_n
    f.close()
    if len(scores) != res_n:
        sys.stderr.write("ERROR: length of local scores file does not match number of residues in pdb: " + filename + "\n")
    return out_str

def read_scores(filename, return_dist):
    scores = []    
    f = open(filename)
    
    while True:
        line = f.readline()
        if len(line) == 0: 
            break
        line = line.rstrip('\n')
        score = float(line)
        if return_dist == "yes":
            score = s2d(score)
        score_str = "%6.3f" % score
        scores.append(score_str)
        #bits = line.split("\t")    
        #print line
        
    f.close()
    return scores

def write_data(output_file, out_str):
    f = open(output_file,"w")
    #out_str = "%s %f \n" % str_var f_var
    f.write(out_str)
    f.close()

def s2d(s):
    d0=3
    #d=15 # for CASP we cap the distance at 15 angstroms
    d=99.999 # for CASP we cap the distance at 100 angstroms
    #if s>0.03846: # this is the S score for 15 angstroms
    if s>0.0009: # this is the S score for 100 angstroms
        if s>=1:
            d=0
        else:
            d=sqrt(1/s-1)*d0
    return d

################################ Variables ################################

# Input files/directories
input_file = sys.argv[1]
local_score_file = sys.argv[2]
output_file = sys.argv[3]
return_dist = sys.argv[4]

# Output files/directories
# N/A

# Constants
# N/A

# Global variables
# N/A

################################ Main script ################################
    
#sys.stderr.write("%s is running with arguments: %s\n" % (script_name, str(sys.argv[1:])))

scores = read_scores(local_score_file, return_dist)

out_str = read_pdb(input_file, scores)

#print out_str,

write_data(output_file, out_str)

#print scores

#sys.stderr.write("%s done.\n" % script_name)



