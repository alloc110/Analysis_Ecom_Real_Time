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


      transactions = []
      for _ in range(batch_size):
            
            step = fake.random_number(min = 1, max = 744)        # Số giờ trong một tháng
            transaction_id = f"T{fake.random_number(digits=10)}" # ID giao dịch giả
            amount = round(random.uniform(1.0, 500000.0), 2)      # Số tiền giao dịch từ 1 đến 500,000
            payment_method = random.choice(['CASH_IN', 'CASH_OUT', 'DEBIT', 'PAYMENT', 'TRANSFER'])
            user = f"user_{fake.random_number(min=1000, max=9999)}"
            user_dest = f"user_{fake.random_number(min=1000, max=9999)}"
            time = fake.date_time_this_month()        

            transactions.append((
                  step,
                  transaction_id, 
                  amount, 
                  user,
                  user_dest,
                  payment_method,
                  time
            ))

# 3. Insert dữ liệu vào tầng Bronze
      insert_sql = """
            INSERT INTO transaction (
                  step, transaction_id, user_id, dest_user_id, amount, payment_method, transaction_time
            ) VALUES (%s, %s, %s, %s, %s, %s, %s)
      """
      cursor.executemany(insert_sql, transactions)
      conn.commit()
      cursor.close()
      conn.close()

# 4. Định nghĩa DAG và task
default_args = {
      'owner': 'airflow',
      'retries': 1,
      'retry_delay': timedelta(minutes=5),
}

with DAG(
      'generate_fake_transactions',
      default_args=default_args,
      description='Tạo dữ liệu ảo PaySim và đẩy vào Postgres Bronze Layer',
      start_date=datetime(2026, 2, 1),
      catchup=False
) as dag:
      generate_task = PythonOperator(
      task_id='generate_fake_transactions',
      python_callable=generate_and_insert_data,
      op_kwargs={'batch_size': 500} # Mỗi giờ tạo 500 giao dịch
)