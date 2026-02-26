# Sử dụng base image Flink 1.17 chính thức
FROM flink:1.17

# 1. Dọn dẹp sạch sẽ các thư viện Kafka cũ/xung đột (nếu lỡ có)
RUN rm -f /opt/flink/lib/flink-connector-kafka*.jar
RUN rm -f /opt/flink/lib/kafka-clients*.jar

# 2. Tải ĐÚNG bản SQL Connector (đã nhồi sẵn Kafka Clients bên trong)
RUN wget -O /opt/flink/lib/flink-sql-connector-kafka-3.0.0-1.17.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.0.0-1.17/flink-sql-connector-kafka-3.0.0-1.17.jar

# 3. Tải thêm thư viện Format JSON (vì bạn cấu hình 'format' = 'json')
RUN wget -O /opt/flink/lib/flink-json-1.17.2.jar https://repo1.maven.org/maven2/org/apache/flink/flink-json/1.17.2/flink-json-1.17.2.jar

# 4. Phân quyền chuẩn để user 'flink' trong container có thể đọc được
RUN chmod 644 /opt/flink/lib/flink-sql-connector-kafka-3.0.0-1.17.jar
RUN chmod 644 /opt/flink/lib/flink-json-1.17.2.jar