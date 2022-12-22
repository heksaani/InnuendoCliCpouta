# usage: nohup bash launch_pipeline_selectedsample.sh input_samples_campy.txt > test_campy &

#!/bin/bash

# clean: blank spaces to have tab delimited 
sed 's/[[:blank:]]\+/\t/g' "$1" > "$1"_clean
sed -i "s/\r//g" "$1"_clean

infile="$1"_clean
TAB=$(printf "\t")
while IFS=$TAB read pipelines       sample_ids      runids  users   input_files
do
  echo "$pipelines, $users, $input_files"
  # trim any white space
  user=`echo $users` 
  runid=`echo $runids`
  Input_file=`echo $input_files`
  pipeline=`echo $pipelines`
  Input_path="/mnt/innuendo2_testing/rawdata/${user}/incoming"
  echo "incoming data: ${Input_path}/$Input_file"
if [[ $(ls -1 ${Input_path}/$Input_file | wc -l ) -gt 0 ]] 2> /dev/null  && [ $user != "users" ]
then    
       echo "in raw file : ${Input_path}"	
	echo "inuput file $Input_file"
	mkdir -p /mnt/innuendo2_testing/jobs/$user
	mkdir -p /mnt/innuendo2_testing/jobs/$user/$runid
        job_dir="/mnt/innuendo2_testing/jobs/$user/$runid"
	mkdir -p $job_dir/data
	echo "raw file : ${Input_path}/$Input_file"
	echo "target file: $job_dir/data/$Input_file"
	ln -s ${Input_path}/$Input_file  $job_dir/data/$Input_file

elif [ $user == "users" ] ; then
        echo "skipping header"
else 
	echo "No recognised input files found in the folder:${Input_path}"
   
fi

done < <(grep "" $infile)



# check if the input file is meant for running only one pipeline; assumes first column has pipeline info
if [[ $(tail -n +2 $infile  | sort -u -t$'\t'  -k1,1 |  awk '{print $1}' |  wc -w ) -gt 1 ]] 2> /dev/null
then
        echo "metadata file has input for more than one pipeline; please  use a metadatfile per pipeline"
	exit 1

else
        echo "unique pipeline mentioned"
fi


if [[ $(ls -1 /mnt/innuendo2_testing/jobs/$user/$runid/data/*_1_*.fastq.gz | wc -l ) -gt 0 ]] 2> /dev/null 
then
	echo "Fastq file(s) found with pattern *_1_*.fastq.gz"
	Nextflow_input="/mnt/innuendo2_testing/jobs/$user/$runid/data/*_{1,2}_*.fastq.gz"

elif [[ $(ls -1 /mnt/innuendo2_testing/jobs/$user/$runid/data/*_1.fastq.gz | wc -l ) -gt 0 ]] 2> /dev/null 
then
	echo "Fastq file(s) found with pattern *_1.fastq.gz"
	Nextflow_input="/mnt/innuendo2_testing/jobs/$user/$runid/data/*_{1,2}.fastq.gz"
elif [[ $(ls -1 /mnt/innuendo2_testing/jobs/$user/$runid/data/*_R1.fastq.gz | wc -l ) -gt 0 ]] 2> /dev/null
then
	echo "Fastq file(s) found with pattern *_R1.fastq.gz"
	Nextflow_input="/mnt/innuendo2_testing/jobs/$user/$runid/data/*_{R1,R2}.fastq.gz"
elif [[ $(ls -1 /mnt/innuendo2_testing/jobs/$user/$runid/data/*_R1_*.fastq.gz | wc -l ) -gt 0 ]] 2> /dev/null
then
	echo "Fastq file(s) found with pattern *_R1_*.fastq.gz"
	Nextflow_input="/mnt/innuendo2_testing/jobs/$user/$runid/data/*_{R1,R2}_*.fastq.gz"

else
	echo "No recognised input files found"
fi


echo "Data folder is lcoated here: $Nextflow_input"

# Build pipeline

job_dir_final="/mnt/innuendo2_testing/jobs/$user/$runid"

cd $job_dir_final

echo "building pipeline in directory:$job_dir_final"

echo $pipeline
bash /mnt/singularity_cache2/pipelines/$pipeline.sh

cp /mnt/singularity_cache2/pipelines/$pipeline/* .

# Run pipeline

if [ $pipeline == "ecoli" ] ; then
  echo "Running ecoli pipeline"
  nextflow run pipeline_ecoli.nf --fastq $Nextflow_input -profile incd --mlstSpecies_12 ecoli  --species_5  "Escherichia coli"     --species_19  "Escherichia coli"  --species_18  "Escherichia coli"  --species_29  "Escherichia coli" --species_27  "Escherichia coli"  -resume -bg 2>&1 >  nextflow_log.txt

elif [ $pipeline == "cjejuni" ] ; then
    echo "Running campy pipeline"
    nextflow run pipeline_cmpy.nf --fastq $Nextflow_input  -profile incd --mlstSpecies_12 campylobacter --species_5 'Campylobacter jejuni' --species_29 'Campylobacter jejuni' --species_27 'Campylobacter jejuni' -resume -bg 2>&1 >  nextflow_log.txt

elif [ $pipeline == "senterica" ] ; then
    echo "Running Salmonella pipeline"
    nextflow run pipeline_salmonella.nf --fastq $Nextflow_input  -profile incd --mlstSpecies_12 senterica  --species_5   "Salmonella enterica"   --species_27  "Salmonella enterica"  --species_29  "Salmonella enterica"   -resume  -bg 2>&1 >  nextflow_log.txt

elif [ $pipeline == "yenterocolitica" ] ; then
    echo "Running yersinia pipeline"
    nextflow run pipeline_yersinia.nf --fastq $Nextflow_input  -profile incd --mlstSpecies_12 yersinia --species_5 'Yersinia enterocolitica' --species_18 'Yersinia enterocolitica' --species_27 'Yersinia enterocolitica' --species_29 'Yersinia enterocolitica' -resume -bg 2>&1 >  nextflow_log.txt

elif [ $pipeline == "lmonocytogenes" ] ; then
    echo "Running Listeria pipeline"
    nextflow run pipeline_listeria.nf --fastq $Nextflow_input  --referenceFile_35 '/mnt/singularity_cache2/serogrouping/Listeria_mono.fasta' -profile incd --mlstSpecies_12 lmonocytogenes   --species_5  "Listeria monocytogenes"  --species_27  "Listeria monocytogenes"  --species_29  "Listeria monocytogenes"   -resume  -bg 2>&1 >  nextflow_log.txt

else
        echo "No pipeline is detected"
fi



#  Wait for the pipeline to be finished

sleep 10

echo "Nextflow pipeline is running"
pid=$(lsof -Fp  $job_dir_final/.nextflow/cache/*/db/LOCK | sed 's/^p//' | head -n 1)
while kill -0 "$pid" >/dev/null 2>&1; do
sleep 60
done

echo "process finished"


# Build reports (This one currently works when workflow job  is successfully run).

mkdir results/md5_sha256
# compute md5/sha256 values; change paths
for file in $job_dir_final/*.gz; do sha256sum $file; done > $job_dir_final/results/md5_sha256/sha256sum.txt
for file in $job_dir_final/*.gz; do md5sum $file; done > $job_dir_final/results/md5_sha256/md5sum.txt

# Reports
bash generate_reports.sh
~

