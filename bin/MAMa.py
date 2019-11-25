#!/usr/bin/python
# -*- coding: utf-8 -*-
# v0.1.0
#########################################################################################
# Constrcut abundance matrix from a list of bam files 								    #
#########################################################################################
#                                                                                       #
# This program is free software: you can redistribute it and/or modify it under the     #
# terms of the GNU General Public License as published by the Free Software Foundation, #
# either version 3 of the License, or (at your option) any later version.               #
#                                                                                       #
#########################################################################################
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, ##
## INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A       ##
## PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT  ##
## HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION   ##
## OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      ##
## SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                              ##
#########################################################################################

_author__ = 'Corentin Hochart'
__email__ = 'corentin.hochart@uca.fr'
__credits__ = ["Corentin Hochart"]
__license__ = 'GPL3'
__maintainer__ = 'Corentin Hochart'
__status__ = 'Development'


import sys
import os
import argparse
import collections
import gzip
import logging
import traceback

dir_module = '/data/chochart/lib/'

if dir_module not in sys.path:
    sys.path.insert(0, dir_module)

from MAMa import version
from biolib.logger import logger_setup
from biolib.common import (remove_extension)

# Functions 
def find_ex(program):
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath = os.path.split(program)[0]
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None

def matrix_maker(faidx, bam_list, extension, threads,
                    abundance_file, normalised_file, relative_file,
                    base_abundance_file, base_normalised_file, base_relative_file,
                    feature_normalisation, discard_gene_length_normalisation, removed
                            ):

    import subprocess
    import re 

    logger = logging.getLogger('timestamp')
    features_size = {}
    counts = {}
    counts_base = {}

    logger.info('Get features and initialise matrix')
    with open(faidx) as f:
        for line in f:
            if not line.startswith('#') :
                LINE = line.rstrip().split('\t')
                features = LINE[0]
                features_size[features] = LINE[1]
                counts[features] = 0 
                counts_base[features] = 0 

    counts_all = []
    counts_all_normalised = []
    counts_all_relative = []
    counts_base_all = []
    counts_base_all_normalised = []
    counts_base_all_relative = []

    file = ["Features","Features_size"]
    logger.info('Browse alignement file(s)')

    samtoolsexec=find_ex('samtools')
    samtoolsthreads='-@ ' + threads

    with open(bam_list,'r') as b :
        for bam in b :
            if bam.startswith('#') :
                continue
            i = 0
            alignementfile,librarysize = bam.split(',')
            if librarysize == '' or librarysize == 0 :
                librarysize = 1 
            samplename = remove_extension(os.path.basename(alignementfile),extension)
            file.append(samplename)
            logger.info('\t'+samplename)
            cmd = [ samtoolsexec,'view',samtoolsthreads,alignementfile ]
            p = subprocess.Popen(cmd, stdout=subprocess.PIPE).stdout
            for line in p:
                line=line.decode(sys.getdefaultencoding()).rstrip()
                if i > 0 and i % 100000 == 0 :
                    logger.info("Alignment record %s processed" % i )
                i += 1
                LINE = line.split('\t')
                features = LINE[2]
                cigar = LINE[5]
                counts[features] += 1
                base_mapped = 0 
                match = re.findall(r'(\d+)M',cigar)
                for base_match in match :
                    base_mapped += int(base_match)
                if discard_gene_length_normalisation :
                    counts_base[features] += base_mapped
                else :
                    counts_base[features] += base_mapped / int(features_size[features])

            if abundance_file :
                counts_all.append(counts.copy())
        
            if normalised_file :
                count_tmp = {}
                count_tmp = {k: (v / int(librarysize))*feature_normalisation for k, v in counts.items()} 
                counts_all_normalised.append(count_tmp.copy())

            if relative_file :
                count_tmp = {}
                count_tmp = {k: v / total for total in (sum(counts.values()),) for k, v in counts.items()}
                counts_all_relative.append(count_tmp.copy())

            if base_abundance_file :
                counts_base_all.append(counts_base.copy())

            if base_normalised_file :
                count_tmp = {}
                count_tmp = {k: (v / int(librarysize))*feature_normalisation for k, v in counts_base.items()} 
                counts_base_all_normalised.append(count_tmp.copy())

            if base_relative_file :
                count_tmp = {}
                count_tmp = {k: v / total for total in (sum(counts_base.values()),) for k, v in counts_base.items()} 
                counts_base_all_relative.append(count_tmp.copy())

            for fn in counts:
                counts[fn] = 0
                counts_base[fn] = 0

    logger.info('Print matrix')

    if abundance_file :
        output_handle = open(abundance_file, "w")
        output_handle.write('\t'.join(file)+'\n')
        for fn in counts.keys():
            if sum([c[fn] for c in counts_all]) == 0 and removed :
                continue
            else :
                output_handle.write('\t'.join([fn] + [features_size[fn]] + [str(c[fn]) for c in counts_all])+'\n') 
        output_handle.close()

    if normalised_file :
        output_handle = open(normalised_file, "w")
        output_handle.write('\t'.join(file)+'\n')
        for fn in counts.keys():
            if sum([c[fn] for c in counts_all_normalised]) == 0 and removed :
                continue
            else :
                output_handle.write('\t'.join([fn] + [features_size[fn]] + [str(c[fn]) for c in counts_all_normalised])+'\n') 
        output_handle.close()

    if relative_file :
        output_handle = open(relative_file, "w")
        output_handle.write('\t'.join(file)+'\n')
        for fn in counts.keys():
            if sum([c[fn] for c in counts_all_relative]) == 0 and removed :
                continue
            else :
                output_handle.write('\t'.join([fn] + [features_size[fn]] + [str(c[fn]) for c in counts_all_relative])+'\n')
        output_handle.close()

    if base_abundance_file :
        output_handle = open(base_abundance_file, "w")
        output_handle.write('\t'.join(file)+'\n')
        for fn in counts_base.keys():
            if sum([c[fn] for c in counts_all]) == 0 and removed :
                continue
            else :
                output_handle.write('\t'.join([fn] + [features_size[fn]] + [str(c[fn]) for c in counts_base_all])+'\n') 
        output_handle.close()

    if base_normalised_file :
        output_handle = open(base_normalised_file, "w")
        output_handle.write('\t'.join(file)+'\n')
        for fn in counts_base.keys():
            if sum([c[fn] for c in counts_all_normalised]) == 0 and removed :
                continue
            else :
                output_handle.write('\t'.join([fn] + [features_size[fn]] + [str(c[fn]) for c in counts_base_all_normalised])+'\n') 
        output_handle.close()

    if base_relative_file :
        output_handle = open(base_relative_file, "w")
        output_handle.write('\t'.join(file)+'\n')
        for fn in counts_base.keys():
            if sum([c[fn] for c in counts_all_relative]) == 0 and removed :
                continue
            else :
                output_handle.write('\t'.join([fn] + [features_size[fn]] + [str(c[fn]) for c in counts_base_all_relative])+'\n')
        output_handle.close()

