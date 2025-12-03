# ===========================
# Stage 1 — Builder
# ===========================
FROM python:3.11-slim AS builder

WORKDIR /app

# System deps needed for torch & transformers
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Replace heavy GPU torch with CPU-only version
RUN sed -i 's/^torch.*/torch==2.3.0+cpu -f https:\/\/download.pytorch.org\/whl\/cpu\/torch_stable.html/' requirements.txt

RUN pip install --user --no-cache-dir -r requirements.txt


# ===========================
# Stage 2 — Runtime Image
# ===========================
FROM python:3.11-slim
WORKDIR /app

COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]