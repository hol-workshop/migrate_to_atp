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

- Get your Oracle cloud account first!

If you don't have an OCI account, you can sign up for a free trial [here](). 

- Let's prepare our work directory. 

We will use something called Cloud Shell in OCI web console, which is simple and sophisticated cloud terminal for the most of your need. It is located right top corner of OCI web console

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
When you issue **vi some_file_name** it will either open if that some_file_name exists or create a new file called some_file_name. 
You have to press **i** to enable editing, then "shift+insert" to paste. If you are done editing press **:wq** keys then hit enter for save & quit.*

![](/files/0.Prep_4.PNG)


Now, once you've set these values close cloud-shell terminal by clicking on exit "X" button. Then again open cloud-shell terminal.


![](/files/0.Prep_0.PNG)

You've done with prerequisites.

# Step 1
Okay, let's begin our lab. First we'll make a copy of lab repository.

```
git clone https://github.com/hol-workshop/migrate_to_atp.git

cd migrate_to_atp
```

![](/files/1.Git.PNG)

Now we need to create a file to help terraform understanding your environment. Let's modify following parameters in your notepad and copy it to clipboard.

```
tenancy_ocid  = "your_tenancy_value_here"
ssh_public_key  = "~/.ssh/oci.pub"
region = "your-region-value here"
compartment_ocid = "your-tenancy-value_here"
```

Enter below command in your current working migrate_to_atp directory:

**`vi terraform.tfvars`**

This will create a new file, *You have to press **i** to enable editing, then "shift+insert" to paste copied parameter. When you are done editing press **:wq** keys then hit enter for save & quit.*

Good practice is, always keep it in your notepad.

### Terraform

Now, time to play terraform. Plan and apply steps shouldn't ask any input from you. if it asks you to provide such as compartment_ocid, then again check previous files.

```
terraform init

terraform plan

terraform apply --auto-approve
``` 
Make a copy of your output results.

![](/files/1.git_1.PNG)

# Step 2

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

Let's create our target tables for migration. Please download target table creation script **[from here](./files/CreateTables.sql)**.  Open this file link and choose **RAW** then save it as CreateTables.sql file. Make sure to save these with correct extension .sql not txt!

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

We successfully enabled GGADMIN in our target Autonomous Database and created target table structures. Let's proceed to Step 3.


# Step 3 

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
You can exit from this instance, and proceed next steps.


#### Connect to your HOL OGG Postgresql instance

Oracle GoldenGate Classic for Non-Oracle (PostgreSQL) allows you to quickly access the GoldenGate Service Command Interface (GGCSI) and is preconfigured with a running Manager process. Copy ip address of OGG_PGSQL_Public_ip and connect using:

**`ssh opc@your_ogg_pgsql_ip_address -i ~/.ssh/oci`**

#### Run GGSCI for the first time

After logging in to the compute node, to start GGSCI, execute the following commands separately:

```
export ODBCINI=/home/opc/postgresql/odbc.ini

cd /usr/local/bin/

./ggsci
```

![](/files/gg_pg_config_2.gif)

#### Create Work directories 

We need to create our work directories in GoldenGate before we start working. Command creates the default directories within the Oracle GoldenGate home directory. 
Once your in GGSCI console, issue **`CREATE SUBDIRS`** command to create your directories.

#### Start Goldengate Manager

After creating sub directories, we need to set Goldengate Manager's port, issue **`EDIT PARAMS MGR`** and enter **`PORT 7809`** then save.

_**NOTE:** Editing uses **vi** editor, you have to press key **i** to edit and press **:wq** keys then **hit enter** for save & quit._


Then start goldengate manager process by issueing **`START MGR`** command. You can check if manager status by issueing **`INFO MGR`** command.

![](/files/gg_pg_config_3.gif)

#### Connect to Source PostgreSQL

Run the following command to log into the database:

**```DBLOGIN sourcedb PostgreSQL USERID postgres PASSWORD postgres```**

You should be able to see below information saying *Successfully Logged into database*

![](/files/gg_pg_dblogin.png)

Now you are logged into database in GGSCI console, which means you are ready to proceed. We will create three extract processes and we have five tables in source database.

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

Let's begin to create the first extract process, which is continuous replication in usual migration and replication project scenario.

First register your extract **`register extract exttar`**. 
Then edit extract configuration with **`edit params exttar`**. 

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

After that add your extract using below commands:

```
add extract exttar, tranlog, begin now

add exttrail ./dirdat/pd, extract exttar
```

Confirm everything is correct then start this extract by issueing **`start exttar`** command.

![](/files/gg_pg_exttar.png)

After completing this, you should be able to see status of extract with **`info all`** command and result should show you **RUNNING** state.

This process is capturing change data from your source database. As I said earlier this is necessary step for usual migration and replication project. Because changes are being captured in live and some point during this process, you need do initial load to your target database.

#### EXTDMP

Now changes are being captured from source database and we need to send that to GG microservices, in order to apply at target database. Therefore we need another process, which acts as extract but sends existing trail files to GG microservices.

