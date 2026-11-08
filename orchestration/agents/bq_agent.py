import os
import warnings

# 1. Silence LangChain's noisy transition warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)
warnings.filterwarnings("ignore", message=".*LangChainDeprecationWarning.*")

from langchain_groq import ChatGroq
from langchain_community.utilities import SQLDatabase
from langchain_community.agent_toolkits import create_sql_agent

# 2. Connect to your BigQuery dbt dataset
PROJECT_ID = "data-warehouse-513514"
DATASET_ID = "dbt_forecast_dev_us"
db = SQLDatabase.from_uri(f"bigquery://{PROJECT_ID}/{DATASET_ID}")

# 3. Initialize the LLM
llm = ChatGroq(
    temperature=0,
    model_name="openai/gpt-oss-120b"
)

# 4. Create the Agent (verbose=False keeps the Airflow logs clean)
agent_executor = create_sql_agent(llm, db=db, agent_type="tool-calling", verbose=False)

print("🤖 Starting Autonomous AI Analyst (Airflow Mode)...")

# 5. Define the automated task you want to run after every dbt build
automated_task = """
Check the latest logistics demand features. 
Identify the top 3 zones with the highest total orders and calculate their demand-per-population ratio.
"""

strict_prompt = (
    f"{automated_task}\n\n"
    "CRITICAL INSTRUCTION: In your final answer, you MUST include the exact SQL query "
    "you used to find the answer, formatted inside a Markdown code block."
)

# 6. Execute the agent autonomously
try:
    response = agent_executor.invoke({"input": strict_prompt})
    print("\n--- AI DAILY INSIGHTS ---")
    print(response["output"])
    print("\n✅ Autonomous Analysis Complete.")
except Exception as e:
    print(f"\n[Error]: The agent encountered an issue: {e}")
    