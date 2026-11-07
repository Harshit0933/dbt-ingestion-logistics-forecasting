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

# 3. Initialize the LLM (Using Flash in the European region)
llm = ChatGroq(
    temperature=0,
    model_name="openai/gpt-oss-120b"
)

# 3. Create the Agent
agent_executor = create_sql_agent(llm, db=db, agent_type="tool-calling", verbose=True)

# 4. Interactive Chat Interface
print("\n" + "="*55)
print("🤖 Welcome to the Autonomous Logistics Data Analyst!")
print("Ask any question about your BigQuery data.")
print("Type 'exit' or 'quit' to stop.")
print("="*55)

while True:
    # Prompt the user for a command
    user_query = input("\nYour question:\n> ")
    
    # Graceful exit
    if user_query.lower() in ['exit', 'quit']:
        print("Closing the AI assistant. Goodbye!")
        break
        
    # Ignore empty inputs
    if not user_query.strip():
        continue

    # Execute the agent
    try:
        response = agent_executor.invoke({"input": user_query})
        print("\n--- AI RESPONSE ---")
        print(response["output"])
    except Exception as e:
        print(f"\n[Error]: The agent encountered an issue: {e}")
