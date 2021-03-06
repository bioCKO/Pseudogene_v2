#!/bin/bash

## bash analysis_v6.sh DIR COVERAGE READLEN ABUNDANCE
## ex bash analysis_v6.sh select_one_pseudogene_110 1 100 10

DIR=$1
SUBDIR=$2
READLEN=$3
MAPPING="mapping"
TOPOUT="tophat_out"
BAM="accepted_hits.bam"


## MAC
#ENST_ENSG_ENSP="/Users/Chelsea/Bioinformatics/CJDatabase/Ensembl/ENST_ENSG_ENSP_74.txt"
#ENST2ENSG="/Users/Chelsea/Bioinformatics/CJDatabase/Ensembl/script/ENST2ENSG.py"

## HOFFMAN
ENST_ENSG_ENSP="/u/home/c/chelseaj/project/database/Ensembl/ENST_ENSG_ENSP_79.txt"
ENST2ENSG="/u/home/c/chelseaj/project/database/Ensembl/script/ENST2ENSG.py"

## LAB
#ENST_ENSG_ENSP="/home/chelseaju/Database/Ensembl/ENST_ENSG_ENSP_74.txt"
#ENST2ENSG="/home/chelseaju/Database/Ensembl/script/ENST2ENSG.py"

echo "Data Analysis Version 1:"

echo ""
echo "Step 1 - Creating Folder"
mkdir -p $DIR/$SUBDIR/$MAPPING

echo ""
echo "Step 2 - Sort BAMFILE by name, convert BAM to bed"
samtools sort -n $DIR/$SUBDIR/$TOPOUT/$BAM $DIR/$SUBDIR/$MAPPING/accepted_hits_sortedByName
bedtools bamtobed -i $DIR/$SUBDIR/$TOPOUT/$BAM > $DIR/$SUBDIR/$MAPPING/accepted_hits.bed

echo ""
echo "Step 3 - Expected Count (Gene Level)"
python expected_counter_v3.py -d $DIR/$SUBDIR/$MAPPING
python $ENST2ENSG -i $DIR/$SUBDIR/$MAPPING/transcripts_expected_read_count.txt -o $DIR/$SUBDIR/$MAPPING/genes_expected_read_count.txt -d $ENST_ENSG_ENSP

# merge the same ENSG
cp $DIR/$SUBDIR/$MAPPING/genes_expected_read_count.txt $DIR/$SUBDIR/$MAPPING/genes_expected_read_count.backup
awk '{A[$1]+=$2; next} END{for (i in A) {print i"\t"A[i]}}' $DIR/$SUBDIR/$MAPPING/genes_expected_read_count.backup > $DIR/$SUBDIR/$MAPPING/genes_expected_read_count.txt

echo ""
echo "Step 4 - Observed Count (Gene Level)"
python local_genes_mapper_v1.py -d $DIR/$SUBDIR/$MAPPING -r $DIR/$MAPPING/genes_distribution.name

echo ""
echo "Step 5 - Format Distribution Equation"
python distribution_equation_v2.py -d $DIR/$SUBDIR/$MAPPING

echo ""
echo "Step 6 - Convert Distribution Equation to a Full Matrix"
python distribution_matrix_v1.py -d $DIR/$SUBDIR/$MAPPING -r $DIR/$MAPPING/genes_distribution.name


echo ""
echo "Step 7 - Convert Expected Count to Sparse Notation"
python convert_expected_counter_v1.py -d $DIR/$SUBDIR/$MAPPING -r $DIR/$MAPPING/genes_distribution.name


echo ""
echo "Step 8 - Remove redundant files"
rm $DIR/$SUBDIR/$MAPPING/genes_expected_read_count.backup
rm $DIR/$SUBDIR/$MAPPING/accepted_hits_sortedByName.bam
rm $DIR/$SUBDIR/$MAPPING/accepted_hits.bed

echo ""
echo "COMPLETE"