Again, register your extdmp extract **`register extract extdmp`**
Then edit extract configuration with **`edit params extdmp`** similar to previous step.

Insert below as your extdmp parameter, but **make sure** you change ip_address with your GG Microservice's IP Address!

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

After that add your extract using below commands

```
add extract extdmp, exttrailsource ./dirdat/pd

add rmttrail pd, extract extdmp, megabytes 50
```

Confirm everything is correct then start this extract by issueing **`start extdmp`** command, similar to previous step.

![](/files/gg_pg_extdmp.png)

#### INITLOAD

Now database changes are being transferred to GG Microservices, it is time to do our initial load... explanation

Again register your initload **`register extract init`** 
Then edit extract configuration with **`edit params init`** similar to previous steps.


Insert below as your initial load parameter, but **make sure** you change ip_address with your GG Microservice's IP Address!

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
After that add your initial load process:

```
add extract init, sourceistable
```

Confirm everything is correct then start this extract by issueing **`start init`** command. You can see status of this special type of extract process with **`info init`. **

![](/files/gg_pg_initload.png)


You can see more information about extract process with **`view report init`**, it is good way to investigate your goldengate process result. I can see some good statistics at the end of this report

![](/files/gg_pg_initload_report.png)

# Step 4
After successful creating extract processes, now it is time to explore your GG Microservices server. 
Let's make console connection to microservice, copy ip address of OGG_Microservices_Public_ip and connect using:

**`ssh opc@your_microservice_ip_address -i ~/.ssh/oci`**

![](/files/oggadmin.png)

Once you are in issue following **`cat ogg-credentials.json`**, and copy credential value from output. Good practice is keep it in your notepad.
Now, open your web browser and point to `https://your_microservices_ip_address`. Provide **oggadmin** in username and credentials, then log in.

![](/files/gg_oggadmin.png)

Then click on Target Receiver server's port **9023**, it will redirect you to new tab, provide your credentials again for username **oggadmin**.

![](/files/gg_oggadmin_0.png)

You should be seeing something like this, what it means that your extdmp is pumping some trail files to your Microservices.

![](/files/gg_oggadmin_1.png)

This is something you'd need if you'd want continuous replication and migration. 

However in this lab scope, we will only migrate to ATP with help of initload. Click on Target Receiver server port **9021**, it will redirect you to new tab, provide your credentials again for username **oggadmin**.

![](/files/micro_oggadmin_0.png)

#### Add Credentials

You should be seeing empty Extracts and Replicats dashboard. Let's add some Autonomous Database credentials at first. Open hamburger menu on left top corner, choose **Configuration**

![](/files/micro_ggadmin_0.png)

It will open OGGADMIN Security and you will see we already have a connection to **HOL Target ATP** database. However, you still need to add password here. Click on a pencil icon to alter credentials.


![](/files/micro_ggadmin_1.png)

Provide password ` GG##lab12345 ` and verify it. This is your ggadmin password, which we provided in lab 3. **NOTE: if you specified different password, please use that password**

![](/files/micro_ggadmin_2.png)

After that click on **Log in** database icon.

![](/files/micro_ggadmin_3.png)

Scroll to **Checkpoint** part and click on **+** icon, then provide `ggadmin.chkpt` and **SUBMIT**. Checkpoint tables contain the data necessary for tracking the progress of the Replicat as it applies transactions to the target system. Regardless of the Replicat that is being used, it is a best practice to enable the checkpoint table for the target system.

![](/files/micro_ggadmin_4.png)


Now let's go back to **Overview** page from here.

#### Add Replicat

The apply process for replication, also known as Replicat, is very easy and simple to configure. There are five types of Replicats supported by the Oracle GoldenGate Microservices. In overview page, go to Replicat part and click on **+** to create our replicat process.


![](/files/micro_initload_0.png)


We will choose **Nonintegrated Replicat** for initial load, click **Next**. In non-integrated mode, the Replicat process uses standard SQL to apply data directly to the target tables. In our case, number of records in source database is small and we don't need to run in parallel apply, therefore it will suffice.


![](/files/micro_initload_1.png)


Provide your name for replicat process then click on **Credentials Domain** drop-down list. There is only one at the moment, choose available option for you then **Credential Alias** would be your **hol_tp**, which is our pre-created connection group to ATP. After that go below to find **Trail Name** and edit to **il**. We defined this in our initload parameter, so it cannot be just random name. Also provide **Trail Subdirectory** as **/u02/trails** and choose **Checkpoint Table** from drop-down list.

Review everything then click **Next**


![](/files/micro_initload_2.png)


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


In overview dashboard, now you should be seeing successful running INITLOAD replication. Click on **Action** button choose **Details**.


![](/files/micro_initload.png)


You can see details of running replicat process. In statistics tab, you'd see some changes right away. Because this is Initial load you will not see any update there, but in continuous replication case we see totally different numbers.

![](/files/micro_initload_5.png)

That was it, you successfully migrated Postgresql database to Autonomous Database in Oracle Cloud Infrastructure!

