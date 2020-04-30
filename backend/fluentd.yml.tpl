fluentd:
  image: registry.gitlab.com/media-cloud-ai/backbone/fluentd:v1.14.0-debian-1.0
  volumes:
    - ../fluentd/conf:/fluentd/etc
  ports:
    - 24224:24224
    - 24224:24224/udp
  networks:
    - mediacloudai_global

logging:
  driver: fluentd
  options:
    fluentd-address: localhost:24224
    tag: backend.log
