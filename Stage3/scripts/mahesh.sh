mkdir Mahesh_Kamilus
mkdir biocomputing
cd biocomputing/
wget -c https://raw.githubusercontent.com/josoga2/dataset-repos/main/wildtype.fna
wget -c https://raw.githubusercontent.com/josoga2/dataset-repos/main/wildtype.gbk
wget -c https://raw.githubusercontent.com/josoga2/dataset-repos/main/wildtype.gbk
mv wildtype.fna ../Mahesh_Kamilus/
rm wildtype.gbk
grep tatatata wildtype.fna 
grep tatatata wildtype.fna |tee mutant.fa
curl "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=NM_000594&db=nuccore&report=fasta&retmode=text" -o TNF_gene.fasta
grep -v "^>" TNF_gene.fasta | wc -l
grep -v "^>" TNF_gene.fasta | grep -o "A" | wc -l
grep -v "^>" TNF_gene.fasta | grep -o "G" | wc -l
grep -v "^>" TNF_gene.fasta | grep -o "C" | wc -l
grep -v "^>" TNF_gene.fasta | grep -o "T" | wc -l

A_count=$(grep -v "^>" TNF_gene.fasta | grep -o "A" | wc -l)
G_count=$(grep -v "^>" TNF_gene.fasta | grep -o "G" | wc -l)
C_count=$(grep -v "^>" TNF_gene.fasta | grep -o "C" | wc -l)
T_count=$(grep -v "^>" TNF_gene.fasta | grep -o "T" | wc -l)
Total_count=$((A_count+T_count+G_count+C_count))
GC_content=$(echo(($G_count+$C_count)*100)/$Total_count)

cat >Mahesh.fasta

cat Mahesh.fasta

A_count=$(grep -v "^>" Mahesh.fasta | grep -o "A" | wc -l)
G_count=$(grep -v "^>" Mahesh.fasta | grep -o "G" | wc -l)
C_count=$(grep -v "^>" Mahesh.fasta | grep -o "C" | wc -l)
T_count=$(grep -v "^>" Mahesh.fasta | grep -o "T" | wc -l)

cat Mahesh.fasta
