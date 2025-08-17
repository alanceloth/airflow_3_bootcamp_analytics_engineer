FROM astrocrpublic.azurecr.io/runtime:3.0-7

COPY --chown=astro:0 dags/ /usr/local/airflow/dags/
COPY --chown=astro:0 plugins/ /usr/local/airflow/plugins/
COPY --chown=astro:0 include/ /usr/local/airflow/include/

USER root
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown astro:0 /entrypoint.sh

EXPOSE 8080
USER astro
ENTRYPOINT ["/entrypoint.sh"]