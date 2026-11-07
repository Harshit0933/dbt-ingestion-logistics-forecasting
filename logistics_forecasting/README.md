# Logistics Demand Forecasting Pipeline

This repository contains the data transformation and orchestration logic for the Logistics Demand Forecasting project. It transforms raw delivery and zonal data into predictive modeling datasets using **dbt**, deployed on **Google BigQuery**, and orchestrated via **Apache Airflow**.

## 🏗 Architecture & Tech Stack

* **Data Warehouse:** Google BigQuery

* **Transformation Engine:** dbt (data build tool) `v1.5+`

* **Orchestration:** Apache Airflow `v2.7.2`

* **Local Development Environment:** Ubuntu (WSL)

### Dual-Environment Strategy

To resolve C++ compilation conflicts with edge-release Python versions, this project utilizes a strict two-environment architecture:

1. `venv/` (Python 3.14): Runs dbt-bigquery and executes SQL models.

2. `airflow-venv/` (Python 3.11): Isolates the Apache Airflow scheduler and webserver.

Airflow bridges this gap by triggering the Python 3.14 dbt executable via the `BashOperator`.

## 🚀 Local Setup Instructions

### 1. Prerequisites

Ensure you have Google Cloud SDK installed and authenticated to your BigQuery project:
`gcloud auth application-default login`

### 2. Configure dbt (Python 3.14)

```
python3 -m venv venv
source venv/bin/activate
pip install dbt-bigquery==1.5.0
dbt deps

```

### 3. Configure Airflow (Python 3.11)

```
python3.11 -m venv airflow-venv
source airflow-venv/bin/activate
pip install "apache-airflow==2.7.2" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.7.2/constraints-3.11.txt"

# Symlink the Git-tracked DAGs to Airflow's home directory
mkdir -p ~/airflow
ln -s $(pwd)/orchestration/dags ~/airflow/dags

# Initialize database and user
airflow db migrate
airflow users create --username admin --firstname Admin --lastname User --role Admin --email admin@example.com --password admin

```

## 📊 Pipeline Logic

### Key Models

* **SCD Type 2 (Snapshots):** Tracks historical changes in logistics zones, safely backdated to `2020` to ensure `not_null` validation tests pass without dropping early historical records.

* **Population Density:** Merges zonal delivery metrics with population density data to enrich the predictive demand models.

### Execution Order

1. `dbt deps`: Resolves package dependencies.

2. `dbt snapshot`: Captures Slowly Changing Dimensions (Type 2).

3. `dbt build`: Runs all seeds, models, and tests in DAG order.

## ⏱️ Orchestration

The pipeline is orchestrated by Airflow via `dag_logistics_forecasting.py`.

* **Schedule:** Monday, Wednesday, and Friday at 02:00 UTC (`0 2 * * 1,3,5`).

* **Path Resolution:** The DAG uses `os.environ.get()` to dynamically locate the dbt project and executable, falling back to local WSL paths for development.

**To run Airflow locally:**

```
source airflow-venv/bin/activate
airflow standalone

```

Navigate to `http://localhost:8080` to monitor task execution.

## 🛡️ Git & CI/CD Workflow

The `main` branch is strictly protected. All data modeling changes (such as the recent `add-SDA-2-on-population` branch) must be introduced via a Pull Request (PR) and pass status checks before merging.