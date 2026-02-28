#!/bin/bash

# Màu sắc cho terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' 

echo -e "${BLUE}🚀 Đang bắt đầu triển khai hệ thống DE (Postgres - Kafka - Flink - Airflow)...${NC}"

# 1. Tạo các Namespace
echo -e "${GREEN}1. Tạo Namespaces (data-storage, stream, orchestration)...${NC}"
for ns in data-storage stream orchestration monitoring; do
    kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -
done

# 2. Cài đặt Strimzi Operator và cấu hình quản lý đa Namespace
echo -e "${GREEN}2. Cài đặt Strimzi Kafka Operator...${NC}"
helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm upgrade --install strimzi-operator strimzi/strimzi-kafka-operator \
  --namespace stream \
  --set watchNamespaces='{*}' # QUAN TRỌNG: Cho phép Operator quản lý tất cả Namespace

# 3. Triển khai Cơ sở dữ liệu (Postgres)
echo -e "${GREEN}3. Triển khai Postgres tại namespace data-storage...${NC}"
kubectl apply -f infra/postgres/ -n data-storage    

# 4. Triển khai Kafka (Sau khi Operator đã sẵn sàng)
echo -e "${GREEN}4. Triển khai Kafka tại namespace stream...${NC}"

kubectl create secret docker-registry my-docker-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=USER-NAME \
  --docker-password=PASSWORD \
  --docker-email=EMAIL \
  -n stream
helm upgrade --install strimzi-operator strimzi/strimzi-kafka-operator \
  --namespace stream \
  --create-namespace \
  --set watchNamespaces="{stream}"

# 5. Triển khai Flink
echo -e "${GREEN}5. Triển khai Flink tại namespace stream...${NC}"
kubectl apply -f infra/flink/ -n stream

# 6. Triển khai Airflow bằng Helm
echo -e "${GREEN}6. Triển khai Airflow tại namespace orchestration...${NC}"
helm repo add apache-airflow https://airflow.apache.org
helm repo update

# Cài đặt Airflow bản tối giản để tiết kiệm RAM cho Minikube
helm install airflow apache-airflow/airflow -n orchestration -f infra/airflow/override-values.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitor-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring

# Cai dat minio
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-minio bitnami/minio -n data-storage -f infra/minio/values.yaml



echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}✅ TẤT CẢ LỆNH ĐÃ ĐƯỢC GỬI!${NC}"
echo -e "1. Kiểm tra Pod: ${GREEN}kubectl get pods -A${NC}"
echo -e "2. Web Airflow (admin/admin): ${GREEN}kubectl port-forward svc/airflow-webserver 8080:8080 -n orchestration${NC}"
echo -e "3. Lưu ý: Đợi khoảng 3-5 phút để Kafka và Airflow khởi tạo xong.${NC}"
echo -e "${BLUE}====================================================${NC}"