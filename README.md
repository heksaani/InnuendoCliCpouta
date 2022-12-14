
# Launching and testing workflows on InnuendoCLI platform for different species.

## Launch workflows for Ecoli species

Things to note before launching workflow:

- You have downloaded samples before lauching workflows
- You have edit the inpput files with correct username/pipeline name/samples


**Usage:**

Clone Innuendo pipeline scripts in this Github to any folder on Innuendo2 machine on cPouta  

```bash
# Let's run all these tests in some folder 
cd  /mnt/innuendo2_testing/demo_environment 

# use your actual name to create a directory (this needs to be done only once)
mkdir your-user-name  && cd your-user-name 

# clone scripts from GitHub if you don't have them already
git clone https://github.com/yetulaxman/InnuendoCliCpouta.git  && cp InnuendoCliCpouta/* .

# edit input file (input_samples_ecoli.txt) and launch pipeline
nohup bash launch_pipeline_selectedsample.sh input_samples_ecoli.txt > test_ecoli &

# view the progress of jobs

contrl + c # to get back to the temrinal
vi/vim/nano test_ecoli  # use your favourite edditor to see if job has started

# You can also check the real progress of batch jobs by going in directory where job is running
# runid : you can find it in your input file
# pipeline: you can find it in the input file

cd /mnt/innuendo2_testing/jobs/your-user-name/pipeline-runid 
vi/vim/nano nextflow_log.txt
# viewing reports file 
cd reports



