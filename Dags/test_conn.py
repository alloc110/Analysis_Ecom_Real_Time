from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from datetime import datetime

with DAG('test_ket_noi_postgres', start_date=datetime(2026, 1, 1), schedule_interval=None, catchup=False) as dag:
    test_task = PostgresOperator(
        task_id='chay_thu_query',
        postgres_conn_id='my_postgres_conn', # Điền Connection ID của bạn vào đây
        sql="SELECT 1;"
    )
