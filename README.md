# 🚀 J-DataPipe: Intelligent Data Engineering & AI Platform

![Python](https://img.shields.io/badge/Python-3.9-blue?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.95-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.27-326ce5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Kafka](https://img.shields.io/badge/Apache_Kafka-2496ED?style=for-the-badge&logo=apache-kafka&logoColor=white)
![Gemini](https://img.shields.io/badge/Google%20Gemini-AI-8E75B2?style=for-the-badge&logo=google&logoColor=white)

> **Project:** J-DataPipe Platform  
> **Affiliation:** Ho Chi Minh City Open University  
> **Architecture Stack:** Airflow, Kafka, Flink, PostgreSQL, MinIO, XGBoost, Kubernetes

J-DataPipe là một nền tảng dữ liệu toàn diện (End-to-End Data Platform) được thiết kế để xử lý dữ liệu quy mô lớn, kết hợp giữa kiến trúc **Lambda/Kappa** để phục vụ cả nhu cầu phân tích thời gian thực và lưu trữ dài hạn. Hệ thống tích hợp **Gemini AI** để phân tích kiến trúc hình ảnh và **XGBoost** để dự báo xu hướng dữ liệu.

---

## 🏗 High-level System Architecture

Hệ thống được vận hành trên nền tảng **Kubernetes**, đảm bảo khả năng mở rộng và quản lý microservices hiệu quả.

### 1. Orchestration & Ingestion

- **Airflow:** Điều phối luồng dữ liệu từ nguồn (Generate Data) vào hệ thống lưu trữ tập trung.

### 2. Hybrid Data Storage

- **Data Warehouse (PostgreSQL):** Lưu trữ dữ liệu có cấu trúc, phục vụ các truy vấn phân tích tức thời.
- **Data Lake (MinIO & Hive):** Lưu trữ dữ liệu thô (Raw Data) và object storage, cho phép xử lý dữ liệu lớn với Hive.

### 3. Real-time Streaming

- **Debezium (CDC):** Theo dõi và trích xuất sự thay đổi dữ liệu từ PostgreSQL.
- **Apache Kafka:** Hệ thống hàng đợi thông điệp chịu tải cao, điều phối luồng dữ liệu giữa các service.
- **Apache Flink:** Xử lý dòng dữ liệu (Stateful Stream Processing) với độ trễ cực thấp.

### 4. AI & Prediction Layer

- **Google Gemini API:** Phân tích hình ảnh, cung cấp mô tả kiến trúc thông minh.
- **XGBoost:** Thực hiện các bài toán dự báo (Inference) dựa trên dữ liệu đã qua xử lý từ pipeline.

### 5. Monitoring & Observability

- **Prometheus:** Thu thập chỉ số (metrics) từ toàn bộ hạ tầng K8s.
- **Grafana:** Trực quan hóa hiệu năng hệ thống qua các dashboard thời gian thực

---

## 📂 Repository Structure

```bash
J-DataPipe/
├── app/
│   ├── main.py            # FastAPI Application
│   ├── worker.py          # Celery/Stream processing worker
│   └── ml_model/          # XGBoost & Gemini API integration
├── config/
│   ├── deployment.yaml    # K8s Deployment
│   ├── service.yaml       # K8s Service networking
│   └── fastapi-monitor.yaml # Prometheus Service Monitor
├── charts/                # Helm charts for infrastructure
├── Dockerfile             # Containerization
└── requirements.txt       # Dependencies
```

🚀 Real-Time Data Pipeline with Kafka, Flink & Gemini AI

This project implements a real-time data processing pipeline using Kafka, Flink, and Gemini AI for intelligent data analysis.
The system is deployed on Kubernetes (Minikube) and monitored using Prometheus + Grafana.

📚 This project is developed as part of a research initiative at Ho Chi Minh City Open University.

🔧 Prerequisites

To run this project locally, you need:

🐳 Docker Desktop

☸️ Minikube (v1.30+)

📦 Helm

🎛 kubectl (configured to connect to your cluster)

🔑 Gemini API Key from Google AI Studio

🕹️ Installation & Setup
1️⃣ Start Kubernetes Cluster
minikube start --driver=docker

Verify cluster status:

kubectl get nodes
2️⃣ Configure Environment Secrets

Create a Kubernetes Secret to store your Gemini API key:

kubectl create secret generic gemini-secret \
  --from-literal=GEMINI_API_KEY=YOUR_KEY_HERE

Verify:

kubectl get secrets
3️⃣ Deploy the Data Pipeline
kubectl apply -f config/deployment.yaml
kubectl apply -f config/service.yaml

Check running pods:

kubectl get pods
4️⃣ Setup Monitoring Stack (Prometheus + Grafana)

Add Helm repository:

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

Install kube-prometheus-stack:

helm install monitor-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
📊 Monitoring

Forward port to access Grafana:

kubectl port-forward svc/monitor-stack-grafana 3000:80 -n monitoring

Access:

http://localhost:3000

👤 Username: admin

🔑 Get password:

kubectl get secret monitor-stack-grafana -n monitoring \
  -o jsonpath="{.data.admin-password}" | base64 --decode

The dashboard provides:

Kafka throughput metrics

Flink consumer lag

Pod CPU & memory usage

JVM performance metrics

🏗️ System Architecture
Database → Debezium → Kafka → Flink → Gemini AI → Output Sink
                                ↓
                           Prometheus
                                ↓
                             Grafana
🛠️ Technology Stack

Apache Kafka – Message Broker

Apache Flink – Stream Processing

Debezium – CDC Connector

Prometheus – Metrics Collection

Grafana – Visualization

Kubernetes – Container Orchestration

Minikube – Local Kubernetes Cluster

🧪 Development & Extensions

You can extend this system by:

Writing a Python script for Debezium → Kafka producer

Developing advanced Flink streaming jobs

Integrating MinIO (S3-compatible storage)

Adding Alerting with Prometheus Alertmanager

Deploying to cloud environments (EKS, GKE, AKS)

🛠 Troubleshooting
Pod in CrashLoopBackOff
kubectl logs <pod-name>
Cannot access Grafana
kubectl get svc -n monitoring
👨‍💻 Author

Research Student
Ho Chi Minh City Open University
2026
