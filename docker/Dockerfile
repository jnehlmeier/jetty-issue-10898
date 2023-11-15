FROM jetty:12.0.3-jdk17-eclipse-temurin

COPY webapp.war /var/lib/jetty/webapps/webapp.war
COPY webapp.mod /var/lib/jetty/modules/webapp.mod
COPY simple-logback-extension.jar /var/lib/jetty/lib/simple-logback-extension.jar
COPY logback-jetty.xml /var/lib/jetty/resources/logback.xml

RUN java -jar $JETTY_HOME/start.jar \
    --add-modules=ee8-deploy,logging-logback,webapp \
    --approve-all-licenses