FROM haskell:9.6-buster

# Cài dependencies
RUN apt-get update && apt-get install -y \
    git build-essential pkg-config \
    libgmp-dev libssl-dev libsqlite3-dev zlib1g-dev \
    libncurses-dev m4 unzip curl \
    graphviz maude \
    && rm -rf /var/lib/apt/lists/*

# Cài Haskell Stack
RUN curl -sSL https://get.haskellstack.org/ | sh

# Clone Tamarin
WORKDIR /app
RUN git clone https://github.com/tamarin-prover/tamarin-prover.git
WORKDIR /app/tamarin-prover

# Build
RUN stack setup && stack build && stack install

ENV PATH="/root/.local/bin:${PATH}"

# Cloud Run truyền vào PORT
ENV PORT=8080
EXPOSE 8080

# Run Tamarin interactive
CMD ["sh", "-c", "tamarin-prover interactive . --port $PORT --interface '*4'"]
