from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

# Cấu hình mặc định cho DAG
default_args = {
    'owner': 'loc_dev',
    'depends_on_past': False,
    'start_date': datetime(2026, 2, 15),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Khai báo DAG
with DAG(
    dag_id='test_loc_airflow_k8s',
    default_args=default_args,
    description='DAG kiểm tra kết nối Git-Sync và K8s Worker',
    catchup=False,
    tags=['testing', 'minikube'],
) as dag:

    def hello_loc():
        print("--------------------------------------------------")
        print("Chào Lộc! Airflow trên máy ASUS đã chạy thành công!")
        print(f"Thời gian hiện tại: {datetime.now()}")
        print("--------------------------------------------------")

    # Task kiểm tra Python cơ bản
    run_test = PythonOperator(
        task_id='print_hello_task',
        python_callable=hello_loc,
    )

    run_test