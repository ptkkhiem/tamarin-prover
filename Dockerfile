# Dockerfile - dùng debian và ghcup, cài GHC 9.2.8, ép stack dùng system-ghc + resolver lts-20.26
FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=8080

# 1) Cài các phụ thuộc hệ thống
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git build-essential pkg-config \
    libgmp-dev libssl-dev libsqlite3-dev zlib1g-dev \
    libncurses-dev m4 unzip \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# 2) Cài ghcup non-interactive (GHC + ghcup bin)
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh -s -- -y

# Thêm ghcup và GHC bin vào PATH (đường dẫn chuẩn của ghcup)
ENV PATH="/root/.ghcup/bin:/root/.ghcup/ghc/9.2.8/bin:/root/.local/bin:${PATH}"

# 3) Cài stack và GHC cụ thể (9.2.8)
RUN /root/.ghcup/bin/ghcup install stack \
 && /root/.ghcup/bin/ghcup install ghc 9.2.8 \
 && /root/.ghcup/bin/ghcup set ghc 9.2.8

# Kiểm tra
RUN stack --version || true
RUN ghc --version || true

# 4) Clone mã nguồn tamarin (shallow)
WORKDIR /app
RUN git clone --depth 1 https://github.com/tamarin-prover/tamarin-prover.git

WORKDIR /app/tamarin-prover

# 5) Dùng stack với hệ thống GHC và resolver cố định (lts-20.26 ~ GHC 9.2.x)
#    --no-terminal để không chờ input, --system-ghc để dùng GHC đã cài sẵn
RUN stack --no-terminal --system-ghc --resolver lts-20.26 setup || true
RUN stack --no-terminal --system-ghc --resolver lts-20.26 build --verbose
RUN stack --no-terminal --system-ghc --resolver lts-20.26 install

# PATH để gọi binary tamarin-prover
ENV PATH="/root/.local/bin:${PATH}"

EXPOSE ${PORT}

CMD ["sh", "-c", "tamarin-prover interactive . --port $PORT --interface '*4'"]
