from airflow.models import Variable
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import BigQueryProfileMapping
import os
from pendulum import datetime

profile_config_dev = ProfileConfig(
    profile_name="bootcamp_dw",
    target_name="dev",
    profile_mapping=BigQueryProfileMapping(
        conn_id="bigquery_db",
        profile_args={"project": "jornada-de-dados"},
    ),
)
profile_config_prod = ProfileConfig(
    profile_name="bootcamp_dw",
    target_name="prod",
    profile_mapping=BigQueryProfileMapping(
        conn_id="bigquery_db",
        profile_args={"project": "jornada-de-dados"},
    ),
)

dbt_env = Variable.get("dbt_env", default_var="dev").lower()
if dbt_env not in ("dev", "prod"):
    raise ValueError(f"dbt_env inválido: {dbt_env!r}, use 'dev' ou 'prod'")

profile_config = profile_config_dev if dbt_env == "dev" else profile_config_prod

my_cosmos_dag = DbtDag(
    project_config=ProjectConfig(
        dbt_project_path="/usr/local/airflow/dbt/bootcamp_dw",
        project_name="bootcamp_dw",
    ),
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt",
    ),
    operator_args={
        "install_deps": True,
        "target": profile_config.target_name,
    },
    schedule="@daily",
    start_date=datetime(2025, 8, 24),
    catchup=False,
    dag_id=f"dag_bootcamp_dw_{dbt_env}",
    default_args={"owner": "Alan Lanceloth", "retries": 2},
)