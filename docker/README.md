# Usage

Install [docker](https://docker.com) and [docker-compose](https://docs.docker.com/compose/install/). 

# Settings

Create docker-compose.override.yml and put the passwords there.

## Sample docker-compose.override.yml

    version: "2.0"

    services:
      mysql:
        environment:
          - MYSQL_ROOT_PASSWORD=secretpass
          - MYSQL_PASSWORD=supersecret

      tomcat:
        environment:
          - DB_PASSWORD=supersecret

# Run

  $ docker-compose up -d

