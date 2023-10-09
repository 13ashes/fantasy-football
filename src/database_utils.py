from sqlalchemy import create_engine
from sqlalchemy import text
import pandas as pd
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration for PostgreSQL database
DATABASE_URL = f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
engine = create_engine(DATABASE_URL)


def execute_sql(query):
    try:
        with engine.connect() as connection:
            connection.execute(text(query))
            connection.commit()
    except Exception as e:
        print(f"An error occurred while executing {query}: {e}")


def read_sql(query, params=None):
    return pd.read_sql_query(query, engine, params=params)


def write_df_to_postgres(df, table_name, schema_name):
    try:
        df.to_sql(table_name, engine, if_exists='append', index=False, schema=schema_name)
        print(f"Data written to {schema_name}.{table_name}.")
    except Exception as e:
        print(f"An error occurred: {e}")

# Add more utility functions as needed
