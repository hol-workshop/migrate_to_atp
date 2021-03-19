# migrate_to_atp
Hello Folks! Welcome to migrate to autonomous database lab.

In this lab we will migrate a postgresql database to an Autonomous database in Oracle Cloud Infrastructure. We will use Oracle Goldengate for migration steps, and all of our services will be hosted in OCI for this lab purpose. This lab has 4 steps.

In step 1, we will use terraform to create and prepare our work environment:

- Virtual Cloud Network: we will create a VCN with public sub network and internet access to avoid complexity.
- Source Postgreqsql database: we will create a Postgresql database server in a Virtual Machine, acts as our source on-premise databas.
- Goldengate for non-Oracle deployment: we will create a Goldengate classic for Postgresql which will extract data from source and ships trails to cloud.
- Goldengate Microservices deployment: we will create a Microservices environment for Autonomous database which applies trails from source to target autonomous database.
- Target Autonomous database: we will provision Oracle Autonomous database acts as our target database.

![](/files/architecture.png)

In step 2, We will create our target tables' structures in Autonomous database
- Create tables using pre-created sqlfile.
- Enable GGADMIN for Goldengate replication.

In step 3:

- Extract exttab process at Goldengate for non-Oracle database, it is known as change data capture for continuous replication.
- Extract extdmp process at Goldengate for non-Oracle database, it will ship our captured trail files to Microservices for continuous replication.
- Extract initload process at Goldengate for non-Oracle database, it is our first data loader process and inserts to ATP.

![](/files/general.gif)

In step 4:
- Replicate process at Microservices, it will apply trail files captured by initload process.

# Prerequisites 

In this step, we will show you how to prepare your work environment in Oracle Cloud Infrastructure. We will use cloud-shell as our terminal which is console based, web terminal built in OCI console. It is good to use this terminal, in case you are behind corporate VPN, in case you don't have stable network connection.
To use the Cloud Shell machine, your tenancy administrator must grant the required IAM (Identity and Access Management) policy.

### Assumptions
- You have an Oracle **Free Tier** or existing **Paid** cloud account
- Your cloud account user must have required IAM (Identity and Access Management) policy or admin user.

### Objectives

-   Create SSH keys in cloud-shell environment
-   Configure API keys for your cloud user
-	  Modify ".bash_profile" to interact with terraform 

Let's prepare our work directory. 

Open Cloud-shell in OCI web console, which is simple and sophisticated cloud terminal for the most of your need. It is located right top corner of OCI web console

![](/files/0.Prep_0.PNG)

Once cloud shell environment is ready, issue below commands:

```
  ssh-keygen -t rsa -N "" -b 2048 -f ~/.ssh/oci
  
  openssl genrsa -out ~/.ssh/oci_api_key.pem 2048
  
  openssl rsa -pubout -in ~/.ssh/oci_api_key.pem -out ~/.ssh/oci_api_key_public.pem
 
  openssl rsa -pubout -outform DER -in ~/.ssh/oci_api_key.pem | openssl md5 -c | awk '{print $2}' > ~/.ssh/oci_api_key.fingerprint
  
  cat ~/.ssh/oci_api_key_public.pem
  
```
and copy your public pem file content.

![](/files/0.Prep_1.PNG)

Now, click on right top corner of your OCI web console, and click on your profile. Then navigate to "API Keys" from left pane and click on "Add API Key" button. Small pop-up will appear and you need to choose "Paste Public Key" radiobutton. Paste your copied public pem key there and click on "Add" button.

![](/files/0.Prep_2.PNG)

A small confirmation will show after you added an API key. Copy those values and open a notepad and keep them for a moment.

![](/files/0.Prep_3.PNG)

In your notepad, modify following:
```
  export TF_VAR_compartment_ocid="your-tenancy-value-goes-here"
  export TF_VAR_fingerprint="your-fingerprint-value-goes-here"
  export TF_VAR_private_key_path="~/.ssh/oci_api_key.pem"
  export TF_VAR_region="your-region-value-goes-here"
  export TF_VAR_tenancy_ocid="your-tenancy-value-goes-here"
  export TF_VAR_user_ocid="your-user-value-goes-here"
```

