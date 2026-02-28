-- =================================================================
-- 1. CÀI ĐẶT HỆ THỐNG & KẾT NỐI S3 (MINIO)
-- =================================================================
SET 'table.exec.resource.default-parallelism' = '1';
SET 'sql-client.execution.result-mode' = 'table';

-- Cấu hình để Flink có thể ghi file vào MinIO
SET 's3.endpoint' = 'http://my-minio.data-storage.svc.cluster.local:9000';
SET 's3.access-key' = 'hiveuser'; -- Thay bằng user của Lộc
SET 's3.secret-key' = 'hivepassword'; -- Thay bằng pass của Lộc
SET 's3.path.style.access' = 'true';

-- =================================================================
-- 2. BẢNG KAFKA (DỮ LIỆU GIAO DỊCH REAL-TIME)
-- =================================================================
CREATE TABLE IF NOT EXISTS kafka_transactions (
    step INT,
    type STRING,
    amount DOUBLE,
    nameOrig STRING,
    oldbalanceOrg DOUBLE,
    newbalanceOrig DOUBLE,
    nameDest STRING,
    oldbalanceDest DOUBLE,
    newbalanceDest DOUBLE,
    isFraud INT,
    isFlaggedFraud INT,
    transaction_id STRING,
    proctime AS PROCTIME(), -- Dùng để Join
    PRIMARY KEY (transaction_id) NOT ENFORCED
) WITH (
    'connector' = 'kafka',
    'topic' = 'pg.public.transactions',
    'properties.bootstrap.servers' = 'my-cluster-kafka-bootstrap:9092', 
    'properties.group.id' = 'flink_production_group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
      'json.fail-on-missing-field' = 'false',
);

-- =================================================================
-- 3. BẢNG POSTGRES (DÙNG ĐỂ TRA CỨU SỐ DƯ - LOOKUP)
-- =================================================================
CREATE TABLE IF NOT EXISTS pg_users (
    user_id STRING,
    current_balance DOUBLE,
    PRIMARY KEY (user_id) NOT ENFORCED
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:postgresql://postgres-service:5432/ecom_Db',
    'table-name' = 'users',
    'username' = 'hiveuser',
    'password' = 'hivepassword'
);

-- =================================================================
-- 4. BẢNG MINIO (LƯU TRỮ PARQUET VĨNH VIỄN)
-- =================================================================
CREATE TABLE IF NOT EXISTS minio_transactions_parquet (
    step INT,
    transaction_id STRING,
    amount DOUBLE,
    type_code INT, -- Cột đã encode sang số để ML dễ học
    isFraud INT,
    dt STRING
) PARTITIONED BY (dt)
WITH (
    'connector' = 'filesystem',
    'path' = 's3a://flink-data/transactions_archive/',
    'format' = 'parquet'
);

-- =================================================================
-- 5. ĐĂNG KÝ HÀM ML XGBOOST
-- =================================================================
CREATE TEMPORARY FUNCTION IF NOT EXISTS predict_fraud 
AS 'fraud_prediction.predict_fraud' 
LANGUAGE PYTHON;