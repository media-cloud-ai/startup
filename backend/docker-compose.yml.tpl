---

version: "3.6"

services:
  workflows:
    image: ${WORKFLOWS_IMAGE}:${WORKFLOWS_VERSION}
    volumes:
      - ../workflows:/workflows-volume
    command: "cp -R /workflows/. /workflows-volume"

  backend:
    image: ${BACKEND_IMAGE}:${BACKEND_VERSION}
    volumes:
      - ../workflows:/workflows
    ports:
      - ${BACKEND_PORT}:80
    environment:
      APP_LABEL: "${APP_LABEL}"
      APP_LOGO: "${APP_LOGO}"
      APP_COMPANY_LOGO: "${APP_COMPANY_LOGO}"
      APP_COMPANY: "${APP_COMPANY}"
      APP_IDENTIFIER: "${APP_IDENTIFIER}"
      TZ: "${APP_TZ}"

      PORT: 80
      SSL: "${BACKEND_SSL}"

      SENDGRID_API_KEY: "${SENDGRID_API_KEY}"

      DATABASE_NAME: "${DATABASE_NAME}"
      DATABASE_PORT: "${DATABASE_PORT}"
      DATABASE_PASSWORD: "${DATABASE_PASSWORD}"
      DATABASE_USERNAME: "${DATABASE_USERNAME}"
      DATABASE_HOSTNAME: "${DATABASE_HOSTNAME}"

      AMQP_HOSTNAME: "${AMQP_HOSTNAME}"
      AMQP_PORT: "${AMQP_PORT}"
      AMQP_MANAGEMENT_PORT: "${AMQP_MANAGEMENT_PORT}"
      AMQP_USERNAME: "${AMQP_USERNAME}"
      AMQP_PASSWORD: "${AMQP_PASSWORD}"
      AMQP_VIRTUAL_HOST: "${AMQP_VIRTUAL_HOST}"

      WORKERS_WORK_DIRECTORY: "/data"
      # The variable below (WORK_DIR) is deprecated but it still here to stay
      # compliant with olders releases.
      WORK_DIR: "/data"
      ROOT_DASH_CONTENT: "/dash"

      ROOT_EMAIL: "${ROOT_EMAIL}"
      ROOT_PASSWORD: "${ROOT_PASSWORD}"
      HOSTNAME: "${APP_DNS}"
      EXPOSED_DOMAIN_NAME: "${EXPOSED_DOMAIN_NAME}"

      STEP_FLOW_WORKFLOW_DIRECTORY: "/workflows"
      VIDEO_FACTORY_ENDPOINT: "${VIDEO_FACTORY_ENDPOINT}"
      VOD_ENDPOINT: "${VOD_ENDPOINT}"

      S3_URL: "${S3_ENDPOINT}"
      S3_ACCESS_KEY: "${S3_ACCESS_KEY}"
      S3_SECRET_KEY: "${S3_SECRET_KEY}"
      S3_REGION: "${S3_REGION}"
      S3_BUCKET: "${S3_BUCKET}"

      TEAMS_CHANNEL_URL: "${TEAMS_CHANNEL_URL}"

    networks:
      - mediacloudai_global
      - backend
    depends_on:
      - database

  database:
    image: ${POSTGRES_IMAGE}:${POSTGRES_VERSION}
    environment:
      POSTGRES_USER: "${DATABASE_USERNAME}"
      POSTGRES_PASSWORD: "${DATABASE_PASSWORD}"
      POSTGRES_DB: "${DATABASE_NAME}"
    labels:
      - "traefik.enable=false"
    networks:
      - mediacloudai_global
      - backend

volumes:
  workflows:

networks:
  backend:
    driver: bridge
  mediacloudai_global:
    external: true

...
