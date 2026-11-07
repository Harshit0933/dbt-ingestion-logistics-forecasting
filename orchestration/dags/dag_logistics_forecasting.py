import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

# Read from environment variables if they exist; otherwise, fall back to your local WSL paths
DBT_PROJECT_DIR = os.environ.get(
    "DBT_PROJECT_DIR", 
    "/home/harshitn/dbt-logistics-forecasting/logistics_forecasting"
)
DBT_EXEC = os.environ.get(
    "DBT_EXEC", 
    "/home/harshitn/dbt-logistics-forecasting/venv/bin/dbt"
)
PROFILES_DIR = "."
default_args = {
    'owner': 'data_engineering',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='dbt_logistics_forecasting_pipeline',
    default_args=default_args,
    description='Runs the dbt logistics pipeline 3 times a week (Mon, Wed, Fri)',
    schedule_interval='0 2 * * 1,3,5',
    start_date=datetime(2026, 11, 1),
    catchup=False,
    tags=['dbt', 'logistics', 'forecasting'],
) as dag:

    # Step 1: Install dbt dependencies
    dbt_deps = BashOperator(
        task_id='dbt_deps',
        bash_command=f"cd {DBT_PROJECT_DIR} && {DBT_EXEC} deps"
    )

    # Step 2: Run SCD Type 2 snapshots
    dbt_snapshot = BashOperator(
        task_id='dbt_snapshot',
        bash_command=f"cd {DBT_PROJECT_DIR} && {DBT_EXEC} snapshot --profiles-dir {PROFILES_DIR}"
    )

    # Step 3: Build models and run tests
    dbt_build = BashOperator(
        task_id='dbt_build',
        bash_command=f"cd {DBT_PROJECT_DIR} && {DBT_EXEC} build --profiles-dir {PROFILES_DIR}"
    )

    # Define execution order
    dbt_deps >> dbt_snapshot >> dbt_build