After you modified above using your parameters/values, now we we will save it to ".bash_profile", go to cloud-shell terminal and issue:

```
  vi ~/.bash_profile
```


*NOTE: Edit a file uses **vi** editor, if you never used it before here is little instruction. 
When you issue **vi .bash_profile** it will open a file. You have to press **i** key to enable editing, then "shift+insert" to paste from clipboard. When you are done editing press **:wq** keys then hit enter for save & quit.*

![](/files/0.Prep_4.PNG)


Now, once you've set these values close cloud-shell terminal by clicking on exit "X" button. Then again open cloud-shell terminal.


![](/files/0.Prep_0.PNG)

You've done with prerequisites.

# LAB 1

In this first lab, we will prepare our work environment and create our lab resources using Terraform script.

```
git clone https://github.com/hol-workshop/migrate_to_atp.git

cd migrate_to_atp
```

![](/files/1.Git.PNG)


Now we need to create a file to help terraform understanding your environment. Let's modify following parameters in your notepad and copy it.

```
tenancy_ocid  = "your_tenancy_value_here"
ssh_public_key  = "~/.ssh/oci.pub"
region = "your-region-value here"
compartment_ocid = "your-tenancy-value_here"
```

Enter below command in your current working migrate_to_atp directory:

**`vi terraform.tfvars`**

*This will create a new file, you have to press **i** key to enable editing, then "shift+insert" to paste copied parameter. When you are done editing press **:wq** keys then hit enter for save & quit.*

Good practice is, always keep it in your side notepad,

### Terraform

Now, time to play terraform. Run below command to download necessary terraform files from OCI provider.

```
terraform init
```

Plan and apply steps shouldn't ask any input from you. If it asks you to provide such as compartment_ocid, then again check previous files.

```
terraform plan

terraform apply --auto-approve
``` 

Make a copy of your output results in your notepad also for later use.

![](/files/1.git_1.PNG)

# LAB 2

We need to create our target tables for our GG migration and enable GGADMIN for replication to Autonomous database.

#### Open SQL developer web 

Go to top left hamburger icon, navigate to **Autonomous Transaction Processing** and click on **HOL Target ATP** database.

![](/files/2.atp.PNG)

In **Tools** tab, where you will see **Database Actions**, click on **Open Database Actions**. You may need to enable pop-up your browser if it doesn't open anything.

![](/files/2.atp_1.PNG)

A new sign-in page opens, enter **ADMIN** in Username, when it asks you to enter password, which is in terraform output. Go and copy, then paste here.

![](/files/sql_dev_1.png)

In the **DEVELOPMENT** section, click on **SQL**. 

#### Create target tables

Let's create our target tables for migration. Please download target table creation script **[from here](./files/CreateTables.sql)**.  Open this file link and choose **RAW** then save it as CreateTables.sql file. Make sure to save these with correct extension **.sql** not txt!

SQL Developer Web opens a worksheet tab, where you execute queries. Drag your downloaded **CreateTables.sql** file and drop in the worksheet area. Then run create statements.

![](/files/sql_dev_2.png)

There should have **5** tables created after script execution.

#### Enable GGADMIN 

Now let's unlock and change the password for the pre-created Oracle GoldenGate user (ggadmin) in Autonomous Database.
Enable GGADMIN by running following query:

```
alter user ggadmin identified by "GG##lab12345" account unlock;
```

![](/files/sql_dev_3.png)

Let's check whether the parameter enable_goldengate_replicaton is set to true. 
```
select * from v$parameter where name = 'enable_goldengate_replication';
``` 

If value is FALSE, then modify the parameter:

```
alter system set enable_goldengate_replication = true scope=both;
``` 
to enable_goldengate_replicaton, check results. This is only applicable to older Autonomous database version.

![](/files/sql_dev_4.png)

We successfully enabled GGADMIN in our target Autonomous Database and created target table structures. 


# LAB 3 

With Oracle GoldenGate Classic for PosgreSQL, you can perform initial loads and capture transactional data from supported PostgreSQL versions and replicate the data to a PostgreSQL database or other supported Oracle GoldenGate targets, such as an Oracle Database. 
We have created and pre-loaded some test data into our test Postgresql database in step 1 using terraform automation.

