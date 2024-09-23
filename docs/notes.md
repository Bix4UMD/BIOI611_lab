


SRR15675112	Neuron_D8_rep1
SRR15675111	Neuron_D8_rep2
SRR15675110	Neuron_D8_rep3
SRR15675135	Neuron D1 rep1
SRR15675134	Neuron D1 rep2
SRR15675123	Neuron D1 rep3




```
find . -type d  -or -type f -exec touch {} + 
```


```
perl -ne 'chomp;($SRR, $name) = split("\t");$R1 = "$SRR"."_1.fastq.gz"; $R2 = "$SRR"."_2.fastq.gz"; print "#$SRR\t$
name\nmv $R1 $name"."_1.fastq.gz\nmv $R2 $name"."_2.fastq.gz\n"' test.txt
```



