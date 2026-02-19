# 1. Base Image
FROM apache/airflow:2.10.4

# 2. Cài thư viện hệ thống (Giữ nguyên)
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    gcc \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Chuyển về user airflow
USER airflow

# 4. Copy file requirements vào trong image
COPY requirements.txt /requirements.txt

# 5. Cài đặt theo danh sách đã định
RUN pip install --no-cache-dir -r /requirements.txt