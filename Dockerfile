# SPDX-FileCopyrightText: 2023-2026 Sayantan Santra <sayantan.santra689@gmail.com>
# SPDX-License-Identifier: MIT
# Source build for VibeNest; context is the repository root.
FROM rust:1.96.0-alpine@sha256:f87aa870663e2b57ec8c69de82c7eedf7383bee987eef7612c0359635eaadb41 AS builder
RUN apk add --no-cache musl-dev
WORKDIR /build
COPY backend/Cargo.toml backend/Cargo.lock ./
COPY backend/src ./src
RUN cargo build --release --locked --jobs 1 --bin chhoto-url
RUN mkdir -p /runtime/data /runtime/frontend/final

FROM scratch
COPY --from=builder /build/target/release/chhoto-url /app/chhoto-url
COPY --from=builder /runtime/data /data
COPY --from=builder /runtime/frontend/final /app/frontend/final
COPY frontend /app/frontend/base
WORKDIR /app
ENV CHHOTO_DB_URL=/data/urls.sqlite \
    CHHOTO_LISTEN_ADDRESS=0.0.0.0 \
    CHHOTO_LISTEN_PORT=4567 \
    CHHOTO_SQLITE_USE_WAL_MODE=True \
    CHHOTO_SQLITE_ENSURE_ACID=True \
    CHHOTO_PUBLIC_MODE=Disable \
    CHHOTO_REQUIRE_PASSWORD=True \
    CHHOTO_SECURE_COOKIES=True \
    CHHOTO_WORKERS=1
EXPOSE 4567
ENTRYPOINT ["/app/chhoto-url"]
