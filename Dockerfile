ALL M&M APPLICATIO DOCKERFILES
----------------------------------------
# ME01R - JAVA SPRINGBOOT APP
-----------
FROM escoacrprod01.azurecr.io/ubuntu/openjdk:1.8
## This is for local testing
#FROM openjdk:12
#Declare env variables
#ENV ARTIFACT="me01r-rest-sprboot-1.2.12-SNAPSHOT.jar"


# Adding application specific group and user
RUN groupadd -g 1999 me01r-grp && useradd -r -u 1999 -g root me01r

RUN apt-get update && apt-get install -y telnet

# Creating app directory
RUN mkdir /app

RUN mkdir -p /appl/wl_apps/domains/kafka-jks/


# Copying application jar to app directory
#COPY target/${ARTIFACT} /app
#COPY target/me01r-rest-sprboot-1.2.12-SNAPSHOT.jar /app
COPY target/*.jar /app

#COPY start.sh /app

# Changing the user and/or group ownership of an app directory
RUN chown me01r:me01r-grp /app -R

RUN chown me01r:me01r-grp /appl/wl_apps/domains/kafka-jks/ -R

# Exposing the container port
EXPOSE 8080

# Switching user to application user from root
USER me01r

# Running the application jar as an entry point
#ENTRYPOINT ["java", "-Duser.timezone=US/Mountain", "-jar", "/app/me01r-rest-sprboot-1.2.12-SNAPSHOT.jar"]
ENTRYPOINT ["java", "-Xms2048m", "-Xmx2048m", "-XX:+PrintGC", "-XX:+UnlockCommercialFeatures", "-XX:+PrintGCDetails", "-XX:+PrintGCDateStamps", "-XX:MaxMetaspaceSize=512m", "-XX:CompressedClassSpaceSize=128m", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-Djava.awt.headless=true", "-Duser.timezone=US/Mountain", "-da", "-jar", "/app/me01r-rest-sprboot.jar" ]

----------------------------------
# MEUP-ANT - JAVA ANT APP
------------
FROM escoacrprod01.azurecr.io/ubuntu/openjdk:1.8

ENV ARTIFACT="meup-app-0.0.1-SNAPSHOT.jar"

RUN groupadd -g 1999 meup-grp && useradd -r -u 1999 -g root meup
# Creating app and change directory to /app
RUN mkdir -p /home/meup/
RUN mkdir /app
COPY target/*.jar /app

# Granting th eowner and group to app dir
RUN chown meup:meup-grp /app -R 
RUN chown meup:meup-grp /home/meup/ -R
RUN chgrp -R 0 /app && chmod -R g+rwX /app

COPY . /app
EXPOSE 8080
USER meup

ENTRYPOINT ["java", "-Xms2048m", "-Xmx2048m", "-XX:+PrintGC", "-XX:+UnlockCommercialFeatures", "-XX:+PrintGCDetails", "-XX:+PrintGCDateStamps", "-XX:MaxMetaspaceSize=512m", "-XX:CompressedClassSpaceSize=128m", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-Djava.awt.headless=true", "-Duser.timezone=US/Mountain", "-da", "-jar", "/app/meup-app.jar" ]

----------------------------------------
# MEUP-RW - REACT JS APP 
----------------
FROM escoacrprod01.azurecr.io/ubuntu/nodejs:14.x

# Adding application specific group and user
RUN groupadd -g 1999 meup-grp && useradd -r -u 1999 -g root meup
RUN mkdir -p /home/meup/
RUN mkdir /app

# Creating app directory and switching
WORKDIR /app

# Copying package.json to app directory
COPY package.json /app
COPY start.sh /app

# Installing the dependency node modules
#RUN npm install -g npm@latest

# Building the application
#RUN npm run build

# Changing the user and/or group ownership of an app directory
RUN chown meup:meup-grp /app -R
#RUN chown meup:meup-grp /app/ -R
RUN chown meup:meup-grp /home/meup/ -R
RUN chgrp -R 0 /app && chmod -R g+rwX /app

RUN rm -rf /app/server

# Copying application code to app directory
COPY . /app

EXPOSE 7000
EXPOSE 3000

# Switching user to application user from root
USER meup

# Running the application
#CMD [ "npm", "start" ]
ENTRYPOINT ["bash", "/app/start.sh"]

---------------------------------------------------
# MEMIU-WEB - JAVA SPRINGBOOT APP (TAKKING BASE IMAGE ANS JAVA AND INSTALL NODEJS IN IT)
----------------
FROM escoacrprod01.azurecr.io/ubuntu/openjdk:1.8

ENV ARTIFACT="memiu-web-0.0.3-SNAPSHOT.jar"

RUN groupadd -g 1999 memiu-grp && useradd -r -u 1999 -g root memiu
# Creating app and change directory to /app
RUN mkdir -p /home/memiu/
RUN mkdir /app
COPY target/*.jar /app
COPY start.sh /app


# Install app dependencies
COPY msal-server/.npmrc /app/
COPY msal-server/package*.json /app/
# Granting th eowner and group to app dir
RUN chown memiu:memiu-grp /app -R 
RUN chown memiu:memiu-grp /home/memiu/ -R
RUN chgrp -R 0 /app && chmod -R g+rwX /app
RUN rm -f /app/.npmrc

RUN apt-get install -y curl \
&& curl -sL https://deb.nodesource.com/setup_16.x|sed -e 's/https/http/' | bash - \
&& apt-get install -y nodejs \
&& curl -L https://www.npmjs.com/install.sh | sh 
  
COPY . /app
EXPOSE 7000
EXPOSE 8080
USER memiu

#CMD ["sh", "-c", "npm run buildsrv && npm run startsrv"] 
ENTRYPOINT ["bash", "/app/start.sh"]

--------------------------------------------------------------------
# MEMIU-RW - NODEJS APP
---------------------
FROM escoacrprod01.azurecr.io/ubuntu/nodejs:14.x

# Adding application specific group and user
RUN groupadd -g 1999 memiu-grp && useradd -r -u 1999 -g root memiu
RUN mkdir -p /home/memiu/
RUN mkdir /app

# Creating app directory and switching
WORKDIR /app

# Copying package.json to app directory
COPY package.json /app
COPY start.sh /app

# Installing the dependency node modules
#RUN npm install

# Building the application
#RUN npm run build

# Changing the user and/or group ownership of an app directory
RUN chown memiu:memiu-grp /app -R
RUN chown memiu:memiu-grp /app/ -R
RUN chown memiu:memiu-grp /home/memiu/ -R
RUN chgrp -R 0 /app && chmod -R g+rwX /app

RUN rm -rf /app/server

COPY . /app

EXPOSE 7000
EXPOSE 3000

# Switching user to application user from root
USER memiu

# Running the application
#CMD [ "npm", "start" ]
ENTRYPOINT ["bash", "/app/start.sh"]

------------------------------------------------------
# MEMI - JAVA SPRINGBOOT APP
--------------------
# Taking ubuntu as base image for the final image
FROM escoacrprod01.azurecr.io/ubuntu/openjdk:1.8


RUN groupadd -g 1999 memi-grp && useradd -r -u 1999 -g root memi

# Creating and change directory to /app
RUN mkdir /app 

# Copying jar filr from first stage to second stage build
COPY target/*.jar /app

RUN mkdir -p /appl/spool/
RUN mkdir -p /appl/spool/wl_apps/logs/memi/


COPY start.sh /app

# Granting the owner and group to app dir
RUN chown memi:memi-grp /app -R
RUN chown memi:memi-grp /appl/spool/ -R
RUN chown memi:memi-grp /appl/spool/wl_apps/logs/memi/ -R


# Exposing the port
EXPOSE 8080

# Switching the user to menu
USER memi

# Starting the service
#ENTRYPOINT ["java", "-Duser.timezone=US/Mountain", "-jar", "/app/memi-web-2.1.11-SNAPSHOT.jar"]
ENTRYPOINT ["java", "-Xms3072m", "-Xmx3072m", "-XX:+PrintGC", "-XX:+UnlockCommercialFeatures", "-XX:+PrintGCDetails", "-XX:+PrintGCDateStamps", "-XX:MaxMetaspaceSize=512m", "-XX:CompressedClassSpaceSize=128m", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-Djava.awt.headless=true", "-Duser.timezone=US/Mountain", "-da", "-jar", "/app/memi-web-2.1.14-SNAPSHOT.jar" ]

-------------------------------------------------------------
# MEGN - JAVA SPRINGBOOT APP
--------------------------
FROM escoacrprod01.azurecr.io/ubuntu/openjdk:1.8
## This is for local testing
#FROM openjdk:12
#Declare env variables
ENV ARTIFACT="megn-web-mdb.jar"


# Adding application specific group and user
RUN groupadd -g 999 megn-grp && useradd -r -u 999 -g root megn

# Creating app directory
RUN mkdir /app
RUN mkdir -p /logs/


# Copying application jar to app directory
COPY target/${ARTIFACT} /app

COPY start.sh /app
# Changing the user and/or group ownership of an app directory
RUN chown megn:megn-grp /app -R
RUN chown megn:megn-grp /logs/ -R

# Exposing the container port
EXPOSE 8080


# Switching user to application user from root
USER megn

# Running the application jar as an entry point
ENTRYPOINT ["java", "-Xms2048m", "-Xmx2048m", "-XX:+PrintGC", "-XX:+UnlockCommercialFeatures", "-XX:+PrintGCDetails", "-XX:+PrintGCDateStamps", "-XX:MaxMetaspaceSize=512m", "-XX:CompressedClassSpaceSize=128m", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-Djava.awt.headless=true", "-Duser.timezone=US/Mountain", "-da", "-jar", "/app/megn-web-mdb.jar" ]
 #ENTRYPOINT ["bash", "/app/start.sh"]
## This is for local testing
#CMD ["java", "-jar", "/app/${ARTIFACT}"]

-------------------------------------------------------------
# MEPL-ANT - JAVA ANT APP 
-------------------
# Ubuntu Base image with openjdk8 with TomEE
FROM escoacrprod01.azurecr.io/ubuntu/tomee/openjdk8:8.0.x

# Adding application specific group and user
RUN groupadd -g 1999 mepl-grp && useradd -r -u 1999 -g root mepl

COPY server.xml /usr/local/tomee/conf/
COPY setenv.sh /usr/local/tomee/bin/

#COPY server.xml /usr/local/tomee/conf/
# Copying application jar to app directory
COPY presentation/target/*.war /usr/local/tomee/webapps

# Changing the user and/or group ownership of an app directory
RUN mkdir -p /home/mepl/appl/spool/mepl/files/d25/
RUN chown mepl:mepl-grp /home/mepl/appl/spool/mepl/files/d25/ -R
RUN chown mepl:mepl-grp /usr/local/tomee/ -R
RUN chown mepl:mepl-grp /usr/local/tomee/logs/ -R

# Exposing the container port
EXPOSE 8080

# Switching user to application user from root
USER mepl

# Running the application jar as an entry point
CMD /usr/local/tomee/bin/catalina.sh run
