FROM debian:bullseye

# Đảm bảo apt-get không hỏi tương tác
ENV DEBIAN_FRONTEND=noninteractive

# Cài dependencies cơ bản
RUN apt-get update && apt-get install -y \
    git build-essential pkg-config \
    libgmp-dev libssl-dev libsqlite3-dev zlib1g-dev \
    libncurses-dev m4 unzip curl \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# Cài GHCup (để có GHC + Cabal + Stack)
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh -s -- -y
ENV PATH="/root/.ghcup/bin:${PATH}"

# Cài Stack qua GHCup
RUN ghcup install stack
RUN ghcup install ghc 9.6.5
RUN ghcup set ghc 9.6.5

# Clone mã nguồn Tamarin
WORKDIR /app
RUN git clone https://github.com/tamarin-prover/tamarin-prover.git
WORKDIR /app/tamarin-prover

# Build Tamarin
RUN stack setup && stack build && stack install

# Thêm PATH
ENV PATH="/root/.local/bin:${PATH}"

# Render truyền vào PORT
ENV PORT=8080
EXPOSE 8080

# Khởi chạy Tamarin web UI
CMD ["sh", "-c", "tamarin-prover interactive . --port $PORT --interface '*4'"]
