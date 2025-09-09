# ---------- Stage 1: builder (build Tamarin with Haskell toolchain) ----------
FROM haskell:9.2.8-buster AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV STACK_ROOT=/root/.stack
ENV PATH="/root/.local/bin:${PATH}"

# 1) cài các package hệ thống cần cho build Haskell
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates curl git build-essential pkg-config \
    libgmp-dev libssl-dev libsqlite3-dev zlib1g-dev \
    libncurses-dev m4 unzip \
    graphviz \
    alex happy \
    libpcre3-dev libicu-dev libtinfo-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# 2) clone repo tamarin (shallow)
RUN git clone --depth 1 https://github.com/tamarin-prover/tamarin-prover.git .

# 3) ensure stack uses system-ghc and fixed resolver (lts compatible with GHC 9.2.x)
#    --system-ghc: dùng GHC có sẵn trong image (haskell:9.2.8)
#    --resolver lts-20.26: cố định snapshot tương thích (thay đổi nếu bạn muốn khác)
RUN stack --no-terminal --system-ghc --resolver lts-20.26 setup || true

# 4) build with single job to reduce memory pressure, verbose for debug if fails
RUN stack --no-terminal --system-ghc --resolver lts-20.26 build --jobs=1 --ghc-options="-j1" --verbose

# 5) install binary to ~/.local/bin
RUN stack --no-terminal --system-ghc --resolver lts-20.26 install

# ---------- Stage 2: runtime (small image) ----------
FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=8080

# runtime libs needed by tamarin binary (adjust if runtime fails)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    libgmp10 libsqlite3-0 zlib1g libtinfo6 graphviz \
    # libssl package name can vary by distro; try libssl3/libssl1.1 fallback
    libssl3 || true \
 && rm -rf /var/lib/apt/lists/*

# copy binary and examples from builder
COPY --from=builder /root/.local/bin/tamarin-prover /usr/local/bin/tamarin-prover
COPY --from=builder /src/examples /opt/tamarin/examples

WORKDIR /opt/tamarin/examples

EXPOSE ${PORT}

CMD ["sh", "-c", "tamarin-prover interactive . --port $PORT --interface '*4'"]
