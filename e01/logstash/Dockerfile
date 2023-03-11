ARG ELASTIC_VERSION

# https://www.docker.elastic.co/
FROM docker.elastic.co/logstash/logstash:${ELASTIC_VERSION}
ADD --chown=1000:1000 https://jdbc.postgresql.org/download/postgresql-42.5.4.jar /usr/share/logstash/logstash-core/lib/jars/postgresql-jdbc.jar
