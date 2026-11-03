# Use a lightweight Python base image
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y git && apt-get clean

# Set the working directory inside the container
WORKDIR /usr/app

# Install the dbt BigQuery adapter
RUN pip install --no-cache-dir dbt-bigquery

# Copy your dbt project and profiles.yml into the container
COPY logistics_forecasting/ ./logistics_forecasting/

# Set the default command to run the pipeline
CMD ["dbt", "run", "--project-dir", "logistics_forecasting", "--profiles-dir", "logistics_forecasting"]
