import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.models import Variable

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
    description='Runs the dbt logistics pipeline 3 times a week (Mon, Wed, Fri) followed by AI analysis',
    schedule_interval='0 2 * * 1,3,5',
    start_date=datetime(2026, 11, 1),
    catchup=False,
    tags=['dbt', 'logistics', 'forecasting', 'ai'],
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

    # NEW Step: Save the production state for Slim CI
    dbt_save_state = BashOperator(
        task_id='dbt_save_state',
        bash_command=f"cp {DBT_PROJECT_DIR}/target/manifest.json {DBT_PROJECT_DIR}/prod-state/manifest.json"
    )

    # Step 4: Run the Autonomous AI Analyst
    # Securely fetches the key from Airflow Variables, falling back to a placeholder if not set
    run_ai_analyst = BashOperator(
        task_id='run_ai_demand_analysis',
        bash_command='source /home/harshitn/ai-venv/bin/activate && python /home/harshitn/dbt-logistics-forecasting/orchestration/agents/bq_agent.py',
        env={
            'GROQ_API_KEY': Variable.get("groq_api_key", default_var="paste-your-actual-groq-key-here-if-no-variable"),
            **os.environ 
        }
    )

    # Define execution order
    dbt_deps >> dbt_snapshot >> dbt_build >> dbt_save_state >> run_ai_analyst   