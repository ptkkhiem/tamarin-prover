FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Cài dependencies cơ bản
RUN apt-get update && apt-get install -y \
    git build-essential pkg-config \
    libgmp-dev libssl-dev libsqlite3-dev zlib1g-dev \
    libncurses-dev m4 unzip curl \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# Cài GHCup (Haskell installer)
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh -s -- -y
ENV PATH="/root/.ghcup/bin:${PATH}"

# Cài Stack và GHC 9.2.8 (phiên bản ổn định với Tamarin)
RUN ghcup install stack
RUN ghcup install ghc 9.2.8
RUN ghcup set ghc 9.2.8

# Clone mã nguồn Tamarin
WORKDIR /app
RUN git clone https://github.com/tamarin-prover/tamarin-prover.git
WORKDIR /app/tamarin-prover

# Build Tamarin
RUN stack setup && stack build && stack install

# Thêm PATH để gọi được tamarin-prover
ENV PATH="/root/.local/bin:${PATH}"

# Render sẽ truyền biến PORT
ENV PORT=8080
EXPOSE 8080

# Khởi chạy Tamarin web UI
CMD ["sh", "-c", "tamarin-prover interactive . --port $PORT --interface '*4'"]
