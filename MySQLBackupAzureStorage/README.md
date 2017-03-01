Backup MySQL to Azure Storage Account
=================================	

This simple script is useful to database backup from **MySQL** to **Azure Storage Account**

---

Step 1
--

Disable password prompt for mysqldump:

Edit my.cnf and add:

```
[mysqldump]
user=mysqluser
password=secret
```

Step 2: Install Azure-CLI
--

Step 2: 

```
yum install nodejs
npm install azure-cli -g
```

Step 3: Create the script
--
```
vim /home/user/bkpmysql/bkpmysql.sh

#!/bin/sh

mkdir /home/user/bkpmysql/backups
export BACKUP_FILE=/home/user/bkpmysql/backups/db-backup.sql.gz
export DATABASE_SCHEMA_NAME=--all-databases
export AZURE_CONTAINER=YOUR_VALUE_HERE
export AZURE_STORAGE_NAME=YOUR_VALUE_HERE
export AZURE_KEY='YOUR_VALUE_HERE'
export AZURE_BLOB_NAME=db-production-$(date +%Y%m%d%H%M%S).sql.gz

/bin/mysqldump $DATABASE_SCHEMA_NAME > temp.sql
gzip temp.sql
rm -rf $BACKUP_FILE
mv temp.sql.gz $BACKUP_FILE
azure storage blob upload --container $AZURE_CONTAINER -f $BACKUP_FILE -b $AZURE_BLOB_NAME  -a $AZURE_STORAGE_NAME -k $AZURE_KEY
```

Step 4: Step 4: Add execute permissions and add to cron:
--

```
rmartins@lab:~$ chmod 755 /home/user/bkpmysql/bkpmysql.sh

rmartins@lab:~$ (crontab -l ; echo "0 0 * * * /home/user/bkpmysql/bkpmysql.sh") | sort - | uniq - | crontab -
```