def main():

    parser = argparse.ArgumentParser(
        description="This script allow the construction of abundance" +
        "matrix from a list of bam file.",
        epilog="Written by Corentin Hochart (corentin.hochart@uca.fr), " +
        "UMR CNRSS 6023 Laboratoire Genome et Environement (LMGE). " +
        "Released under the terms of the GNU General Public License v3. " +
        "MAMa version %s." % version())

    parser.add_argument('faidx',help='samtools fasta index of the reference')
    parser.add_argument('bam_list',help='list of bam format alignement file(s) path ') 
    
    input_argument = parser.add_argument_group('optional input arguments')
    input_argument.add_argument('-x','--extension', help='bam file prefix',default='bam')
    input_argument.add_argument('-t','--threads', help='threads number for "samtools view"',default='2')

    output_argument = parser.add_argument_group('optional output arguments')
    output_argument.add_argument('-a','--abundance', help="reads count abundance output")
    output_argument.add_argument('-n','--normalised', help="reads count normalised abundance output (feature per X reads ; see '-f' argument)")
    output_argument.add_argument('-r','--relative', help="reads count relative abundance output")
    output_argument.add_argument('--base_abundance', help="base count abundance output")
    output_argument.add_argument('--base_normalised', help="base count normalised abundance output (feature per X reads ; see '-f' argument)")
    output_argument.add_argument('--base_relative', help="base count relative abundance output")
    output_argument.add_argument('-f','--feature_normalisation',help="get the numer of features per X reads [Default: 1000000]",default=1000000,type=int)
    output_argument.add_argument('-g','--discard_gene_length_normalisation',help="discard gene length normalisation for base count abundance output",action='store_true')
    output_argument.add_argument('--removed',help="removed features who do not appears in samples (sum of abundance through sample = 0)",action='store_true')

    parser.add_argument('--silent', help='suppress output of logger', action='store_true')
    parser.add_argument('--version',help='print version and exit',action='version',version='MAMa '+ version())
    
    args = parser.parse_args()

    try:
        logger_setup('log', "MAMa.log", "MAMa", version(), args.silent)
    except:
        logger_setup(None, "MAMa.log", "MAMa", version(), args.silent)
    
    if not args.abundance and not args.normalised and not args.relative  :
        parser.error('''At least one output file name must be specified with '--relative' and/or '--normalised' and/or '--abundance'.''')

    matrix_maker(args.faidx, args.bam_list, args.extension, args.threads,
                    args.abundance, args.normalised, args.relative,
                    args.base_abundance, args.base_normalised, args.base_relative,
                    args.feature_normalisation, args.discard_gene_length_normalisation, args.removed
    )


if __name__ == "__main__":
    main()
