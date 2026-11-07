# Autonomous AI Logistics Analyst

This module contains the LangChain SQL agents that autonomously query the BigQuery `logistics_forecasting` dataset using the Groq API. 

## Files
* `app.py`: The interactive Streamlit web interface. It features chat history, smart prompt routing for natural conversations, and transparent SQL code blocks.
* `bq_agent.py`: The headless command-line script. This is designed to be triggered downstream by Apache Airflow after the `dbt build` task completes.

## Prerequisites
Ensure your AI Python environment (`ai-venv`) is active and all dependencies are installed:
```bash
source ~/ai-venv/bin/activate
pip install langchain-groq langchain-community streamlit sqlalchemy-bigquery

## Authentication
This agent uses **Groq** (`openai/gpt-oss-120b`) for high-speed LLM inference and your local `gcloud` default credentials to execute the generated SQL against BigQuery. 

You must export your Groq API key before running either script:
```bash
export GROQ_API_KEY="your-groq-key"

## Running the Web UI
To launch the interactive chat interface in your browse:
```bash
streamlit run app.py