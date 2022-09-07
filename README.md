# Docker with PHP and Oracle Extensions

This package is a demo dockerfile and docker-compose for creating a container based on Apache and PHP 8 with OCI8
extensions installed and enabled.

## Installation

### Certificate creation

Inside the docker directory:

```
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
"/C=IT/ST=TESTSERVER/L=TESTSERVER/O=TESTSERVER/CN=TESTSERVER" \
-keyout ./ssl.key -out ./ssl.crt
```

Alternatively you can use your own keyfiles

## Oracle connection: tnsnames.ora

Please modify `docker/tnsnames.ora`

## docker-compose.yml

```
- ORACLE_SID=MYDEMOSID
- ORACLE_USER=MYDEMOUSER
- ORACLE_PASSWORD=MYDEMOPASSWORD
```

## Run

Now you can run the compose file and go to https://localhost/
