FROM tomcat:7-jre8

RUN mkdir /app
COPY . /app
COPY ./docker/tomcat/run.sh /run.sh

RUN { \
    echo "container.dir = /usr/local/tomcat/webapps"; \
    } > /app/build.properties \
    && chmod +x /run.sh \
    && apt update && apt install -y --no-install-recommends ant openjdk-8-jdk && rm -rf /var/lib/apt/lists/* \
    && cp /usr/local/tomcat/lib/servlet-api.jar /usr/share/ant/lib/ \
    && mkdir -p /data/newsrack/archive && mkdir -p /data/newsrack/users/

EXPOSE 8009

CMD ["/run.sh"]
