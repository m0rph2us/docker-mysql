# Usage

You need to install https://docs.docker.com/engine/install/ first.

Then you can run docker with the command as belows. 
Also, You can run with daemon mode if you add `-d` option at the end.

```
docker-compose up
```

For stopping docker, the command is: 

```
docker-compose down
```

# Structure

This MySQL container is structured as master-slave structure. Wait, What is master-slave structure? 
Ok, This is the answer for you https://dev.mysql.com/doc/refman/8.0/en/replication.html.

In the file `docker-compose.yml`:

```yaml
version: '3'
services:
  mysql-master:
    image: mysql:5.7.22
    volumes:
      - ./conf/master:/etc/mysql/conf.d
      - ./init/mysql/master:/init-mysql
      - ./init/db:/init-db
      - ./init/seeding.sh:/docker-entrypoint-initdb.d/seeding.sh
      #- ./volume/mysql-slave:/var/lib/mysql
    environment:
      #- TZ=Asia/Seoul
      - MYSQL_ROOT_PASSWORD=1234
    ports:
      - '33060:3306'

  mysql-slave:
    image: mysql:5.7.22
    volumes:
      - ./conf/slave:/etc/mysql/conf.d
      - ./init/mysql/slave:/init-mysql
      - ./init/db:/init-db
      - ./init/seeding.sh:/docker-entrypoint-initdb.d/seeding.sh
      #- ./volume/mysql-slave:/var/lib/mysql
    depends_on:
      - mysql-master
    environment:
      #- TZ=Asia/Seoul
      - MYSQL_ROOT_PASSWORD=1234
    ports:
      - '33070:3306'
```

Change the image if you want to use other version of MySQL. And Change or uncomment TZ environment value if you need.

Uncomment lines which has `/var/lib/mysql` when you need persistence.

It has several volume mount. Each directory contains:

* conf
    * mysql server configuration for master and slave
* init
    * init sql script for master and slave
    * init sql script for each db(in this case `sample`)
* tool
    * tools for mysql or something
    
As you can see, master port is `33060` and slave port is `33070`.

# Seeding

In the file `seeding.sh`:

```shell script
#!/bin/bash

set -e

mysql_sqls=(
    "init.sql"
    )

db_sqls=(
    "sample/init.sql"
    "sample/init-data.sql"
     )

sqlExecute() {
	path=$1
	shift
	sqls=("${@}")

	for file in "${sqls[@]}"
	do
		echo "- import: /$path/$file"
		mysql --default-character-set=utf8 -uroot -p${MYSQL_ROOT_PASSWORD} < "/$path/$file"
	done
}

sqlExecute "init-mysql" "${mysql_sqls[@]}"
sqlExecute "init-db" "${db_sqls[@]}"
```

You can see what's going on here. `mysql_sqls` for mysql initialization. 
`db_sqls` for database initialization. 
Just add directories and files under the init/db directory if you need to add another database. 
And then add paths to the `db_sqls` array.
    
End of document. Have fun!