from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from datetime import datetime

with DAG(
    dag_id="test_ket_noi_postgres",
    start_date=datetime(2026, 1, 1),
    schedule=None,  # Airflow 3 dùng schedule thay cho schedule_interval
    catchup=False,
) as dag:

    test_task = SQLExecuteQueryOperator(
        task_id="chay_thu_query",
        conn_id="my_postgres_conn",   # đổi từ postgres_conn_id
        sql="SELECT 1;"
    )