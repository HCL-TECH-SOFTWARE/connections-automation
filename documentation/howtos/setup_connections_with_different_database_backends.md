# Using different database backends with HCL Connections' automation

Automated and tested database backends by HCL are IBM DB2 11.1, Oracle 19c and Microsoft SQL Server 2019. Please note that automated and tested only implies that it is covered by this automation, and does not mean it is (not) officially supported by HCL.

## What did we change?

The only real change, beside supporting multiple database, is introducing the variables needed to install JDBC drivers on for that specified locations.

Those variables are called:

```
[was_servers:vars]
#setup_db2_jdbc=false
#setup_oracle_jdbc=false
#setup_mssql_jdbc=false
```

By default, they are set to false, which means that if you don specifically say that you want JDBC drivers installed, they will not be installed.

This applies only for HCL Connections.

## Defaults and IBM DB2 11.1

First supported database with this automation was IBM DB2 v11.1.

To install Connections by using DB2 as a backend, all you need is this:

```
# The server where DB2 is going to be installed and configured
[db2_servers]
db1.internal.example.com

# Installing DB2 JDBC drivers to WAS nodes. By default it is set to false.
[was_servers:vars]
setup_db2_jdbc=True

[all:vars]

# The location from which DB2 installation archive is going to be downloaded
db2_download_location=http://installer1.internal.example.com:8001/DB2

# This is used by WebSphere, Connections and TDI.
db_username=LCUSER
db_password=password
db_hostname=db1.internal.example.com
db_port=50000
db_jdbc_file=/opt/IBM/db2/V11.1/java
db_type=DB2
```

HCL Connections installer will use this set of parameters when setting up HCL Connections installation:

```
activities_db={ 'server': 'db1.internal.example.com' }
blogs_db={ 'server': 'db1.internal.example.com' }
dogear_db={ 'server': 'db1.internal.example.com' }
communities_db={ 'server': 'db1.internal.example.com' }
files_db={ 'server': 'db1.internal.example.com' }
forums_db={ 'server': 'db1.internal.example.com' }
homepage_db={ 'server': 'db1.internal.example.com' }
metrics_db={ 'server': 'db1.internal.example.com' }
mobile_db={ 'server': 'db1.internal.example.com' }
profiles_db={ 'server': 'db1.internal.example.com' }
push_db={ 'server': 'db1.internal.example.com' }
wikis_db={ 'server': 'db1.internal.example.com' }
icec_db={ 'server': 'db1.internal.example.com' }
ic360_db={ 'server': 'db1.internal.example.com' }
```

By default, it is only taking as a parameter the server where DB2 is installed. This means that other parameters that can also be configured, as you will see in the next example, are omitted because defaults are taken, and defaults already point to what IBM DB2 expects it to be.

### Under the hood

With the latest changes, what actually happens is:
- On the DB2 server, Ansible will configure swap which is requirement for paging by IBM.
- DB2 will be installed from the installer specified in db2_download_location variable.
- Because setup_db2_jdbc=True, on all WAS nodes DB2 JDBC drivers will be also set up.
- Connections Wizards will check inventory file, and decide what to do based on what they find. In this case, they will find group db2_servers, and decide based on that to run DB2 related migrations.
- TDI will use db_username, db_password, db_hostname, db_port to configure itself to successfully run.
- HCL Connections response file will be populated based on *_db structures.

## Using Oracle 19c as a database backend for HCL Connections 7

If you want to try HCL Connections with Oracle 19c, now that is possible as well.

The main difference here is that:

- You will not have the group db2_servers but oracle_servers
- You will not have db2_download_location but oracle_download_location
- You will have to tell it to install Oracle JDBC drivers on WAS nodes
- You will have to update your connections parameters like paths, ports, and users
- You will have to update your configuration parameters that are going to be passed to response file for HCL Connections installation. Remember, if you don't do it, by default it is assuming it is IBM DB2.

In the end, in your inventory file, you will have something like this:

```
[oracle_servers]
db1.internal.example.com

[was_servers:vars]
setup_oracle_jdbc=True

[all:vars]

# Download location of Oracle
oracle_download_location=http://installer1.internal.example.com:8001/Oracle

# This is used by WebSphere, Connections and TDI.
db_username=EMPINST
db_password=password
db_hostname=db1.internal.example.com
db_port=1521
db_jdbc_file=/opt/oracle/product/19.0.0/db_1/jdbc/lib
db_type=Oracle

activities_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'OAUSER' }
blogs_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'BLOGSUSER' }
dogear_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'DOGEARUSER' }
communities_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'SNCOMMUSER' }
files_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'FILESUSER' }
forums_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'DFUSER' }
homepage_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'HOMEPAGEUSER' }
metrics_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'METRICSUSER' }
mobile_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'MOBILEUSER' }
profiles_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'PROFUSER' }
push_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'PNSUSER' }
wikis_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'WIKISUSER' }
icec_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'XCC' }
ic360_db={ 'name': 'LSCONN', 'server': 'db1.internal.example.com', 'user': 'ESSUSER' }
```

### Under the hood

- Ansible will set up swap in the size of the amount of RAM on the node which will host Oracle 19c. This is actually prerequisite for installing Oracle 19c successfully (no, scripts are not ignoring prerequisite checks).
- Ansible will download Oracle 19c installer from oracle_download_location and install it on the server mentioned in oracle_servers group.
- Because setup_oracle_jdbc=True, it will also download drivers for Oracle 19c from oracle_download_location and put them to WAS servers at the location of db_jdbc_file variable.
- Connections Wizards, because this time they will file oracle_servers group name in the inventory, will decide to execute Oracle migrations using the specified db_username, db_password, db_hostname and db_port.
- IBM TDI will find oracle_servers group name in the inventory, and because of that decide to download Oracle 19c JDBC driver from oracle_download_location necessary to successfully execute TDI scripts.
- All variables with *_db will be added to the response file for HCL Connections installer.

## Using Microsoft SQL Server 2019 as a database backend for HCL Connections 7

This was, obviously, implemented and tested on Linux (CentOS 7.9 to be more specific).

It follows the same logic that DB2 and Oracle are following, but note that in case of MSSQL you need to use strong password, otherwise it will simply not work:

```
[mssql_servers]
db1.internal.example.com

[mssql_servers:vars]
db_password="Pa55w0rd"

[was_servers:vars]
setup_mssql_jdbc=True

[all:vars]

# Download location of MSSQL drivers
mssql_download_location=http://installer1.internal.example.com:8001/MSSQL

db_username=LCUSER
db_password=Pa55w0rd
db_hostname=c7cl7db1.internal.cnx-dev.net
db_port=1433
db_jdbc_file=/opt/mssql/jdbc/lib/sqljdbc_6.0/enu/jre8
db_type="SQL Server"

activities_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
blogs_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
dogear_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
communities_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
files_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
forums_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
homepage_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
metrics_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
mobile_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
profiles_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
push_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
wikis_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
icec_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
ic360_db={ 'server': 'c7cl7db1.internal.cnx-dev.net' }
```

### Under the hood

- Ansible will install MSSQL 2019 on mssql_servers from official Microsoft yum repository.
- Because setup_mssql_jdbc=True, it will download JDBC drivers from mssql_download_location and install it on WAS nodes.
- Connections Wizards will decide to run MSSQL migrations because of finding mssql_servers in group names.
- TDI will use db_username, db_password, db_hostname, db_port to configure itself, and because of finding mssql_servers in the group names, it will download MSSQL drivers from mssql_download_location.
- The response file for HCL Connections will be filled with the structures from *_db variables. Note that names here are actually matching the names we use for IBM DB2, so defaults applies.

## Frequently asked questions

### What if I specify all database types?

In that case, Ansible will attempt to install everything you specified. Which doesn't mean it will necesarily work based on eventual port clashes and resource issues.

### Can I simply install all JDBC drivers?

Yes you can, you can switch all three variables to true. But in the end of the day, Connections itself will use only the one passed to the installer in db_jdbc_file.

### And if I forgot to install JDBC drivers?

Just enable it and run playbooks/third-party/setup-database.yml again.

### But what is playbooks/third-party/setup-database.yml?

It's just a playbook which is calling the playbooks for DB2, Oracle and MSSQL 2019. It will run based on what database(s) are specified in the inventory file: if it finds [db2_servers] it will run playbookd/third-party/setup-db2.yml.
