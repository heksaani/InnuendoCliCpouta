# InnuendoCLI platform documentation (WIP)

## Contents
 - [Installation of InnuendoCLI platform](#installation-of-innuendoCLI-platform)
 - [InnuendoCLI Usage](#innuendocli-usage)
 - [Updating or adding a new module in InnuendoCLI platform](#updating-a-module-in-innuendoCLI-platform)
 - [Updating software databases](#update-innuendoCLI-software-database)
 - Sample databases
 - [Updating a new software/tool](#updating-a-new-software)
 - [Troubleshooting](#troubleshooting)

## Installation of InnuendoCLI platform
### Installation of Nextflow
Nextflow is a workflow manager that enables scalable and reproducible scientific workflows using software containers.
An overview of how to install and its requirements, please refer to [official documentation](https://www.nextflow.io/docs/latest/index.html).
However, you can run the following commands for basic installation:
```
# Install Java (required for Nextflow)
sudo apt install openjdk-11-jre-headless

# Download specific Nextflow version (replace with desired version, e.g., v23.04.3)
wget https://github.com/nextflow-io/nextflow/releases/download/<version>/nextflow

# Alternatively, install the latest version
wget -qO- https://get.nextflow.io | bash


```
Above script installs *nextflow* binary on the current directory. To make it accessible system-wide, you need to add it to user PATH by simply
moving the executable to  /usr/local/bin as shown below:
```
# Move the binary to a system-wide location
sudo mv nextflow /usr/local/bin
```
You can now run Nextflow software. For usage instructions, use the following command:
```
nextflow -h
```
 
> Please note that the nextflow version starting from 23.04.3 can only be used for pipelines built with DSL2. You can downgrade to lower versions for DSL1-compliant pipelines.

### Installation of Flowcraft

In the InnuendoCLI platform, Flowcraft serves as the pipeline builder, generating workflows according to the defined protocols. For more details, please consult official [documentation](https://flowcraft.readthedocs.io/en/latest/?badge=latest). Here is a way to install the flowcraft using conda:

```
# Install Miniconda (if not already installed)
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh

# Install Flowcraft via Bioconda
conda install -c bioconda flowcraft
```

## InnuendoCLI Usage
### **Launching workflows**
Before launching workflows, please ensure the following preparations are complete:
- **Sample Upload**:Upload your raw data samples to a dedicated directory on the InnuendoCLI machine. Use one of the following base folder paths, depending on your user setup:
   - /mnt/rv_data/your_username/ftp
   - /mnt/thl_data/your_username/ftp

For better organization, create a subfolder corresponding to each batch of samples you plan to analyze (e.g., /mnt/rv_data/your_username/ftp/ecoli_samples for E. coli samples).

- **Metadata File Upload**: Create an input metadata file for the Nextflow job and place it under the same folder as your raw data.
   - Follow the field specifications carefully.
   - Refer to metadata_example.csv and metadata_screenshot.png in the GitHub repository.
   - See the *MetadataVocab* folder for field definitions and restrictions.

- **Submit Workflows:** you can launch your pipeline after navigating to the folder where you have metadata file and raw data are stored.
   ```bash
   # Syntax for running automated worklfow in the background.
   # After issueing the following command, use  **contrl + c**  to get back to linux terminal.
   
   nohup bash icli-run -p -m  -r -f metadata_example.csv > log.txt &
   
   # You can also view file metadata_screenshot.png to get some idea about metadata file
   # you can monitor the resulting output in the file, log.txt ( use less/more/tail log.txt) to check
   # if the job has successfully been started.

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

  ### **Examining your reports**
    Reports are generated automatically once your submitted job has successfully run. Within your job directory (located under the base path: /mnt/thl_data/$USER/jobs/ or /mnt/rv_data/$USER/jobs/), you will find the analysis results organized into two folders: results and reports. The reports folder also includes the following summary files:
   - Innuendo_reports.xlsx
   - combine_samples_reports.tab
   - Samples_reports.tab
   - AMR_reports.tab
   - log_reports.tab
   - typing_reports.tab

   Please note that the excel file, Innuendo_reports.xlsx also comprises all reports, each one in a separate excel sheet.

 - ### **Visualising ChewBBACA allelic profiles using Grapetree**
   Grapetree software (version 2.2.0) is installed on InnuendoCLI machine and can be used for the visualization of allelic profiles.  You can use the
   following command on linux terminal to launch GrapeTree: 

    ```bash
    grapetree
    ```
    Once the software is launched, you can access it from your web browser using the following URL: http://floating_ip:5000/. The floating_ip is shared 
    seperately in e-mail.

   Since metadata is still being compiled for the in-house generated allelic profiles, only the raw samples can be visualized at this time. A search tool has been developed to find the nearest neighbors and retrieve their corresponding allelic profiles. To use this tool, you need to create a query file containing the allelic profile of a sample (see the example  file: indexquery in this GitHub repository), and then run the search for the sample’s nearest neighbors as shown below::

    ```bash
    index_profiles indexquery
    ```
    The command above will generate a file named indexquery_nearest_profiles.tsv, containing the nearest neighbors along with their allelic profiles. This file can be used to create tree visualizations using the GrapeTree software.
   
## Updating a module in InnuendoCLI platform

The InnuendoCLI platform provides a set of workflow recipes that can be assembled to run software on strain data in the correct order. It leverages [FlowCraft technology](https://github.com/assemblerflow/flowcraft) to dynamically build pipelines based on available modules. To use a new module on-the-fly, it must first be defined as a component within FlowCraft. InnuendoCLI includes its own recipe called *innuendo*, and you can view the available modules within this recipe using the following command:

```bash
> flowcraft build -L # this should list all the available modules in  the flowcraft
> flowcraft build -L -r innuendo  # this should list all the available  modules in Innuendo platform
```

The entire process of creating (or updating) InnuendoCLI with a new module involves editing (or even writing) several scripts inside of the platform. Main steps (not necessarily in the same order) are described below:

- Modify INNUENDO platform recipe file
- Build singularity image for INNUca
- Modify the configuration file of nextflow (nextflow.config) to add e.g., runOptions and other  options if necessary
- Create process templates for new processes
- Create process class files for new processes


### Modify InnuendoCLI platform recipe file 

The InnuendoCLI platform includes a curated recipe file (recipe.py) that defines a set of software tools and their execution order for processing strain data.

To add a new Nextflow module (e.g., Kraken2), you must update this recipe file, ensuring that the new module is integrated in the correct position within the workflow and that any dependencies on other tools are properly handled. An example of how to add a module while managing dependencies is shown below:

```
class Innuendo(InnuendoRecipe):
    """
    Recipe class for the INNUENDO Project. It has all the available in the
    platform for quick use of the processes in the scope of the project.
    """

    def __init__(self, *args, **kwargs):

        super().__init__(*args, **kwargs)

        # The description of the processes
        # [forkable, input_process, output_process]
        self.process_descriptions = {
            "reads_download": [False, None,"integrity_coverage"],
            "integrity_coverage": [True, None, "fastqc_trimmomati|kraken2"],
            "fastqc_trimmomatic": [False, "integrity_coverage",
                                   "true_coverage"],
            "true_coverage": [False, "fastqc_trimmomatic",
                              "fastqc"],
            "fastqc": [False, "true_coverage", "check_coverage"],
            "check_coverage": [False, "fastqc", "spades|skesa"],
            "spades": [False, "fastqc_trimmomatic", "process_spades"],
            "skesa": [False, "fastqc_trimmomatic", "process_skesa"],
            "process_spades": [False, "spades", "assembly_mapping"],
            "process_skesa": [False, "skesa", "assembly_mapping"],
            "assembly_mapping": [False, "process_spades", "pilon"],
            "pilon": [False, "assembly_mapping", "mlst"],
            "mlst": [False, "pilon", "chewbbaca"],
            "chewbbaca": [True, "mlst", None],
            "kraken2": [True,"integrity_coverage", None],
        }
        
```

The recipe.py file is locoated  inside the folder ".../flowcraft/generator/".  In the above example,  kraken2 is added as an example defining a fork ("true") with an upstream module ("integrity_coverage") and no downstream modules (None). 


### Build Singularity image of Kraken2 

The Singularity image for the Kraken2 software was built from a Docker image downloaded from [Docker hub](https://hub.docker.com/). The Kraken2 module can be built using a Singularity definition file (deffile) or pulled directly from Docker registries if the image is available.

```
Bootstrap: docker
From: ummidock/innuca:4.2.0-05
%post
chmod -R a+rwX /usr
chmod -R a+rwX /NGStools
chmod -R a+rwX /var
cp -fr /usr/local/lib/python2.7/dist-packages/* /usr/local/lib/python3.5/dist-packages/

# and run build command 
sudo singularity build innuca.simg deffile 
 ```

For example one can pull the image for the DocekrHub as below:

```bash
sudo singularity build docker://staphb/kraken2:2.1.3
```

The built image can be stored in the Singularity cache directory. In principle, if you provide the image URL from a registry, the image can be built on-the-fly. However, this approach may result in errors if not executed correctly.

### Modify the Nextflow configuration file (nextflow.config) to add runOptions, along with any other necessary settings.

Nextflow configuration file (/Controller/flowcraft/flowcraft/nextflow.config) can be configured for options such as cacheDir and runOptions as shown below:

```
you can dd with runoptions (---bind /path   as below:
        singularity {
            cacheDir = "/mnt/singularity_cache"
            autoMounts = true
            runOptions = "--bind /INNUENDO/ftp/files/minikraken2_v1_8GB"
        }
        
```
This runtime path binding is used to mount the krakendb inside the Kraken2 container. Alternatively, the database can be stored within the container itself. However, updating the database is easier when it is located outside the container; otherwise, the container must be modified to update the database.

### Create process templates files (.nf file) for new processes

Please refer to excellent  Flowcraft [documentation] (https://flowcraft.readthedocs.io/en/latest/dev/create_process.html)  to  create  process templates. A new Nextflow tag requires creation of a process template that will eventually be integrated into the Nextflow pipeline. All files with defined process templates should be available inside "...flowcraft/generator/templates/" to build pipelines by Flowcraft. 
 
 An example of kraken2 process definition is shown below:
 
 ```
 IN_kraken2_DB_{{ pid }} = Channel.value(params.kraken2DB{{ param_id }})
IN_speciesExpected_{{ pid }} = Channel.value(params.speciesExpected{{ param_id }})

//Process to run Kraken2
process kraken2_{{ pid }} {

    // Send POST request to platform
    {% include "post.txt" ignore missing %}

    tag { sample_id }

    publishDir "results/kraken2/", mode: 'copy', pattern: "*.{txt,tab,html}"

    input:
    set sample_id, file(fastq_pair) from {{ input_channel }}
    val krakenDB from IN_kraken2_DB_{{ pid }}
    val species from IN_speciesExpected_{{ pid }}

    output:
    file "*"
   // file("${sample_id}_kraken_report.txt")
  //  set sample_id, file('*.evaluation.minikraken2_v1_8GB.fastq.tab') into LOG_kraken2_innu_{{ pid }}
    set sample_id, file('*.evaluation.minikraken2_v1_8GB.fastq.tab'), file('kraken_report.minikraken2_v1_8GB.fastq.txt'),file('summary_warnings_fastq.txt')  into LOG_kraken2_innu_{{ pid }}
    {% with task_name="kraken2_innu" %}
    {%- include "compiler_channels.txt" ignore missing -%}
    {% endwith %}

    script:
    """

    export PYTHONPATH=$PYTHONPATH:/NGStools/INNUca
    python -c "from modules.kraken import run_for_innuca; summary = [None] * 6; summary=run_for_innuca(species='${species}', files_to_classify=['${fastq_pair[0]}','${fastq_pair[1]}'], kraken_db='${krakenDB}', files_type='fastq',outdir='.',version_kraken=2);print(summary);f=open('summary_report_fastq.txt','w');f.write(str(summary[3]['taxon']).strip('[').strip(']') + ';\\n') if 'taxon' in summary[3] else ''; f.write(str(summary[4]['unknown']).strip('[').strip(']')) if 'unknown' in summary[4] else ''; f.close()"
    cat summary_report_fastq.txt | sed -e "s/'//g" > summary_warnings_fastq.txt
    python -c "from modules.kraken import rename_output_innuca as rename_innuca; rename_innuca('${krakenDB}','fastq','')"
    echo pass > .status

    """
}

process kraken2_innu_report_{{ pid }} {

    {% with overwrite="false" %}
    {% include "post.txt" ignore missing %}
    {% endwith %}

    tag { sample_id }

    input:

    set sample_id, file(fastq_eval_file), file(fastq_report_file), file(qc_report_file)  from LOG_kraken2_innu_{{ pid }}

   // set sample_id, file(fastq_eval_file) from LOG_kraken2_innu_{{ pid }}.collect()

    output:
//    file "*" into kraken2_innu_report_out_{{ pid }}
    {% with task_name="kraken2_innu_report" %}
    {%- include "compiler_channels.txt" ignore missing -%}
    {% endwith %}

    script:
    template "kraken2_innu_report.py"

}

{{ forks }}

```

### Create process class for new processes

All new class definitions for INNUca processes are located in the metagenomics.py file. For example, the class definition for Kraken2, which takes FASTQ (reads) files as input, is shown below:

```
class Kraken2_innu(Process):
    """kraken2 process template interface
            This process is set with:
                - ``input_type``: fastq
                - ``output_type``: txt
                - ``ptype``: taxonomic classification
    """
    def __init__(self, **kwargs):

        super().__init__(**kwargs)

        self.input_type = "fastq"
        self.output_type = None

        self.params = {
            "kraken2DB": {
                "default": "'minikraken2_v1_8GB'",
                "description": "Specifies kraken2 database. Requires full path if database not on "
                               "KRAKEN2_DB_PATH."
            },
          "speciesExpected": {
                "default": "'None'",
                "description": "expected species"
            },
        }

        self.directives = {
            "kraken2_innu": {
                "container": "ummidock/innuca",
                "version": "4.2.0-05",
                "memory": "{8.Gb*task.attempt}",
                "cpus": 4
            }
        }

        self.status_channels = [
            "kraken2_innu",
            "kraken2_innu_report"
        ]

```
 For the definitions of all other classes, please check metagenomics.py file. 
 In the docker-compose version the following was done:
 ```
 # find / -name metagenomics.py 
 yes | cp metagenomics.py -rf /Controller/flowcraft/build/lib/flowcraft/generator/components/
 yes | cp metagenomics.py -rf /Controller/flowcraft/flowcraft/generator/components/
 yes | cp metagenomics.py -rf /usr/lib/python3.6/site-packages/flowcraft-1.4.0-py3.6.egg/flowcraft/generator/components/
 
 ```
*** please note *** that these class definitions can be added directly (instaead overriding the file) inside metagenomics.py file of INNUENDO platform in the production version to avoid loosing the existing class definitions. 




One can also check work flows by properly adding all the necessary sofwtare tools along with fields as shown with some examples below:

```
python3 /usr/local/lib/python3.6/dist-packages/flowcraft-1.4.2-py3.6.egg/flowcraft/flowcraft.py  build -t "integrity_coverage={'pid':'3','cpus':'2','memory':'\'2GB\''}  fastqc_trimmomatic={'pid':'4','cpus':'3','memory':'\'3GB\''}  true_coverage={'pid':'5','cpus':'2','memory':'\'2GB\''} \
  fastqc={'pid':'6','cpus':'3','memory':'\'3GB\''}  \
  check_coverage={'pid':'7','cpus':'2','memory':'\'2GB\''}  \
  spades={'pid':'8','scratch':'true','cpus':'4','memory':'\'8GB\''}  \
  process_spades={'pid':'9','cpus':'3','memory':'\'3GB\''}  \
  assembly_mapping={'pid':'10','cpus':'3','memory':'\'3GB\''}  \
  pilon={'pid':'11','cpus':'3','memory':'\'3GB\''}  \
  mlst={'pid':'12','version':'tuberfree','cpus':'3','memory':'\'3GB\''} "  -o innuendo.nf -r innuendo
  
```

## Update InnuendoCLI software database  

InnuendoCLI uses multiple databases that often need to be updated regularly. Each database may have multiple sources or methods for updating. Below are some examples of how to update these databases.

Since InnuendoCLI runs within containers, some containers may include the databases internally. However, it is preferable to keep the databases outside the containers, allowing you to update the databases independently without having to modify or rebuild the software container.

**Note**: When you update the databases, make sure to update the databas version or download date to respective reports (e.g., logs and AMR reports)
### Resfinder: 
You can clone the latest versions of [Resfinder database]((https://git@bitbucket.org/genomicepidemiology/resfinder_db.git) from genomicepidemiology project as below:
```bash
# clone database to some directory (e.g., /mnt/rv_data/username/) on the InnuendoCLI machine 
git clone https://git@bitbucket.org/genomicepidemiology/resfinder_db.git
# tools like kma and kma_index are needed for indexing 
singularity exec -B $PWD -B /home/ubuntu /mnt/singularity_cache2/genomicepidemiology-resfinder-4.1.3.img bash
cd resfinder_db/
# Index: one way to index the database 
python3 INSTALL.py
```
You can finally transfer the indexed database to the expected location of tools. 

### Pointfinder

You can clone the latest version of [pointfinder database](https://git@bitbucket.org/genomicepidemiology/pointfinder_db.git) as below:
```
git clone https://git@bitbucket.org/genomicepidemiology/pointfinder_db.git
singularity exec -B $PWD -B  /home/ubuntu /mnt/singularity_cache2/genomicepidemiology-resfinder-4.1.3.img bash
python3 INSTALL.py
```
### Virulencefinder
```
git clone https://bitbucket.org/genomicepidemiology/virulencefinder_db.git
cd virulencefinder_db
singularity exec -B $PWD -B /home/ubuntu  /mnt/singularity_cache2/genomicepidemiology-resfinder-4.1.3.img bash
python3 INSTALL.py
```
### Serotypefinder
```
git clone https://bitbucket.org/genomicepidemiology/serotypefinder_db.git
cd serotypefinder_db
singularity exec -B $PWD -B /home/ubuntu  /mnt/singularity_cache2/genomicepidemiology-serotypefinder-2.0.1.img bash
STFinder_DB=$(pwd)
# Install SerotypeFinder database with executable kma_index program
python3 INSTALL.py kma_index
```

### MLST database

 The easiest way to update the MLST database is to use the existing MLST database and its compatible software from container registry. TAn example of container registry is [Docker hub](https://hub.docker.com/). 
 
 ```bash
 singularity build ummidock-mlst-2.23.0.img docker://ummidock/mlst:v2.23.0
 ```
 Path of the database can be adjusted. 
 
### Updating a new software

Updating a new software means usually updating the container image of the software. Once the software is updated, make sure that commands works fine. 

## Troubleshooting

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
 
 **A2**: This is due to lack of file permissions to edit *.fasta* files in cheBBACA flat file database.

 **Q3: Analysis of a tool (e.g., reads_serotypefinder) gets stuck and no apparent progress or error was found**


 **A3**:  More likely a database locking error inside of a container. Try to move the database out of container and use it from a mounted path.

 **Q4: How do you stop a running nextflow job on slurm cluster?**

 **A4**: As nextflow job that is running on cluster has several job steps, just cancelling a job step (scancel <job_id>) won't stop the whole
     nextflow job. One easy way to stop the job is to find the master nextflow process ID (PID) using  the following command:
     
  ```
     cd /path/nextflow/submission/directory/   # move to the directory from where you have submitted job
     lsof .nextflow/cache/**/db/LOCK    # under cache directory ther should be folder name with hash number
  ```
    
   Above command should print PID of a running nextflow job among other column fields. Identiy the PID and kill the job as below:
     
  ```
     
     kill <pid>
   ```
     
 **Q5: ChewBBACA error: EOFError: Ran out of input or Filenotfound error**

 **A5**: Ran out of disk space where ChewBBACA databases are stored
