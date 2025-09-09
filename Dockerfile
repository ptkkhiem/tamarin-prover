FROM haskell:9.6-buster

# Cài dependencies (bỏ maude để tránh lỗi apt-get trên Render)
RUN apt-get update && apt-get install -y \
    git build-essential pkg-config \
    libgmp-dev libssl-dev libsqlite3-dev zlib1g-dev \
    libncurses-dev m4 unzip curl \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# Cài Haskell Stack
RUN curl -sSL https://get.haskellstack.org/ | sh

# Tạo thư mục làm việc
WORKDIR /app

# Clone repo Tamarin
RUN git clone https://github.com/tamarin-prover/tamarin-prover.git

WORKDIR /app/tamarin-prover

# Build Tamarin
RUN stack setup && stack build && stack install

# Thêm PATH cho binary
ENV PATH="/root/.local/bin:${PATH}"

# Render cần $PORT
EXPOSE 3001
CMD ["sh", "-c", "tamarin-prover interactive . --port $PORT --interface '*4'"]

