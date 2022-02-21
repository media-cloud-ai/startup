# fluentd/Dockerfile
FROM fluent/fluentd:v1.14.0-debian-1.0
USER root
RUN ["gem", "install", "elasticsearch", "--no-document", "--version", "7.5.0"]
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-document", "--version", "3.8.0"]
RUN ["gem", "install", "fluent-plugin-concat", "--no-document", "--version", "2.4.0"]
USER fluent
