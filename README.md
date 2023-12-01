
# InnuendoCLI platform for Escherichia coli species

## List of things to test in InnuendoCLI platform:

- ### **Logging into InnuendoCLI machine**
  Please make sure that you can login to InnuendoCLI machine using your SSH key authentication. All those who shared their respective public SSH key with CSC should be able to login to InnuendoCLI machine. In Linux/ macOS, one can use the following command to login:
  ```bash
   ssh -i ~/.ssh/your_private_ssh_key.pem  your_user_name@Innuendomachine_ip
  ```
  The **Innuendomachine_ip** in the above command is sent separately by e-mail. Upon successful login, you will end up in your own home folder on InnuendoCLI machine.
- ###  **Understanding your own data folders on InnuendoCLI machine**
  We have a dedicated storage area for each institute under the folder "/mnt". Please create a folder (e.g., ftp) for storing your data under your own username as below:

   ```bash
   # RV users
   mkdir -p /mnt/rv_data/$USER/ftp 
   # THL users
   mkdir -p /mnt/thl_data/$USER/ftp
  ```
   And it is also a good idea to create a subfolder (e.g., /mnt/rv_data/$USER/ftp/ecoli_data)  for a set of samples that you would like to analyse together.
   Please note that you have to place corresponding metadata file in the same directory as your raw data and launch your pipeline from the same directory.

   Create a folder for jobs where the analysed data resulting from submitted batch jobs can be stored.

    ``` bash
    # THL users
    mkdir -p /mnt/rv_data/$USER/jobs
    # RV users
    mkdir -p /mnt/thl_data/$USER/jobs
    ```

    All batch jobs that you submit via **icli-run** command will be run and stored under your own jobs folder.

   **Note**: Each user has a home folder (/home/user_name) and one can keep light-weights scripts there. However, the home folder space is very limited and 
    requires frequent self-cleaning.  One should not download any big data files to home folders.

 - ### **Transfering data to InnuendoCLI machine**
   You can use your own favourite file transfer protocol to transfer data from your local place to InnnuendoCLI machine.  You can consult our CSC
   documentation on [Graphical file transfer tools](https://docs.csc.fi/data/moving/graphical_transfer/) such as FileZilla and WinSCP.
   You can of course transfer your data with your favourite command-line tool for data transfer. For example, you can use scp or rsync tool on your
   macOS/Linux as below:

    ```bash
    # The basic syntax for copying data from a local machine to a Innuendo machine
    scp  -i ~/.ssh/private_key.pem  /path/to/file/on local machine  user_name@Innuendomachine_ip:"/path/to/destination/folder on Innuendo machine"
    rsync -rP -i ~/.ssh/private_key.pem  /path/to/local/folder on local mahcine  user_name@Innuendomachine_ip:"/path/to/destination/folder on Innuendo machine"
    # The basic  syntax to copy files from Innuendo machine to a local machine
    scp  -i ~/.ssh/private_key.pem  user_name@Innuendomachine_ip:"/path/of the/file/on Innuendo machine"  
    rsync -rP -i ~/.ssh/private_key.pem  user_name@Innuendomachine_ip:"/path/to/the/folder on Innuendo machine"
    ```
   In addition, ALLAS tools are installed on Innuendo2 machine to copy files  between Innuendo2 machine and ALLAS object storage. Allas tools require a CSC user account and the detailed usage instructions can be found on [CSC documentation](https://docs.csc.fi/data/Allas/accessing_allas/).

   Activate allas tools on Innuendo machine as below:
   ```
   export PATH=${PATH}:/home/ubuntu/allas-cli-utils
   source /home/ubuntu/allas-cli-utils/allas_conf -u CSC_username
   a-put filename -b innuendo2  # innuendo2 bucket is created on allas under our project
   ```
- ### **Launching workflows**
  Please make sure that you have done the following preparation before launching workflows:
    - You have uploaded your samples to a dedicated directory (under /mnt/rv_data/use_name/ftp or /mnt/thl_data/user_name/ftp ) on InnuendoCLI machine. It is a good idea to create a subfolder (e.g., /mnt/rv_data/use_name/ftp/ecoli_samples for e-coli samples) corresponding to a batch of samples that you would like to analyse together.
    - You have created a input metadata file for nextflow job and placed it in the same folder where you have raw data. Pay attention to different fields of matadata input file. One example file (metadata_example.csv) is created in this GitHub folder. You can check metadata_screenshot.png file for more clarity. Please read files inside of the folder "MetadataVocab" in this GitHub to understand more about
different metadata fields and restrictons.

   Finally, you can launch your pipeline after navigating to the folder where you have metadata file and raw data are stored.

   **Usage:**

   ```bash
   # Syntax for running automated worklfow in the background.
   # After issueing the following command, use  **contrl + c**  to get back to linux terminal.
   nohup bash icli-run -p -m  -r -f metadata_example.csv > log.txt &
   # you can monitor the resulting output in the file, log.txt ( use less/more/tail log.txt) to check
   # if the job has successfully been started.
   # You can also view file metadata_screenshot.png to get some idea about metadata file
  
   # Syntax for interactive  usage 
   icli-run -p -m  -r -f metadata_example.csv
   
   # Options:
   # -p    Pipeline. Run the pipeline
   # -d    Duplicate. Run even if sample exists
   # -m    Metadata. Write metadata to DB
   # -r    Reports. Write analysis results and reports to DB
   # -f    Metadata file

   # You can monitor the progress of batch job by going into directory where job is running
   # your job name is your metadata file name without .csv extension

   cd /mnt/rv_data/jobs/your-user-name/job_folder or cd /mnt/thl_data/jobs/your-user-name/job_folder
   cat/less/head/tail nextflow_log.txt
   
   # You can check the status of running jobs
   squeue -l -u user_name

   # view reports file 
   cd reports
   # Check the folder with important files for saving. this folder is created once job is successfully finished.
   cd Final_results
   ```

 - ### **Examining your reports**
    Reports are generated once your submitted job is successfully run. Under your own job directory (/mnt/thl_data/$USER/jobs/ or /mnt/rv_data/$USER/jobs),
    you can see the actual analysis results split into **results** and **reports** folders. The reports folder also contains the following summery files:
   - Innuendo_reports.xlsx
   - combine_samples_reports.tab
   - Samples_reports.tab
   - AMR_reports.tab
   - log_reports.tab
   - typing_reports.tab

   Please note that the excel file, Innuendo_reports.xlsx comprises all reports, each one in a separate excel sheet.

 - ### **Visualising ChewBBACA allelic profiles using Grapetree**
   Grapetree software (version 2.2.0) is installed on InnuendoCLI machine and can be used for the visualization of allelic profiles.  You can use the
   following command to on linux terminal to launch GrapeTree: 

    ```bash
    grapetree
    ```
    Once the software is launched, you can access it from your web browser using the following URL: http://floating_ip:5000/. The floating_ip is shared 
    seperately in e-mail.

    As metadata need to be compiled for the in-house generated allelic profiles, one can only visualise the  
    raw samples for now. A search tool is created for finding nearest neighbours and fetching the corresponding allelec profiles of the neighbouring samples.     You have to create a query file with a sample allelic  profile (check example file:indexquery in this GitHub) and the search the nearest neighbours of
    the sample as below:

    ```bash
    index_profiles indexquery
    ```
    Above command will produce a file (file name: "indexquery_nearest_profiles.tsv") with nearest neighbours along with their allelic profiles. This can be
    used to generate tree visualisations with GrapeTree software.
   
- ### **Known issues or warning messages**
  
 1. In the nextflow_log.txt under jobs directory, you may see the following slurm warning message but it will not affect the execution process. So please ignore it.
    
 ```bash 
  WARN: [SLURM] queue (test) status cannot be fetched
   - cmd executed: squeue --noheader -o %i %t -t all -p test -u lyetukur
   - exit status : 1
   - output      :
   ...

 ```
- ### **Troubleshooting Guide**: <br>

  **Q1: Information in log files indicate that the large number of samples are submitted as part of  nextflow job despite fewer samples have infact been submitted**
  <br>
    **A1**:  log files would have the following text: <br> 
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

   **Please note** that this isssue is only when one tries to run nextflow pipeline manually. When pipelines are launched with *icli-run*, you will **NOT**
   come across this issue.


  **Q2: ChewBBACA: file not found: FileNotFoundError: [Errno 2] No such file or directory: '/mnt/singularity_cache2/shared_files/chewbbaca_test_bala/ecoli
   /test_schema_ecoli_download/ecoli_INNUENDO_wgMLST/temp/INNUENDO_wgMLST-00016261.fasta_result.txt'**
   <br>
    **A2**: This is due to lack of file permissions to edit *.fasta* files in cheBBACA flat file database.

   **Q3: Analysis of a tool (e.g., reads_serotypefinder) gets stuck and no apparent progress or error was found**
    <br> 
    **A3**:  More likely a database locking error inside of a container. Try to move the database out of container and use it from a mounted path.

    **Q4: How do you stop a running nextflow job on slurm cluster?**
     <br> 
     **A4**: As nextflow job that is running on cluster has several job steps, just cancelling a job step (scancel <job_id>) won't stop the whole
     nextflow  job. One easy way to stop the job is to find the master nextflow process ID (PID) using  the following command:

     ```
     cd /path/nextflow/submission/directory/   # move to the directory from where you have submitted job
     lsof .nextflow/cache/**/db/LOCK    # under cache directory ther should be folder name with hash number
     ```
     Above command should print PID of a running nextflow job among other column fields. Identiy the PID and kill the job as below:
     ```
     kill <pid>
     ```
