# Sử dụng phiên bản Flink ổn định (tương thích với dự án của bạn)
FROM flink:1.17.0-scala_2.12

# Thiết lập thư mục làm việc
WORKDIR /opt/flink

# Tải các Connector quan trọng cho hệ thống Fraud Detection
# 1. Kafka Connector: Để đọc dữ liệu từ Kafka
RUN wget -P lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.0.0-1.17/flink-connector-kafka-3.0.0-1.17.jar

# 2. JDBC Connector: Để ghi kết quả cảnh báo vào Postgres
RUN wget -P lib/ https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.0-1.17/flink-connector-jdbc-3.1.0-1.17.jar

# 3. Postgres Driver
RUN wget -P lib/ https://jdbc.postgresql.org/download/postgresql-42.6.0.jar

# (Tùy chọn) Copy code ứng dụng Java/Scala đã build của bạn
# COPY target/fraud-detection-1.0.jar /opt/flink/usrlib/fraud-detection.jar

# Chạy với quyền user flink để đảm bảo bảo mật cho Cluster
USER flink