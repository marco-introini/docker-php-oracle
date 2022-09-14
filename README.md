# Docker with PHP and Oracle Extensions

This package is a demo dockerfile and docker-compose for creating a container based on Apache and PHP 8 with OCI8
extensions installed and enabled.

The container has the SSL enabled and expose itself at the default 443 port.

## Installation

### Certificate creation

Inside the docker directory:

```bash
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
"/C=IT/ST=TESTSERVER/L=TESTSERVER/O=TESTSERVER/CN=TESTSERVER" \
-keyout ./ssl.key -out ./ssl.crt
```

Alternatively you can use your own keyfiles

## Oracle connection

You can connect to Oracle in two ways

### tnsnames.ora

Firstly you can use a TNSNAMES.ORA file and pass the SID to oci_connect, in this way:

```php
$conn = oci_connect($_ENV["ORACLE_USER"], $_ENV["ORACLE_PASSWORD"], $_ENV["ORACLE_SID"]);
```

Please modify `docker/tnsnames.ora`

### Connection string

Alternatively you can pass the full connection string as environment variable in docker-compose.yml

```
- ORACLE_CONNECTION=//oraclehost:1521/myservicename
```

and connect using:

```php
$conn = oci_connect($_ENV["ORACLE_USER"], $_ENV["ORACLE_PASSWORD"], $_ENV["ORACLE_CONNECTION"]);
```

## docker-compose.yml

```
- ORACLE_SID=MYDEMOSID
- ORACLE_USER=MYDEMOUSER
- ORACLE_PASSWORD=MYDEMOPASSWORD
```

## Run

Now you can run the compose file and go to https://localhost/
