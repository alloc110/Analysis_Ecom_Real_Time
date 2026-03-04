FROM flink:1.17.2-java11

USER root

# 1. Cài đặt Python và các công cụ hệ thống cần thiết (Gộp lại để giảm layer)
RUN apt-get update -y && \
      apt-get install -y --no-install-recommends \
      wget \
      ca-certificates \
      python3 \
      python3-pip \
      python3-dev && \
      ln -s /usr/bin/python3 /usr/bin/python && \
      rm -rf /var/lib/apt/lists/*

# 2. Tải JAR thư viện (Dùng một lần chạy RUN duy nhất để tối ưu)
WORKDIR /opt/flink/lib
RUN wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.0-1.17/flink-connector-jdbc-3.1.0-1.17.jar && \
      wget -q https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.3/postgresql-42.7.3.jar && \
      wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.0.1-1.17/flink-connector-kafka-3.0.1-1.17.jar && \
      wget -q https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.4.0/kafka-clients-3.4.0.jar && \
      wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-json/1.17.2/flink-json-1.17.2.jar && \
      wget -q https://repo1.maven.org/maven2/org/apache/flink/flink-s3-fs-hadoop/1.17.2/flink-s3-fs-hadoop-1.17.2.jar

# 3. Cài đặt Python ML (Gộp tất cả thư viện vào 1 lệnh, có apache-flink)
RUN pip3 install --no-cache-dir --upgrade pip setuptools && \
      pip3 install --no-cache-dir \
      apache-flink==1.17.2 \
      xgboost \
      pandas \
      scikit-learn \
      numpy \
      boto3

# 4. Tạo thư mục usrlib và phân quyền cho người dùng flink
RUN mkdir -p /opt/flink/usrlib && \
      chown -R flink:flink /opt/flink/usrlib

# Chuyển về user flink để đảm bảo bảo mật đúng chuẩn Flink Image
USER flink
WORKDIR /opt/flink