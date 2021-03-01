# migrate_to_atp
Hello Folks! Welcome to migrate to autonomous database lab.

In this lab we will migrate a postgresql database to an Autonomous database in Oracle Cloud Infrastructure. We will use Oracle Goldengate for migration steps, and all of our services will be hosted in OCI for this lab purpose. This lab has 2 steps.

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

In step 3, Oracle Goldengate configuration will consist of followings:

- Extract exttab process at Goldengate for non-Oracle database, it is known as change data capture for continuous replication.
- Extract extdmp process at Goldengate for non-Oracle database, it will ship our captured trail files to Microservices for continuous replication.
- Extract initload process at Goldengate for non-Oracle database, it is our first data loader process and inserts to ATP.
- Replicate process at Microservices, it will apply trail files captured by initload process.

![](/files/general.gif)

## Prerequisites 

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

A small confirmation will show after you added an API key. Copy those values and open a notepad to modify them.

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


After you modified above using your parameters/values, now we we will save it to ".bash_profile", to do so go to your terminal and issue:
```
  vi ~/.bash_profile
```

*NOTE: Edit a file uses **vi** editor, if you never used it before here is little instruction. 
When you issue **vi some_file_name** it will either open if that some_file_name exists or create a new file called some_file_name. 
You have to press **i** for editing the file, then if you are done editing press **:wq** keys then hit enter for save & quit.*

![](/files/0.Prep_4.PNG)

then issue following to use variables you added to ".bash_profile" file.
```
  . ~/.bash_profile
```
You've done with prerequisites.

## Step 1


## Step 2

In the beginning of step 2, we need to create our target tables for our GG migration and enable GGADMIN for replication to Autonomous database.

#### Open SQL developer web 

Go to top left hamburger icon, navigate to **Autonomous Transaction Processing** and click on **HOL Target ATP** database.

In **Tools** tab, where you will see **Database Actions**, click on **Open Database Actions**. You may need to enable pop-up your browser if it doesn't open anything.

A new sign-in page opens, enter **ADMIN** in Username, when it asks you to enter password, which is in your Cloud Shell window. Go and copy, then paste here.

![](/files/sql_dev_1.png)

In the **DEVELOPMENT** section, click on **SQL**. When you open the SQL Developer Web for first time, a series of pop-up informational boxes introduce you to the main features. Take a quick look at them. 

#### Create target tables

Let's create our target tables for migration. Please download target table creation script **[from here](./files/CreateTables.sql)**. Make sure to save these with correct extension .sql not txt!

SQL Developer Web opens a worksheet tab, where you execute queries. Drag your downloaded **CreateTables.sql** file and drop in the worksheet area. Then run create statements.

![](/files/sql_dev_2.png)

#### Enable GGADMIN 

Now let's unlock and change the password for the pre-created Oracle GoldenGate user (ggadmin) in Autonomous Database.
Enable GGADMIN by running following query:

```
alter user ggadmin identified by "GG##lab12345" account unlock;
```

![](/files/sql_dev_3.png)

Let's run 
```
alter system set enable_goldengate_replication = true scope=both;
``` 
to enable_goldengate_replicaton, check results.

![](/files/sql_dev_4.png)

We successfully enabled GGADMIN in our target Autonomous Database and created target table structures. Let's proceed to Step 3.


## Step 3 

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

#### Connect to your HOL OGG Postgresql instance

#### Run GGSCI for the first time

Oracle GoldenGate Classic for Non-Oracle (PostgreSQL) allows you to quickly access the GoldenGate Service Command Interface (GGCSI) and is preconfigured with a running Manager process. Copy ip address of OGG_PGSQL_Public_ip and connect using:

`ssh opc@your_ip_address -i ~/.ssh/oci`

After logging in to the compute node, to start GGSCI, execute the following commands separately:

```
export ODBCINI=/home/opc/postgresql/odbc.ini

cd /usr/local/bin/

./ggsci
```

![](/files/gg_pg_config_2.gif)

#### CREATE SUBDIRS

We need to create our work directories in GoldenGate before we start working. Command creates the default directories within the Oracle GoldenGate home directory. 
Once your in GGSCI console, issue **`CREATE SUBDIRS`** command to create your directories.

#### Goldengate Manager

After sub directories, we need to set Goldengate Manager's port, issue **`EDIT PARAMS MGR`** and enter **`PORT 7809`** then save.

_**NOTE:** Editing uses **vi** editor, you have to press key **i** to edit and press **:wq** keys then **hit enter** for save & quit._


Then start goldengate manager process by issueing **`START MGR`** command. You can check if manager status by issueing **`INFO MGR`** command.

![](/files/gg_pg_config_3.gif)
