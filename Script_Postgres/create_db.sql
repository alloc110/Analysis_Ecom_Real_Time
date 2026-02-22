CREATE TABLE fraud_db (
    step INTEGER,
    type VARCHAR(20),
    amount DECIMAL(18, 2),
    name_orig VARCHAR(50),
    oldbalance_org DECIMAL(18, 2),
    newbalance_orig DECIMAL(18, 2),
    name_dest VARCHAR(50),
    oldbalance_dest DECIMAL(18, 2),
    newbalance_dest DECIMAL(18, 2),
    is_fraud BOOLEAN,
    is_flagged_fraud BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);