
# Testing InnuendoCLI platform for e-coli species


## Launch workflows for Ecoli species

Please make sure that you have done the following preparation before launching workflows:

- You have downloaded samples to a dedicated directory (/mnt/rv_data/$USER/data or /mnt/thl/$USER/data ) on Innuendo machine
- You have edited input template file for worklfows 

**Usage:**

```bash

# Syntax:
> icli-run -r -m -f metadata.csv
Options:
 -r    Run the pipeline
 -m    Write metadata to DB
 -f    Metadata file

# To both write the metadata and run the pipeline 
# specify both -r and -m

# view the progress of jobs

contrl + c  # to get back to the linux terminal
vi/vim/nano test_ecoli  # use your favourite editor to see if job has started

# You can also check the real progress of batch jobs by going into directory where job is running
# you need to know runid (you can find it in your input template file)  specific to your run.

cd /mnt/rv_data/jobs/your-user-name/runid  or cd /mnt/thl/jobs/your-user-name/runid 
vi/vim/nano nextflow_log.txt

# view reports file 
cd reports
```

## Things to test in this workflows
Mention feedback in different stages of pipeline
- Moving data to Inneundo machine
- Running workflows
- Specific tools
- Database
- Reports
- Visualisation
