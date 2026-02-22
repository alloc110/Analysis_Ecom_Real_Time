from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime, timedelta
from faker import Faker
import random

fake = Faker()

def generate_and_insert_data(batch_size=100, **kwargs):
    # 1. Kết nối tới Postgres bằng Connection ID chúng ta đã tạo
    # Nhớ đổi 'postgres_final' thành ID thật bạn đã đặt trong values.yaml
    pg_hook = PostgresHook(postgres_conn_id='my_postgres_conn')
    conn = pg_hook.get_conn()
    cursor = conn.cursor()

    # 2. Lấy giá trị 'step' từ Airflow (ví dụ: dùng số giờ kể từ ngày bắt đầu)
    # 1 step = 1 hour
    execution_date = kwargs.get('execution_date')
    step_val = execution_date.hour + (execution_date.day * 24)

    transactions = []
    for _ in range(batch_size):
        amount = round(random.uniform(1.0, 500000.0), 2)
        trans_type = random.choice(['CASH_IN', 'CASH_OUT', 'DEBIT', 'PAYMENT', 'TRANSFER'])
        
        # Logic tính toán số dư cho khớp với thực tế
        old_org = round(random.uniform(amount, 1000000), 2)
        if trans_type in ['CASH_OUT', 'TRANSFER']:
            new_org = old_org - amount
        elif trans_type == 'CASH_IN':
            new_org = old_org + amount
        else:
            new_org = old_org

        name_dest = f"M{fake.random_number(digits=9)}" if random.random() > 0.5 else f"C{fake.random_number(digits=9)}"
        is_fraud = 1 if (amount > 200000 and trans_type == 'TRANSFER' and random.random() < 0.1) else 0
        is_flagged = 1 if amount > 200000 else 0

        transactions.append((
            step_val, trans_type, amount, 
            f"C{fake.random_number(digits=9)}", old_org, new_org,
            name_dest, round(random.uniform(0, 1000000), 2), 0.0, # Dest balance tính sau
            bool(is_fraud), bool(is_flagged)
        ))

    # 3. Insert dữ liệu vào tầng Bronze
    insert_sql = """
        INSERT INTO financial_transactions (
            step, type, amount, nameOrig, oldbalanceOrg, newbalanceOrig,
            nameDest, oldbalanceDest, newbalanceDest, isFraud, isFlaggedFraud
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    cursor.executemany(insert_sql, transactions)
    conn.commit()
    cursor.close()
    conn.close()

# 4. Định nghĩa DAG
default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'data_generation_paysim_v1',
    default_args=default_args,
    description='Tạo dữ liệu ảo PaySim và đẩy vào Postgres Bronze Layer',
    schedule_interval='@hourly', # Chạy mỗi giờ một lần tương ứng với 1 step
    start_date=datetime(2026, 2, 1),
    catchup=False
) as dag:

    generate_task = PythonOperator(
        task_id='generate_fake_transactions',
        python_callable=generate_and_insert_data,
        op_kwargs={'batch_size': 500} # Mỗi giờ tạo 500 giao dịch
    )