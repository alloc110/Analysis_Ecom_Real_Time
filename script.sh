#!/bin/bash

# Màu sắc cho terminal để dễ nhìn
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Đang bắt đầu triển khai hệ thống DE trên Minikube...${NC}"

# 1. Tạo các Namespace cần thiết
echo -e "${GREEN}1. Tạo Namespaces...${NC}"
kubectl create namespace data-storage --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace messaging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace batch-namespace --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace stream-namespace --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace orchestration --dry-run=client -o yaml | kubectl apply -f -
# 2. Triển khai Cơ sở dữ liệu (Postgres & MinIO)
echo -e "${GREEN}2. Triển khai Postgres và MinIO...${NC}"
# Lộc đảm bảo đã có các file yaml này trong folder k8s nhé
helm repo add strimzi https://strimzi.io/charts/
helm repo update

# Cài đặt Operator vào namespace messaging
helm install strimzi-operator strimzi/strimzi-kafka-operator \
  --namespace data-storage
kubectl apply -f infra/postgres/ -n data-storage    
kubectl apply -f infra/minio/ -n data-storage

# Thêm vào trước phần cài đặt Trino trong deploy_all.sh
echo -e "${GREEN}4.5 Triển khai Hive Metastore...${NC}"
# 2. Apply file Deployment
kubectl apply -f infra/hive/hive.yaml -n data-storage

echo "Đợi Hive Metastore khởi động..."
kubectl wait --for=condition=ready pod -l app=hive -n data-storage --timeout=90s
# Đợi Hive Metastore sẵn sàng trước khi cài Trino
kubectl wait --for=condition=ready pod -l app=hive-metastore -n data-storage --timeout=60s

# 3. Triển khai Kafka
echo -e "${GREEN}3. Triển khai Kafka...${NC}"
kubectl apply -f infra/kafka/ -n messaging

# 4. Triển khai Spark Operator (Cài đặt qua Helm)
echo -e "${GREEN}4. Đang kiểm tra Spark Operator...${NC}"
helm repo add spark-operator https://kubeflow.github.io/spark-operator
helm repo update
helm upgrade --install my-spark-operator spark-operator/spark-operator \
  --namespace spark-operator --create-namespace --set webhook.enable=true

echo -e "${GREEN}🚀 Đang triển khai Flink Fraud Detection...${NC}"
kubectl apply -f infra/flink/deployment.yaml -n stream-namespace
# 5. Triển khai Trino
echo -e "${GREEN}5. Triển khai Trino...${NC}"
# Dùng file values.yaml để giữ cấu hình RAM thấp cho máy ASUS
helm upgrade --install my-trino trino/trino \
  --namespace data-storage \
  --set server.workers=1 \
  --set coordinator.resources.requests.memory=1Gi

echo -e "${BLUE}✅ Hoàn thành! Đợi vài phút để các Pod chuyển sang trạng thái Running.${NC}"
echo -e "Dùng lệnh: ${GREEN}kubectl get pods -A${NC} để kiểm tra."