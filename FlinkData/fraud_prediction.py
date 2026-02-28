import pandas as pd
import xgboost as xgb
import os
from pyflink.table import udf, DataTypes

# 1. Cấu hình đường dẫn mô hình
# Khi mount ConfigMap vào Pod, file sẽ nằm ở đường dẫn này (tùy theo file YAML của Lộc)
MODEL_PATH = "/opt/flink/usrlib/fraud_model.json"

# 2. Khởi tạo mô hình Global để tránh việc mỗi dòng dữ liệu lại load lại file (gây chậm)
_model = None

def get_model():
    global _model
    if _model is None:
        _model = xgb.XGBClassifier()
        if os.path.exists(MODEL_PATH):
            _model.load_model(MODEL_PATH)
        else:
            # Fallback nếu không tìm thấy file để tránh crash Job Flink
            print(f"Warning: Model file not found at {MODEL_PATH}")
    return _model

# 3. Mapping loại giao dịch (Phải khớp 100% với lúc Lộc train)
TYPE_MAP = {
    'CASH_IN': 0,
    'CASH_OUT': 1,
    'DEBIT': 2,
    'PAYMENT': 3,
    'TRANSFER': 4
}

@udf(result_type=DataTypes.INT())
def predict_fraud(step, type_str, amount, oldbalanceOrg, newbalanceOrig, oldbalanceDest, newbalanceDest):
    """
    Hàm UDF để dự đoán gian lận cho từng dòng dữ liệu từ Flink SQL
    """
    # Lấy mô hình
    model = get_model()
    if model is None:
        return 0

    # Tiền xử lý: Chuyển Type từ chuỗi sang số
    type_code = TYPE_MAP.get(type_str, 0) # Mặc định là 0 nếu không khớp

    # Tạo DataFrame với đúng thứ tự cột như lúc Train
    # Lưu ý: Lộc cần đảm bảo danh sách cột này y hệt tập X_train
    input_df = pd.DataFrame([[
        step, 
        type_code, 
        amount, 
        oldbalanceOrg, 
        newbalanceOrig, 
        oldbalanceDest, 
        newbalanceDest
    ]], columns=['step', 'type', 'amount', 'oldbalanceOrg', 'newbalanceOrig', 'oldbalanceDest', 'newbalanceDest'])

    try:
        # Dự đoán
        prediction = model.predict(input_df)
        return int(prediction[0])
    except Exception as e:
        # Ghi log lỗi nếu có biến cố (ví dụ thiếu cột)
        print(f"Prediction error: {str(e)}")
        return 0