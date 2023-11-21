
# Testing InnuendoCLI platform for e-coli species

## List of things to test in this InnuendoCLI platform 
- **Logging into the innuendo2 machine**:
  Please check that you can login to Innuendo2 machine using SSH key authentication. All those who have shared your public SSH key with us should be able to login to Innuendo machine. In Linux/ macOS, one can use the following command to login:
  ```bash
   ssh -i ~/.ssh/your_private_ssh_key.pem  your_user_name@195.148.22.5
  ```
  You can also find more detailed instructions on [our CSC documentation](https://docs.csc.fi/computing/connecting/)
- **Data folders on Inneundo2 machine**:
  We have a dedicated stiorage area for each institute under the folder "/mnt". Please create a storage folder (e.g., ftp) for your data under your own username as below:

   ```bash
   # THL users
   mkdir -p /mnt/rv_data/$USER/ftp 
   # RV users
   mkdir -p /mnt/THL_data/$USER/ftp
  ```
  And also you might want to create a subfolder (e.g., /mnt/rv_data/$USER/ftp/ecoli_data)  for a set of smaples that you would like to run together.

  Please create a folder for jobs under your username:

   ``` bash
   # THL users
   mkdir -p /mnt/rv_data/$USER/jobs
   # RV users
   mkdir -p /mnt/THL_data/$USER/jobs
    ```
  All jobs that you have submitted will be created under *jobs* folder.

- **Running workflows**:
   - Please make sure that you have done the following preparation before launching workflows:
     - You have downloaded samples to a dedicated directory (/mnt/rv_data/$USER/data or /mnt/thl/$USER/data ) on Innuendo machine
     - You have edited input template file for worklfows 

  **Usage:**

  ```bash

   # Syntax:
   > nohup bash icli-run -p  -r -f md_example_1.csv > test &

   # Syntax:
   # icli-run -p -m -r -f metadata.csv
   #
   # Options:
   # -p    Pipeline. Run the pipeline
   # -d    Duplicate. Run even if sample exists
   # -m    Metadata. Write metadata to DB
   # -r    Reports. Write analysis results and reports to DB
   # -f    Metadata file
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


 - Specific tools
 - Database
 - Reports
 - **Visualisation**:
Grapetree (version 2.2.0) is installed on Innuendo2 machine and can be used for the visualization of allelic profiles.  You can type the following command to start grapetree: 

```bash
grapetree
```
Once the software is started one can access it from here: http://195.148.22.5:5000/

 - **Troubleshooting**: <br>

 **Q1: Information in log files indicate that the large numebr of samples are submitted as part of  nextflow job despite fewer samples have infact been submitted**
 <br>**A1**: log files would have the following text: <br> 
 ```
 ....
  Input FastQ                 : 149289221 
  Input samples               : 74644610 
  Reports are found in        : ./reports 
  Results are found in        : ./results 
  Profile                     : incd 
  ....                         ...
 ```
 Above error is as a consequnce of not using quotes when giving path to input files. Make sure to use quotes ('') to fastq sample path as below:
  nextflow run pipeline_ecoli.nf --fastq '/mnt/rv_data/lyetukur/jobs/33/data/*_{1,2}.fastq.gz' ....


 **Q2: ChewBBACA: file not found: FileNotFoundError: [Errno 2] No such file or directory: '/mnt/singularity_cache2/shared_files/chewbbaca_test_bala/ecoli/test_schema_ecoli_download/ecoli_INNUENDO_wgMLST/temp/INNUENDO_wgMLST-  00016261.fasta_result.txt'**
 <br> **A2**: This is due to lack of file permissions to edit *.fasta* files in cheBBACA flat file database.

 **Q3: Analysis of a tool (e.g., reads_serotypefinder) gets stuck and no apparent progress or error was found**
<br> **A3**:  More likely a database locking error inside of a container. Try to move the database out of container and use it from a mounted path.

 **Q4: How do you stop a running nextflow job on slurm cluster**
<br> **A4**: As nextflow job that is running on cluster has several job steps, just cancelling a job step (scancel <job_id>) won't stop the whole nextflow job. One easiest way stop the job is to find the master nextflow process ID (PID) uisng  the following command:

 ```
 cd /path/nextflow/submission/directory/   # move to the directory from where you have submitted job
 lsof .nextflow/cache/**/db/LOCK    # under cache directory ther should be folder name with hash number
 ```
 Above command should print  PID  of a running nextflow job among other column fields. Identiy the PID and kill the job as below:
 ```
 kill <pid>
 ```

