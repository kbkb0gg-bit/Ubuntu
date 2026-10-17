FROM nullskill/openvscode-server-flutter:1.105.1-3.44.4

USER root

RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    zip \
    xz-utils \
    ca-certificates \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV PORT=3000

EXPOSE 3000

USER openvscode-server

WORKDIR /home/workspace

CMD ["sh", "-c", "exec /home/openvscode-server/bin/openvscode-server --host 0.0.0.0 --port ${PORT} --without-connection-token /home/workspace"]
