#!/bin/sh

rm -rf /usr/local/tomcat/webapps/ROOT

cd /app

{ \
    echo "sql.dbUrl = jdbc:mysql://mysql"; \
    echo "sql.dbName = $DB_NAME"; \
    echo "sql.user = $DB_USER"; \
    echo "sql.password = $DB_PASSWORD"; \
} > /app/resources/newsrack.properties.override \

ant deploy

cd $CATALINA_HOME

catalina.sh run
