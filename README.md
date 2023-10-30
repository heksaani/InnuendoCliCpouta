
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
- Troubleshooting <br>

**Q1: Log files show that very large numebr of samples are submitted in nextflow job even though very few FASTQ files have been submitted**


 
**A1**: log files would have the following text: <br> 
```
 Input FastQ                 : 149289221 <br>
 Input samples               : 74644610 <br>
 Reports are found in        : ./reports <br>
 Results are found in        : ./results <br>
 Profile                     : incd <br>
 ....                         ...
```
Above error is resulting from not using quotes when giving path to input files. Make sure to use quotes ('') to fastq sample path as below:
 nextflow run pipeline_ecoli.nf --fastq '/mnt/rv_data/lyetukur/jobs/33/data/*_{1,2}.fastq.gz' ....

**Q2 chewBBACA: file not found: FileNotFoundError: [Errno 2] No such file or directory: '/mnt/singularity_cache2/shared_files/chewbbaca_test_bala/ecoli/test_schema_ecoli_download/ecoli_INNUENDO_wgMLST/temp/INNUENDO_wgMLST-00016261.fasta_result.txt'**

<br> **A2**: This is due to lack of file permissions to edit *.fasta* files in cheBBACA flat file database.

**Q3 Analysis of a tool (e.g., reads_serotypefinder) gets stuck and no apparent progress or error was found**

<br> **A3**:  More likely a database locking error inside of a container. Try to move the database out of container and use it from a mounted path.
