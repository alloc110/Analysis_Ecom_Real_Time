-- 1. Bảng Khách hàng
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(100),
    amount BIGINT,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 3. Bảng Giao dịch (Nơi luồng data tuôn chảy liên tục)
DROP TABLE IF EXISTS transactions CASCADE;
CREATE TABLE transactions (
    step INT,
    transaction_id VARCHAR(50) PRIMARY KEY,
    source_user_id VARCHAR(50) REFERENCES users(user_id),
    dest_user_id VARCHAR(50) REFERENCES users(user_id),
    amount BIGINT,
    payment_method VARCHAR(50),
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng Cảnh báo gian lận (Đích đến để Flink ghi kết quả)
CREATE TABLE fraud_alerts (
    alert_id SERIAL PRIMARY KEY, -- SERIAL tự động tăng số 1, 2, 3...
    transaction_id VARCHAR(50) REFERENCES transactions(transaction_id),
    risk_score DECIMAL(5, 2),
    alert_reason VARCHAR(255),
    alert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);