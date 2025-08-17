FROM astrocrpublic.azurecr.io/runtime:3.0-7

COPY dags/ /usr/local/airflow/dags/
COPY plugins/ /usr/local/airflow/plugins/
COPY include/ /usr/local/airflow/include/

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
USER root
# ajuste de permissões se necessário…
USER airflow
ENTRYPOINT ["/entrypoint.sh"]