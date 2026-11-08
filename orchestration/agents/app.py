import os
import warnings
import streamlit as st

warnings.filterwarnings("ignore", category=DeprecationWarning)
warnings.filterwarnings("ignore", message=".*LangChainDeprecationWarning.*")

from langchain_groq import ChatGroq
from langchain_community.utilities import SQLDatabase
from langchain_community.agent_toolkits import create_sql_agent

# 1. Attractive Page Configuration & UI
st.set_page_config(page_title="Logistics AI", page_icon="📦", layout="wide")

# Sidebar for tips and info
with st.sidebar:
    st.title("📦 Logistics AI")
    st.markdown("Your autonomous data analyst.")
    st.divider()
    st.info("💡 **Try asking:**\n- Which city has the highest population density?\n- Show me the 7-day rolling average for zone_2.\n- How many total orders were there on October 27?")

st.title("Data Command Center 📊")

@st.cache_resource
def get_agent():
    PROJECT_ID = "data-warehouse-513514"
    DATASET_ID = "dbt_forecast_dev_us"
    db = SQLDatabase.from_uri(f"bigquery://{PROJECT_ID}/{DATASET_ID}")
    
    llm = ChatGroq(temperature=0, model_name="openai/gpt-oss-120b")
    return create_sql_agent(llm, db=db, agent_type="tool-calling", verbose=False)

agent_executor = get_agent()

# 2. Add an automatic welcoming greeting to the chat history
if "messages" not in st.session_state:
    st.session_state.messages = [
        {"role": "assistant", "content": "Hello! 👋 I am your Logistics AI. I'm connected to your BigQuery warehouse. How can I help you today?", "avatar": "🤖"}
    ]

# Render chat history with custom avatars
for message in st.session_state.messages:
    with st.chat_message(message["role"], avatar=message.get("avatar")):
        st.markdown(message["content"])

if prompt := st.chat_input("Ask a question about your logistics data..."):
    # Add user message
    st.session_state.messages.append({"role": "user", "content": prompt, "avatar": "🧑‍💻"})
    with st.chat_message("user", avatar="🧑‍💻"):
        st.markdown(prompt)

    # 3. Smart Prompt: Instruct the AI to handle small talk naturally
    strict_prompt = (
        f"{prompt}\n\n"
        "CRITICAL INSTRUCTIONS:\n"
        "1. If the user is just saying hello, greeting you, or saying thanks, respond naturally and politely WITHOUT using any SQL tools.\n"
        "2. If the user is asking a data question, you MUST include the exact SQL query you used inside a Markdown code block in your final answer."
    )

    with st.chat_message("assistant", avatar="🤖"):
        with st.spinner("Thinking..."):
            try:
                response = agent_executor.invoke({"input": strict_prompt})
                answer = response["output"]
            except Exception as e:
                answer = f"⚠️ **Error:** {e}"
        
        st.markdown(answer)
        st.session_state.messages.append({"role": "assistant", "content": answer, "avatar": "🤖"})
