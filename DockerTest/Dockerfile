# Use lightweight Ubuntu
FROM ubuntu:22.04

# Non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    sudo \
    xz-utils \
    zip \
    libglu1-mesa \
    libxi6 \
    libxrender1 \
    libxtst6 \
    libxrandr2 \
    libxfixes3 \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m runner
WORKDIR /home/runner

# Install Flutter SDK
ENV FLUTTER_VERSION=3.38.5
RUN git clone -b stable https://github.com/flutter/flutter.git /home/runner/flutter \
    && /home/runner/flutter/bin/flutter --version

ENV PATH="/home/runner/flutter/bin:/home/runner/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Copy entrypoint
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Switch to runner user
USER runner
WORKDIR /home/runner

# Entrypoint
ENTRYPOINT ["./entrypoint.sh"]