As you can see below, we will need 3 extract processes for continuous replication and migration:
  - An extract for changed data capture. Exttab process will start capturing changes and this will create some files called trails.
  - An extract for sending those capture to GG Microservices. Extdmp will be pumping trail files.
  - An Initial-Load extract. While changes are being captured, migration step needs special type of extract and replicat process, this is is cold data. Usually after initial load finishes, we start applying changed data while initial load happens.

![](/files/general.gif)

This part describes the tasks for configuring and running Oracle GoldenGate for PostgreSQL and [I used official oracle documentation for this lab](https://docs.oracle.com/en/middleware/goldengate/core/19.1/gghdb/preparing-system-oracle-goldengate3.html)

I'd say there are many requirements for replicating data from PostgreSQL database, review official document if you want extra options such as more security with different privileges et cetera.

Let's begin.

#### Connect to your Microservices instance

We need to enable network access to Microservices from our Classic deployment. Without adding ports to Microservices' firewall would cause you failure in next steps.
Let's make console connection to microservice, copy ip address of OGG_Microservices_Public_ip and connect using:

**`ssh opc@your_microservice_ip_address -i ~/.ssh/oci`**

Once you are there run below commands, which will add ports and take them in effect.

```
sudo firewall-cmd --zone=public --permanent --add-port=9011-9014/tcp

sudo firewall-cmd --zone=public --permanent --add-port=9021-9024/tcp

sudo firewall-cmd --zone=public --permanent --add-port=443/tcp

sudo firewall-cmd --zone=public --permanent --add-port=80/tcp

sudo firewall-cmd --zone=public --permanent --add-port=7809-7810/tcp

sudo firewall-cmd --reload

```

Exit from this instance with command **`exit`** and go back to your cloud-shell.

#### Access to Goldengate classic instance

Oracle GoldenGate Classic for Non-Oracle (PostgreSQL) allows you to quickly access the GoldenGate Service Command Interface (GGCSI) and is preconfigured with a running Manager process. Copy ip address of OGG_PGSQL_Public_ip and connect using:

**`ssh opc@your_ogg_pgsql_ip_address -i ~/.ssh/oci`**

#### Run GGSCI for the first time

After logging in to the compute node, you need to make sure your Goldengate environment knows about current odbc driver, execute the following commands separately in your cloud-shell:

```
export ODBCINI=/home/opc/postgresql/odbc.ini

cd /usr/local/bin/
```

Then run below command to start GGSCI to start:

```
./ggsci
```

![](/files/gg_pg_config_2.gif)

#### Create Work directories 

We need to create our work directories in GoldenGate before we start working. Command creates the default directories within the Oracle GoldenGate home directory. 

Once you are in GGSCI console, issue below command to create your directories.

```
CREATE SUBDIRS
```
#### Edit Goldengate Manager Port

We need to set manager’s port to start Goldengate manager process
To do so, issue:

```
EDIT PARAMS MGR
```

It will open parameter file of manager process and enter and save.

```
PORT 7809
```
_**NOTE:** Editing uses **vi** editor, you have to press key **i** to edit and press **:wq** keys then **hit enter** for save & quit._



#### Start Goldengate Manager

Now start Goldengate manager process by issuing below command:

```START MGR```

You can check if manager status by issueing **`INFO MGR`** command.

![](/files/gg_pg_config_3.gif)

#### Connect to Source PostgreSQL

Run the following command to log into the database from Goldengate instance:

**```DBLOGIN sourcedb PostgreSQL USERID postgres PASSWORD postgres```**

You should be able to see below information saying *Successfully Logged into database*

![](/files/gg_pg_dblogin.png)

Now you are logged into source database from GGSCI console, which means you are ready to proceed. Remember that we need to create three extract processes and we have five tables in source database.

#### Enabling Supplemental Logging for a Source PostgreSQL Database

After logging to the source database, you must enable supplemental logging on the source schema for change data capture. The following steps are used to enable supplemental logging at table level.

```
add trandata public."Countries"

add trandata public."Cities"

add trandata public."Parkings"

add trandata public."ParkingData"

add trandata public."PaymentData"
```

![](/files/gg_pg_trandata.png)

#### Registering a Replication Slot

Oracle GoldenGate needs to register the extract with the database replication slot, before adding extract process in Goldengate. 
_Ensure that you are connected to SourceDB using the DBLOGIN command._

We will issue register command in each of these extracts steps.

#### EXTTAR

Oracle GoldenGate needs to register the extract with the database replication slot, before adding extract process in Goldengate. 
_**Ensure that you are connected to SourceDB using the DBLOGIN command.**_

Let's begin to create the first extract process, which is continuous replication in usual migration and replication project scenario.


1. First register your extract: 

```register extract exttar```

![](/files/gg_pg_exttar_0.png)

2. Then edit extract configuration with **`edit params exttar`**. 

![](/files/gg_pg_exttar_1.png)

Insert below as your exttar parameter:
```
EXTRACT exttar
SOURCEDB PostgreSQL USERID postgres PASSWORD postgres
EXTTRAIL ./dirdat/pd
TABLE public."Countries";
TABLE public."Cities";
TABLE public."Parkings";
TABLE public."PaymentData";
TABLE public."ParkingData";
```
and save!

_**NOTE:** Editing uses **vi** editor, you have to press key **i** to edit and press **:wq** keys then **hit enter** for save & quit._

3. To create your extract process issue below commands:

```
add extract exttar, tranlog, begin now

add exttrail ./dirdat/pd, extract exttar
```

![](/files/gg_pg_exttar_2.png)

4. Confirm everything is correct then start this extract by issuing below command:
 
 ```start exttar```

![](/files/gg_pg_exttar_3.png)

After completing this, you should be able to see status of extract with **`info all`** command and result should show you **RUNNING** state.

![](/files/gg_pg_exttar.png)

This process is capturing change data from your source database. As it was mentioned earlier, this is necessary step for continuous replication or zero downtime migration project. 

Because changes are being captured in live and meanwhile at some point during this process you need to do initial load to your target database.
As soon as initial load process finished and you loaded, let’s say your warm data at your target database, you need to start applying captured data whilst you were importing. 

Once you are satisfied with source and target databases data quality, you can do cut over and point you application connections to your target database.

#### EXTDMP

Oracle GoldenGate needs to register the extract with the database replication slot, before adding extract process in Goldengate. 
*Ensure that you are connected to SourceDB using the DBLOGIN command.*

Now changes are being captured from source database and we need to send that to GG microservices, in order to apply at target database. Therefore we need another process, which acts as extract but sends existing trail files to GG microservices.

1. Again, register your extdmp extract:

```register extract extdmp```

![](/files/gg_pg_extdmp_0.png)

2. Then edit extract configuration with **`edit params extdmp`** similar to previous step.

![](/files/gg_pg_extdmp_1.png)

Insert below as your extdmp parameter, but **make sure** you change **ip_address** with your GG Microservice's IP Address!

```
EXTRACT extdmp
RMTHOST ip_address, PORT 9023
RMTTRAIL pd
PASSTHRU
TABLE public."Countries";
TABLE public."Cities";
TABLE public."Parkings";
TABLE public."PaymentData";
TABLE public."ParkingData";
```

_**NOTE**:Editing uses **vi** editor, so you have to press **i** for editing the file, when you are done press **:wq** then **hit enter** for save & quit._

3. To create your extract process issue below commands:

```
add extract extdmp, exttrailsource ./dirdat/pd

add rmttrail pd, extract extdmp, megabytes 50
```


![](/files/gg_pg_extdmp_2.png)

4. Confirm everything is correct then start this extract by issuing below command:
 
 ```start extdmp```


![](/files/gg_pg_extdmp_3.png)

After completing this, you should be able to see status of extract with **`info all`** command and result should show you **RUNNING** state.

![](/files/gg_pg_extdmp.png)

EXTTAR process is capturing your changes at your source database, however it is going nowhere rather than being kept at Goldengate instance.
 
EXTDMP process is then pumping captured trail files to Goldengate Microservices instance. We will check if this is working properly in Lab-4.
These two processes were preparation for change synchronization.

#### INITLOAD

So far, we created 2 extract processes which are now capturing changes and shipping to Goldengate Microservices instance.

However, we are not yet loaded our static data directly from source objects to target database. This specific process is called Initial-load. Steps are similar to the previous extract processes

1. Again register your initload 

```register extract init``` 

![](/files/gg_pg_initload_0.png)

2. To edit initial load configuration, issue below:

```edit params init```

![](/files/gg_pg_initload_1.png)

Insert below as your initial load parameter, but **make sure** you change **ip_address** with your GG Microservice's IP Address!

```
EXTRACT init
SOURCEDB PostgreSQL USERID postgres PASSWORD postgres
RMTHOST ip_address, PORT 9023
RMTFILE il
TABLE public."Countries";
TABLE public."Cities";
TABLE public."Parkings";
TABLE public."PaymentData";
TABLE public."ParkingData";
```

_**NOTE**:Editing uses **vi** editor, so you have to press **i** for editing the file, when you are done press **:wq** then **hit enter** for save & quit._

3. After that add your initial load process:

```
add extract init, sourceistable
```
Extract process extracts a current set of static data directly from the source objects in preparation for an initial load to another database. SOURCEISTABLE type does not use checkpoints. 

![](/files/gg_pg_initload_2.png)

4. Confirm everything is correct then start initial load by issuing below command: 

```start init``` 

![](/files/gg_pg_initload_3.png)

You can see status of this special type of extract process with **`info init`. **

![](/files/gg_pg_initload.png)

Note that number of record is 10000 and status is already STOPPED. Because our sample data has only 5 tables and few records, initial load will take only few seconds.
You can see more information about extract process with:

```
view report init
```

![](/files/gg_pg_initload_report.png)


It is good way to investigate your Goldengate process result. I can see some good statistics at the end of this report

# LAB 4
In this final step of workshop, we will configure replication process in Microservices and apply captured changes from source database to our target Autonomous database. This is final lab.

####	Access to Goldengate Microservices instance

After successful creating extract processes, now it is time to explore your GG Microservices server. Let's make console connection to microservice, copy ip address of OGG_Microservices_Public_ip and connect using:

**`ssh opc@your_microservice_ip_address -i ~/.ssh/oci`**

#### Retrieve Goldengate Microservices’ admin password

Once you are in issue following **`cat ogg-credentials.json`**, and copy credential value from output

![](/files/oggadmin.png)

Good practice is to keep it in your notepad. 

#### Login to Microservices web console

Now, open your web browser and point to https://your_microservices_ip_address. Provide oggadmin in username and credentials, then log in

![](/files/gg_oggadmin.png)

#### Open Target Receiver server

Then click on Target Receiver server's port **9023**, it will redirect you to new tab, provide your credentials again for username **oggadmin**.

![](/files/gg_oggadmin_0.png)

You should be seeing something like this, what it means that your extdmp is pumping some trail files to your Microservices.

![](/files/gg_oggadmin_1.png)

This is something you'd need if you'd want continuous replication and migration. 

#### Open Target Administration server

In this lab scope, we will only migrate to ATP with help of initload. Click on Target Receiver server port **9021**, it will redirect you to new tab, provide your credentials again for username **oggadmin**.

![](/files/micro_oggadmin_0.png)

#### Modify Goldengate credentials

You should be seeing empty Extracts and Replicats dashboard. Let's add some Autonomous Database credentials at first. Open hamburger menu on left top corner, choose **Configuration**

![](/files/micro_ggadmin_0.png)

It will open OGGADMIN Security and you will see we already have a connection to **HOL Target ATP** database. However, you still need to add password here. Click on a pencil icon to alter credentials.

![](/files/micro_ggadmin_1.png)

#### Update password and test connection

Provide password ` GG##lab12345 ` and verify it. This is your ggadmin password, which we provided in lab 3. 
**NOTE: if you specified different password, please use that password**

![](/files/micro_ggadmin_2.png)

After that click on **Log in** database icon.

![](/files/micro_ggadmin_3.png)

#### Add checkpoint table

Scroll to **Checkpoint** part and click on **+** icon, then provide `ggadmin.chkpt` and **SUBMIT**. 

![](/files/micro_ggadmin_4.png)

Checkpoint table contains the data necessary for tracking the progress of the Replicat as it applies transactions to the target system. Regardless of the Replicat that is being used, it is a best practice to enable the checkpoint table for the target system.

Now let's go back to **Overview** page from here.

#### Add replication process

The apply process for replication, also known as Replicat, is very easy and simple to configure. There are five types of Replicats supported by the Oracle GoldenGate Microservices. In overview page, go to Replicat part and click on **+** to create our replicat process.

![](/files/micro_initload_0.png)

We will choose **Nonintegrated Replicat** for initial load, click **Next**. In non-integrated mode, the Replicat process uses standard SQL to apply data directly to the target tables. In our case, number of records in source database is small and we don't need to run in parallel apply, therefore it will suffice.

![](/files/micro_initload_1.png)

#### Modify replication parameters

Provide your name for replicat process, for example **initload**, process name has to be unique and 8 characters long. It is better if you give some meaningful names to identify them later on. 
I choose to name it as **initload**, because this is currently our initial load process.

![](/files/micro_initload_2_1.png)

Then click on **Credentials Domain** drop-down list. There is only one credential at the moment, choose the available option for you.  
In the **Credential Alias**, choose **hol_tp** from drop down, which is our pre-created connection group to target ATP. 

![](/files/micro_initload_2_2.png)

After that go below to find Trail Name and edit to **il**. We defined this in our extract parameter, so it cannot be just a random name.

![](/files/micro_initload_2_3.png)

Also provide **/u02/trails** in "Trail Subdirectory" and choose a **Checkpoint Table** from drop-down list. It is **GGADMIN.CHKPT** in our case.


Review everything then click **Next**


#### Edit parameter file

Microservices has created some draft parameter file for your convenience, let's edit to our need.

![](/files/micro_initload_3_1.png)

Erase existing and paste below configuration 

```
replicat initload
useridalias hol_tp domain OracleGoldenGate
MAP public."Countries", TARGET admin.Countries;
MAP public."Cities", TARGET admin.Cities;
MAP public."Parkings", TARGET admin.Parkings;
MAP public."ParkingData", TARGET admin.ParkingData;
MAP public."PaymentData", TARGET admin.PaymentData;
```

![](/files/micro_initload_3_2.png)


I hope everything is correct until this stage. Click **Create and Run** to start our replicat.


![](/files/micro_initload_4.png)


#### Check INITLOAD status

In overview dashboard, now you should be seeing successful running INITLOAD replication. Click on **Action** button choose **Details**.


![](/files/micro_initload.png)


You can see details of running replicat process. In statistics tab, you'd see some changes right away. Because this is Initial load you will not see any update there, but in continuous replication case we see totally different numbers.

![](/files/micro_initload_5.png)

Congratulations! You have completed this workshop! 

You successfully migrated Postgresql database to Autonomous Database in Oracle Cloud Infrastructure.


## Summary

Here is summary of resources which was created by Terraform script and used in our workshop.

1. [Virtual Cloud Network](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingVCNs.htm)
- Public Subnet, Internet Gateway
- Private Subnet, NAT Gateway, Service gateway

2. [Compute Virtual Machines and Shapes, OS Images](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)
- Source PostgreSQL database instance, 
- Goldengate PostgreSQL instance
- Goldengate Microservices instance

3. [Autonomous Database offerings ](https://docs.oracle.com/en-us/iaas/Content/Database/Concepts/adboverview.htm)
- Target ATP

4. [Oracle Cloud Marketplace](https://docs.oracle.com/en-us/iaas/Content/Marketplace/Concepts/marketoverview.htm)
- Goldengate non-oracle deployment 
- Goldengate Microservices deployment


## Acknowledgements

* **Author** - Bilegt Bat-Ochir, Solution Engineer
* **Contributors** - John Craig, Patrick Agreiter
* **Last Updated By/Date** -
