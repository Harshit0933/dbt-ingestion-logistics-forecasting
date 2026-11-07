# Logistics Demand Forecasting

Welcome to the Logistics Demand Forecasting repository. This project manages the automated data pipelines required to analyze historical delivery trends and predict future logistics demand.

## 🎯 Project Overview

Accurate forecasting requires reliable data. This pipeline processes daily delivery metrics, tracks historical changes in logistics zones, and merges them with external datasets like population density. The resulting data is stored cleanly in Google BigQuery, ready for our machine learning models and BI dashboards.

## 📂 Repository Structure

* **`/logistics_forecasting/`** - The core dbt project. This folder contains all of our SQL transformations, tests, seeds, and snapshot logic.
* **`/orchestration/dags/`** - Our scheduling code. Contains the Apache Airflow DAGs that automate our pipeline runs.

## ⚙️ How It Works

* **Data Warehouse:** Google BigQuery
* **Transformations:** dbt (Data Build Tool)
* **Schedule:** The pipeline runs automatically 3 times a week (Monday, Wednesday, Friday) via Apache Airflow.

## 🚀 Quick Start for Developers

1. Ensure you have the Google Cloud SDK installed and authenticated.
2. Set up a Python 3.14 virtual environment for dbt.
3. Set up a separate Python 3.11 virtual environment for Apache Airflow.
4. Run `dbt deps`, `dbt snapshot`, and `dbt build` to execute the pipeline manually.

*(Note: For the full step-by-step local setup guide and architecture details, please refer to our internal engineering wiki or technical documentation.)*

## 🤝 Contributing

To protect the integrity of our production data, direct pushes to the `main` branch are blocked. 

1. Create a new branch for your feature or fix (e.g., `add-new-model`).
2. Test your changes locally.
3. Open a Pull Request (PR) against the `main` branch and request a review before merging.