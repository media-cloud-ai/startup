---

worker:
  environment:
      AMQP_HOSTNAME: "${AMQP_HOSTNAME}"
      AMQP_PORT: "${AMQP_PORT}"
      AMQP_MANAGEMENT_PORT: "${AMQP_MANAGEMENT_PORT}"
      AMQP_USERNAME: "${AMQP_USERNAME}"
      AMQP_PASSWORD: "${AMQP_PASSWORD}"
      AMQP_VIRTUAL_HOST: "${AMQP_VIRTUAL_HOST}"
      AMQP_VHOST: "${AMQP_VHOST}"
      AMQP_TLS: "${AMQP_TLS}"
  networks:
      - mediacloudai_global
      - workers

...
