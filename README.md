
# Testing workflows on InnuendoCLI platform for different species.

## Launch workflows for ecoli species

Things to remember before launching pipeline

- Make sure that you have downloaded samples before lauching pipelines
- You have replaced your user name and samples as in samples files


Usage:

Clone Innuendo pipeline scripts in this Github to any folder on Innuendo2 machine on cPouta  

```bash

cd  /mnt/innuendo2_testing/demo_environment 
mkdir your-user-name

git clone https://github.com/yetulaxman/InnuendoCliCpouta.git  && cp InnuendoCliCpouta/* .

# edit input file (input_samples_ecoli.txt) and launch pipeline

nohup bash launch_pipeline_selectedsample.sh input_samples_ecoli.txt > test_ecoli &

# view the progress of jobs

contrl + c # (to get back to the temrinal
vi/vim test_ecoli

# You can also check the progress of pipeline by going to the job directory
cd /mnt/innuendo2_testing/jobs/your-user-name/runid/nextflow_log.txt 

# viewing reports file 

cd /mnt/innuendo2_testing/jobs/your-user-name/runid-of-your-samples/reports



