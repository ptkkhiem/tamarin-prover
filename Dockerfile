FROM haskell:9.6-buster

RUN apt-get update && apt-get install -y \
    git build-essential pkg-config \
    libgmp-dev libssl-dev libsqlite3-dev zlib1g-dev \
    libncurses-dev m4 unzip curl \
    graphviz maude \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://get.haskellstack.org/ | sh

WORKDIR /app
RUN git clone https://github.com/tamarin-prover/tamarin-prover.git
WORKDIR /app/tamarin-prover

RUN stack setup && stack build && stack install

ENV PATH="/root/.local/bin:${PATH}"

# Render cung cấp PORT qua biến môi trường
EXPOSE 3001
CMD ["sh", "-c", "tamarin-prover interactive . --port $PORT --interface '*4'"]
