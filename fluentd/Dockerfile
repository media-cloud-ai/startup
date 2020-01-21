# fluentd/Dockerfile
FROM fluent/fluentd:v1.6-debian-1
USER root
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-document", "--version", "3.5.2"]
RUN ["gem", "install", "fluent-plugin-concat", "--no-document", "--version", "2.4.0"]
USER fluent
