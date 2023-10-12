# Updating recent features of INNUca workflow inside [INNUENDO platform](https://innuendo.readthedocs.io/en/latest/index.html)
This documentation helps update the existing INNUca workflow  inside INNUENDO Platform with new features as available in [INNUca] (https://github.com/B-UMMI/INNUca) 4.2 version. Recent version of INNUca (v4.2) allows the following:
- Searching of [krakenDB] (https://ccb.jhu.edu/software/kraken2/) (i.e., minikraken2_v1_8GB) for taxonomic information both at read  (using PE reads in fastq files as input) and assembly level (using fasta file as input, generated from tools such as  pilon)
- Obtaining insertsize distribution (i.e., distribution of insert lengths) of reads
 
Kraken2 and Insertsize modules of INNUca are implemented as [FlowCraft](https://github.com/assemblerflow/flowcraft) components inside INNUENDO platform.  Additionally, whole INNUca v4.2 workflow is also made available for admin's usage to facilitate running the workflow with  overriding parameters as and when needed. 
Although this docuemntation is more about updating new features of INNUca workflow,  similar approach can be used to update any Nextflow tags inside  INNUENDO platform.


INNUENDO platform uses FlowCraft to build pipelines based on available protocols. So it is required to add new features of INNUca as components of Flowcraft to build on-the-fly custom-made Nextflow (workflow manager that enables scalable and reproducible scientific workflows using software containers)  workflows based on user defined inputs. INNUENDO also uses FlowCraft webapp interface for reporting and visualisations of different procesess of workflow. 

Entire process of updating INNUENDO platform with new features of INNUca involves editing (or even writing) several scripts inside the platform. Main steps (not necessarily in the same order) are described below:

- [Add newly defined Nextflow/Flowcraft tags inside the configuration file of INNUENDO front-end server](#add-newly-defined-nextflowflowcraft-tags-inside-the-configuration-file-of-innuendo-front-end-server)
- [Update new Nextflow tags inside the configuration file of INNUENDO process controller](#update-new-nextflow-tags-inside-the-configuration-file-of-innuendo-process-controller)
- [Modify INNUENDO platform recipe file](#modify-innuendo-platform-recipe-file)
- [Build singularity image for INNUca](#build-singularity-image-of-innuca)
- [Modify the configuration file of nextflow (nextflow.config) to add e.g., runOptions and other  options if necessary](#modify-the-configuration-file-of-nextflow-nextflowconfig-to-add-eg-runoptions-and-other-options-if-necessary)
- [Create process templates for new processes](#create-process-templates-files-for-new-processes)
- [Create process class files for new processes](#create-process-class-for-new-processes)
- [Write scripts  for generating reports from each process](#write-scripts-for-generating-reports-from-each-process)
- [Reporting and visualisation of results for new Nextflow process](#reporting-and-visualisation-of-results-for-new-nextflow-process)
- [Health check for newly added Nextflow tags and configurations](#health-check-for-newly-added-nextflow-tags-and-configurations)
- [Build species-specific workflows based on available protocols](#build-species-specific-workflows-based-on-available-protocols)
- [INNUca 4.2 workflow (admin version)](#innuca-42-workflow-admin-version)
- [Trouble shooting](#trouble-shooting)

----
## Add newly defined Nextflow/Flowcraft tags inside the configuration file of INNUENDO front-end server


Edit NEXTFLOW_TAGs section in the configuration file (e.g., config_frontend.py in docker-compose version) of front-end  server  to reflect
new  tags (e.g., "kraken2_innu", "kraken2fasta_innu", "insertsize_innu" and "innuca_whole" are marked as examples here) as shown below:

```

NEXTFLOW_TAGS = [
    "reads_download",
    "seq_typing",
    "patho_typing",
    "integrity_coverage",
    "fastqc_trimmomatic",
    "true_coverage",
    "fastqc",
    "check_coverage",
    "skesa",
    "spades",
    "process_skesa",
    "process_spades",
    "assembly_mapping",
    "pilon",
    "mlst",
    "abricate",
    "chewbbaca",
    "sistr",
    "trimmomatic",
    "kraken2_innu",
    "kraken2fasta_innu",
    "insertsize_innu",
    "innuca_whole",
    # "prokka",
] 

```
Then these new Nextflow tags would appear in INNUENDO GUI (i.e., inside admin tool -> protocols -> Nextflow Tag). **Please note** that it may require restarting of front-end server in order to appear in  GUI.

----
## Update new Nextflow tags inside the configuration file of INNUENDO process controller 

The configuration file of INNUENDO process controller (i.e., /Controller/INNUENDO_PROCESS_CONTROLLER/config.py in docker-compose version) should contain information about nextflow tags and their resources specification  as shown below:

```
# Specific process resources specifications
NEXTFLOW_RESOURCES = {
    "reads_download": {
        "memory": r"\'2GB\'",
        "cpus": "2"
    },
   
    .
    .
    .
    
"kraken2_innu": {
        "memory": r"\'2GB\'",
        "cpus": "1"
    },
   "kraken2fasta_innu": {
        "memory": r"\'2GB\'",
        "cpus": "1"
    },
 "insertsize_innu": {
        "memory": r"\'2GB\'",
        "cpus": "1"
    },
 "insertsize_innu": {
        "memory": r"\'2GB\'",
        "cpus": "1"
      },
 "innuca_whole": {
        "memory": r"\'2GB\'",
        "cpus": "1"
    },
    
```

Above information is necessary while building Nextflow pipeline  in the process controller when user submits  a workflow from GUI.

## Modify INNUENDO platform recipe file 

INNUENDO platform has its own curated recipe file (filename - recipe.py)  which defines a set of  software tools that can be run on the strain data in the correct order. So add new nextflow tags ("kraken2_innu", "kraken2fasta_innu","insertsize_innu" and "innuca_whole") paying attention to dependencies with other sofwtare tools as shown below:

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
            "reads_download": [False, None,"integrity_coverage|seq_typing|patho_typing"],
            "patho_typing": [True, None, None],
            "seq_typing": [True, None, None],
            "integrity_coverage": [True, None, "fastqc_trimmomatic|innuca_whole|kraken2_innu"],
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
            "pilon": [False, "assembly_mapping", "mlst|kraken2fasta_innu|insertsize_innu"],
            "mlst": [False, "pilon", "abricate|prokka|chewbbaca|sistr"],
            "sistr": [True, "mlst", None],
            "abricate": [True, "mlst", None],
            #"prokka": [True, "mlst", None],
            "chewbbaca": [True, "mlst", None],
            "kraken2_innu": [True,"integrity_coverage", None],
            "kraken2fasta_innu": [True,"pilon", None],
            "insertsize_innu": [True,"pilon", None],
            "innuca_whole": [True,"integrity_coverage", None]

        }
        
```

The recipe.py file is locoated  inside the folder ".../flowcraft/generator/" . Try not to copy the udpated recipe.py file as was done below in Docker-compose version, one can instead  update those new tags directly inside recipe.py ".../flowcraft/generator/" in the production version.

 ```
 # find / -name recipe.py
  yes | cp recipe.py -rf /Controller/flowcraft/build/lib/flowcraft/generator/
  yes | cp recipe.py -rf /usr/lib/python3.6/site-packages/flowcraft-1.4.0-py3.6.egg/flowcraft/generator/
  yes | cp recipe.py -rf /Controller/flowcraft/flowcraft/generator/
 
 ```

## Build Singularity image of INNUca 

Singularity image of INNUca software was built from Docker image as downloaded from [Docker hub](https://hub.docker.com/). In order to be compatible with output of INNUca, kraken and insertsize modules as implemented in INNUca are used. Here is an example  deffile for converting docker image to singularity:

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

# cp innuca.simg ~/.singularity_cache/ummidock-innuca-4.2.0-05.img
  
 ``` 
*** Please note *** chnages in the permissions of folder as defined in deffile above can be more restricted so that any user execute pipeline without the need for having previlised access permissions like root user as in the case of docker version.

## Modify the configuration file of nextflow (nextflow.config) to add e.g., runOptions and other  options if necessary

Nextflow configuration file (/Controller/flowcraft/flowcraft/nextflow.config) can be configured for options such as cacheDir and runOptions as shown below:

```
you can dd with runoptions (---bind /path   as below:
        singularity {
            cacheDir = "/mnt/singularity_cache"
            autoMounts = true
            runOptions = "--bind /INNUENDO/ftp/files/minikraken2_v1_8GB"
        }
        
```
This binding of path during run time is used to mount krakendb inside the INNUca container.
----
## Create process templates files for new processes

Please refer to excellent  Flowcraft [documentation] (https://flowcraft.readthedocs.io/en/latest/dev/create_process.html)  to  create  process templates. A new Nextflow tag requires creation of a process template that will eventually be integrated into the Nextflow pipeline. All files with defined process templates should be available inside "...flowcraft/generator/templates/" to build pipelines by Flowcraft. 
So all new .nf files (see files inside 'templates' directory in gitlab)  corresponding to new tags should be copied to templates folder (in docker-compsoe version) as shown  below:

 ``` 
 yes | cp *.nf -rf /Controller/flowcraft/flowcraft/generator/templates/
 yes | cp *.nf -rf  /Controller/flowcraft/build/lib/flowcraft/generator/templates/
 yes | cp *.nf -rf  /usr/lib/python3.6/site-packages/flowcraft-1.4.0-py3.6.egg/flowcraft/generator/templates/
 
 ```
 
 An example of INNUca process definition including the one for reporting is shown below:
 
 ```
 IN_kraken2_DB_{{ pid }} = Channel.value(params.kraken2DB{{ param_id }})
IN_speciesExpected_{{ pid }} = Channel.value(params.speciesExpected{{ param_id }})

//Process to run Kraken2
process kraken2_innu_{{ pid }} {

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
----
## Create process class for new processes

All new class definitions for new processes of INNUca  are defined here in metagenomics.py file. For example, class definition for kraken2 
with fastq (reads data) file as input is shown below:

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
## Write scripts for generating reports from each process

Scripts for generationg report for new each process are written in python and are added here in flowcraft folders (inside "../flowcraft/templates/)

```
 yes | cp *_report.py -rf /Controller/flowcraft/build/lib/flowcraft/templates/
 yes | cp *_report.py -rf /Controller/flowcraft/flowcraft/templates/
 yes | cp *_report.py  -rf /usr/lib/python3.6/site-packages/flowcraft-1.4.0-py3.6.egg/flowcraft/templates/
 
 ```

and warnings cane be generated for each process by providing the content o "value" field inside the json file as shown below (should be inside the above *_report.py files):

```

    json_dic["warnings"] = [{
               "sample": sample_id,
               "table": "qc",
               "value": []
              }]
    json_dic["warnings"][0]["value"].append("fail")
    json_report.write(json.dumps(json_dic, separators=(',', ':')))

```

## Reporting and visualisation of results for new Nextflow process

Existing javascripts inside Flowcraft webapp are sufficient for the most of reporting purposes. However, if neeeded one needs to modify javascript functions inside  flowcraft webapp. Typically, one needs to modify scripts such as drawings.js, charts.js, Reports.js, Tables.js etc and  rebuild a static main.js file for rendering reports 


For example, hearderMap inside drawings.js (/FlowCraft_inspect/flowcraft-webapp/flowcraft-webapp/frontend/src/components) is edited for laying out the reports panel as shown below.

```
const headerMap =  {
            "base_n_content": {"icon": <HeartPulseIcon/>, "text": "FastQC"},
            "Insert_dist": {"icon": <ChartHistogramIcon/>, "text": "Insert Size"},
            "size_dist": {"icon": <ChartScatterplotHexbinIcon/>, "text": "Contig size"},

        };

```
similarly modify Reports.js and charts.js files inside "../flowcraft-webapp/flowcraft-webapp/frontend/src" depending on the need for reporting results.

In the case of docker-compose version, the following was done to update modified javascript files (copied directly from host to flowcraft-webapp container )

```
 sudo cp charts.js  /var/lib/docker/overlay2/c7aef98aa4dabfaf1ed039c21b587ee67add8ff4aeb449c58400df340da94cc1/merged/FlowCraft_inspect/flowcraft-webapp/flowcraft-webapp/frontend/src/components/reports/charts.js
 sudo cp tables.js /var/lib/docker/overlay2/c7aef98aa4dabfaf1ed039c21b587ee67add8ff4aeb449c58400df340da94cc1/merged/FlowCraft_inspect/flowcraft-webapp/flowcraft-webapp/frontend/src/components/reports/tables.js
 sudo cp drawer.js /var/lib/docker/overlay2/c7aef98aa4dabfaf1ed039c21b587ee67add8ff4aeb449c58400df340da94cc1/merged/FlowCraft_inspect/flowcraft-webapp/flowcraft-webapp/frontend/src/components/reports/drawer.js
 sudo cp Reports.js /var/lib/docker/overlay2/c7aef98aa4dabfaf1ed039c21b587ee67add8ff4aeb449c58400df340da94cc1/merged/FlowCraft_inspect/flowcraft-webapp/flowcraft-webapp/frontend/src/components/Reports.js
```
and then ran the following command: 

```
 yarn run build #  This command will create new main.js file which will be used when report related request comes from process controller.
 *** note *** if needed, one can run "/bin/bash /FlowCraft_inspect/flowcraft-webapp/docker-flowcraft-entrypoint.sh init_all"  to build everything from the scratch in flowcraft webapp 
 ```
 

One can use different options for reporting for the *** flowcraft report ***  command. Few are shown below: 

```
flowcraft report  -i pipeline_report/pipeline_report.json  # without url, default it uses main.js file available inside the reports 
flowcraft report  -i pipeline_report/pipeline_report.json -u http://195.148.30.242/ # it uses main.js defined in the flowcraft-webapp assuming the URL 
```

In order to generate downlodable results in frontend GUI, final_POST.sh file was edited as bewlow ( so 'run_output':'None' in the original file was modified to as 'run_output':'$(pwd)/.command.out'):
```
#!/usr/bin/env sh

st=$(cat $(pwd)/.status)

json="{'project_id':'$1','pipeline_id':'$2','process_id':'$3','run_info':'None','run_output':'$(pwd)/.command.out','warnings':'$(pwd)/.warning','log_file':'$(pwd)/.command.log','status':'$st','type':'output'}"

{
    curl -H  "Content-Type: application/json" -L -X POST -d \"$json\" $4 > /dev/null
} || {
    echo Curl request failed
}

```
and be copied to the following location:

```
 yes | cp final_POST.sh   /usr/lib/python3.6/site-packages/flowcraft-1.4.0-py3.6.egg/flowcraft/bin/final_POST.sh
 yes | cp final_POST.sh   /Controller/flowcraft/flowcraft/bin/final_POST.sh
 yes | cp final_POST.sh   /Controller/flowcraft/build/lib/flowcraft/bin/final_POST.sh
 
 ```
 
Above script will send the "".command.out" file to front-end. It requires editing of some front-end scripts to be able to visible as a downlaodable file in front-end GUI

In the file  "./app/resources/jobs/jobs.py" at front-end app, make sure to modify jsonResult object have information from  file_2, file_3, fil_4 (file_3 is missing in original script) as shown below :

```
 queryString = "SELECT (str(?typelabel) as ?label) (str(?file1)"\
                              " as ?file_1) (str(?file2) as ?file_2) " \
                              "(str(?file3) as ?file_3) (str(?file4) as " \
                              "?file_4) (str(?status) as ?statusStr) " \
                              "WHERE{<"+procStr+"> obo:RO_0002234 ?in. ?in a " \
                              "?type.?type rdfs:label ?typelabel. OPTIONAL { " \
                              "?in obo:NGS_0000092 ?file1; obo:NGS_0000093 " \
                              "?file2; obo:NGS_0000096 ?file4; obo:NGS_0000094"\
                              " ?file3. } OPTIONAL {?in obo:NGS_0000097 " \
                              "?status.} }"

                tupleQuery = dbconAg.prepareTupleQuery(QueryLanguage.SPARQL,
                                                       queryString)
                result = tupleQuery.evaluate()

                jsonResult = parseAgraphQueryRes(
                    result, ["statusStr", "file_2","file_3","file_4"])
                    
```
and also, remove text " "style="display:none;" in scripts (related section shown below) files (./app/static/controllers/js_objects/single_project.js or ./app/static/controllers/js_objects/objects_utils.js)   so that output file is displayed in Fron-end GUI

```
<li class="' + pipelineIdentifier + '&&' + strain_name.replace(/ /g, '_') + "_workflow_" + String(count) + '_' + CURRENT_PROJECT_ID + '&&&" onclick="getProcessesOutputs(this)" style="display:none;"><a>Get Results</a></li>' +
                            '<li class="' + pipelineIdentifier + '&&' + strain_name.replace(/ /g, '_') + "_workflow_" + String(count) + '_' + CURRENT_PROJECT_ID + '&&&" onclick="getProcessesLog(this)" style="display:none;"><a>Get Run Log</a></li>';

```
**command hint** to locate the files and locations of certian text in file: grep -rnw ./  -e 'file_3' to find all scripts with file_3 as text or similarly, grep -rnw ./  -e  'Get Results' to spot 'Get Results' 


# Health check for newly added Nextflow tags and configurations 

It is good to check if the newly added tags are properly built before adding them to workflows inside INNUENDO GUI. 
One can check the information in frontend/process controller machines as below:


```
flowcraft build -L # this should list all the available tags in teh flowcraft
flowcraft build -L -r innuendo  # this should list all the available tags in teh flowcraft for inneundo recipe

```

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
and 

```
  
  flowcraft  build -t  "integrity_coverage={'pid':'3','cpus':'2','memory':'\'2GB\''}  \
  fastqc_trimmomatic={'pid':'4','cpus':'3','memory':'\'3GB\''}  \
  true_coverage={'pid':'5','cpus':'2','memory':'\'2GB\''} \
  fastqc={'pid':'6','cpus':'3','memory':'\'3GB\''}  \
  check_coverage={'pid':'7','cpus':'2','memory':'\'2GB\''}  \
  spades={'pid':'8','scratch':'true','cpus':'4','memory':'\'8GB\''}  \
  process_spades={'pid':'9','cpus':'3','memory':'\'3GB\''}  \
  assembly_mapping={'pid':'10','cpus':'3','memory':'\'3GB\''}  \
  pilon={'pid':'11','cpus':'3','memory':'\'3GB\''}  \
  mlst={'pid':'12','version':'tuberfree','cpus':'3','memory':'\'3GB\''} \
  innuca_whole={'pid':'13','cpus':'3','memory':'\'4GB\''}  -o test.nf -r innuendo
  ```


## Build species-specific workflows based on available protocols

Workflows inside INNEUNDO platform are built from uniquely defined protocols, which  are the basic unit for running processes. Workflow can then be
tailered to strains in our projects. Protocol types are defined by NGSOnto and are a way of classifying the available protocols. Each type can have different attributes as below:

- de-novo assembly protocol
- Sequencing quality control protocol
- Allele Call Protocol
- sequencing Protocol
- DNA Extraction protocol
- Pathotyping Protocol
- Sequence cutting protocol
- mapping assembly protocol
- Filtering protocol
- Library Preparation Protocol


It is required for the INNUENDO Platform to know which software (including fields) one is
going to use on that protocol to run it. The available tags (notice new tags are marked here) are: 

- reads_download
- seq_typing
- patho_typing
- integrity_coverage
- fastqc (fastqc_trimmomatic)
- true_coverage
- fastqc_2 (fastqc)
- integrity_coverage_2 (check_coverage)
- spades
- process_mapping
- pilon
- mlst
- sistr
- chewBBACA
- abricate
- kraken2_innu (new tag)
- kraken2fasta_innu (new tag)
- insertsize_innu (new tag)
- innuca_whole (new tag)

In the INNUENDO platform, each of these tags are closely related to the Nextflow Tags chosen. So, to
have a good agreement between Software and Nextflow Tags, pair them together. 
Nextflow Tags are the specific names that [FlowCraft](<https://github.com/assemblerflow/flowcraft) requires to build
Nextflow pipelines based on the available software at the INNUENDO Platform.


The protocol name is the identifier that will appear when choosing protocols
to apply to a workflow. Each protocol name **MUST** be unique. Also, try to
make a reference for the nextflow tag used in the protocol name in order to
establish a better organization regarding available protocols.

In front-end GUI, building workflows typically involves following steps:

  - Add protocol for a specie
  <img src="./kraken2_campy.pdf" alt="Example here" width="738">

  - Build workflows based on available species-specififc protocols

  - Test  the workflows (successful workflow will be added for that specie for running)

---
## INNUca 4.2 workflow (admin version)

INNUca 4.2 admin version is implemented with following parameters:

```

INNUca.py     --fastq  ${fastq_pair[0]} ${fastq_pair[1]}  --speciesExpected "'${species}'"   --genomeSizeExpectedMb 2.1 --threads 8 --fastQCproceed --trimKeepFiles  --krakenProceed --krakenDB ${krakenDB} --insertSizeDist  --pilonKeepFiles --skipTrueCoverage --runKraken --saveExcludedContigs

```

So if necessary, one has to modify parameters of INNUca as needed.

**Some Notes** 

- If "check_coverage" tag is not added as part of the protocol when building a workflows, it is neither  building nor  complaining !!!
- When adding protocols, add single quotes for parameters
- All resources are as set in docker-compose version and can be changed to fit in the production environment
- Some reporting results may depend on browser ( or clean cache as well as edit blocking settings by some sofware)

## Trouble shooting
