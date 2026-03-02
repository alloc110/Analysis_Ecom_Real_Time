FROM flink:1.17

USER root

# 1. Cài đặt công cụ hệ thống và Python
RUN apt-get update -y && \
      apt-get install -y wget ca-certificates python3 python3-pip python3-dev && \
      ln -s /usr/bin/python3 /usr/bin/python

# 2. Tải CÁC FILE JAR THƯ VIỆN (Bắt buộc phải có đủ bộ này)
# --- JDBC & Postgres ---
RUN wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.0-1.17/flink-connector-jdbc-3.1.0-1.17.jar -P /opt/flink/lib/
RUN wget -q https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.3/postgresql-42.7.3.jar -P /opt/flink/lib/

# --- KAFKA BỘ ĐÔI (Thiếu 1 trong 2 là lỗi NoClassDefFound) ---
# Connector của Flink
RUN wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.0.1-1.17/flink-connector-kafka-3.0.1-1.17.jar -P /opt/flink/lib/
# Thư viện gốc của Kafka (ĐÂY LÀ CÁI CÒN THIẾU)
RUN wget -q https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.4.0/kafka-clients-3.4.0.jar -P /opt/flink/lib/

# --- DEBEZIUM & JSON FORMAT ---
RUN wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-json/1.17.2/flink-json-1.17.2.jar -P /opt/flink/lib/

# --- MINIO / S3 SUPPORT ---
RUN wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-s3-fs-hadoop/1.17.2/flink-s3-fs-hadoop-1.17.2.jar -P /opt/flink/lib/

# 3. Cài đặt Python ML
RUN pip3 install --no-cache-dir --upgrade pip setuptools && \
      pip3 install --no-cache-dir xgboost pandas scikit-learn boto3

# 4. Cấp quyền
RUN mkdir -p /opt/flink/usrlib && chown -R flink:flink /opt/flink/usrlib

USER flink