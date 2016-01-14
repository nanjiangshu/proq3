#!/usr/bin/env python

# Written by Karolis Uziela in 2014

import sys

################################ Usage ################################

script_name = sys.argv[0]

usage_string = """
Description:

The script checks if the psiblast matrix file (.psi) does not contain all-zero lines in the matrix. If the matrix line is all-zero, it is replaced by the matrix line
that would correspond to the input sequence itself (100%% probability of obtaining amino acid that is in the actual sequence). If the input psiblast
matrix file does not contain all-zero matrix lines, the output matrix will be the same as the input matrix.

Usage:

    %s [Parameters]
    
Parameters:

    <input-file> - input psiblast matrix file (.psi)
    <sequence-fasta> - input sequence file in fasta format. Note that the sequence has to be in one line (not text wrapped)
    <output-file> - output psiblast matrix file
""" % script_name

if len(sys.argv) != 4:
    sys.exit(usage_string)

################################ Functions ################################

def read_fasta(filename):
    f = open(filename)
    f.readline()
    n = 0
    while True:
        line = f.readline()
        if len(line) == 0:
            break
        my_seq = line.rstrip('\n')
        n += 1
    f.close()
    if n > 1:
        sys.exit("ERROR: fasta file contains more than 2 lines. Note that input sequence should not be text-wrapped. Fasta file should contain 1 line for fasta ID and one line for sequence. ")
    if n == 0:
        sys.exit("ERROR: fasta file contains only 1 line. Fasta file should contain 1 line for fasta ID and one line for sequence.")
    return my_seq

def check_psiblast_matrix(input_matrix_file, output_matrix_file, fasta_seq):
    
    f = open(input_matrix_file)
    
    line_begin = []
    line_end = []
    matrix = []
    validate_seq = ""
    file_begin = ""
    file_end = ""
    file_middle = ""
    n = 0
    while True:
        line = f.readline()
        if len(line) == 0: 
            break
        n += 1
        #line = line.rstrip('\n')
        bits = line.split()
        #print len(bits)
        if len(bits) == 44:
            line_begin = bits[:22]
            line_end = bits[42:]
            matrix = map(int,bits[22:42])
            validate_seq += bits[1]
            matrix_sum = sum(matrix)
            if matrix_sum == 0:
                matrix = create_new_matrix(bits[1])
                line = format_matrix_string(matrix, line_begin, line_end)
            file_middle += line
        elif n <= 3:
            file_begin += line
        else:
            file_end += line

    if fasta_seq != validate_seq:
        sys.exit("ERROR: Sequence from fasta file does not match sequence from psiblast matrix file. \n Fasta sequence: \n %s\n Psiblast matrix sequence: \n %s" % (fasta_seq, validate_seq) )
    
    #print "Sum:"
    #print matrix_sum
    
    out_str = file_begin + file_middle + file_end
    
    write_data(output_matrix_file, out_str)

    f.close()
    
def create_new_matrix(letter):
    amino_dict = {"A": 0, "R": 1, "N": 2, "D": 3, "C": 4, "Q": 5, "E": 6, "G": 7, "H": 8, "I": 9, "L": 10, "K": 11, "M": 12, "F": 13, "P": 14, "S": 15, "T": 16, "W": 17, "Y": 18, "V":19}
    new_matrix = []
    new_matrix = [0] * 20
    index = amino_dict[letter]
    new_matrix[index] = 100
    return new_matrix

def format_matrix_string(new_matrix, line_begin, line_end):
    matrix_string = ""
    matrix_string += "%5s%2s%5s " % (line_begin[0], line_begin[1], line_begin[2])
    for bit in line_begin[3:]:
        matrix_string += bit + " "
    for freq in new_matrix:
        matrix_string += "%4d" % freq
    matrix_string += " "
    for bit in line_end:
        matrix_string += bit + " "
    matrix_string += "\n"
    
    return matrix_string

def write_data(output_file, out_str):
    f = open(output_file,"w")  
    f.write(out_str)    
    f.close()


################################ Variables ################################

# Input files/directories
input_matrix_file = sys.argv[1]
input_seq_file = sys.argv[2]

# Output files/directories
output_matrix_file = sys.argv[3]

# Constants
# N/A

# Global variables
# N/A

################################ Main script ################################
    
sys.stderr.write("%s is running with arguments: %s\n" % (script_name, str(sys.argv[1:])))

my_seq = read_fasta(input_seq_file)

check_psiblast_matrix(input_matrix_file, output_matrix_file, my_seq)

sys.stderr.write("%s done.\n" % script_name)



