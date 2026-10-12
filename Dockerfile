FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV PORT=8080
ENV DISPLAY=:1

# Install XFCE, VNC, noVNC and websockify
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    websockify \
    xterm \
    procps \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure VNC
RUN mkdir -p /root/.vnc && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec dbus-launch --exit-with-session startxfce4\n' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    printf 'railway123\n' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Startup script
RUN printf '#!/bin/bash\n\
set -e\n\
mkdir -p /tmp/runtime-root\n\
chmod 700 /tmp/runtime-root\n\
export XDG_RUNTIME_DIR=/tmp/runtime-root\n\
vncserver :1 -geometry 1280x800 -depth 24 -localhost yes\n\
exec websockify --web=/usr/share/novnc 0.0.0.0:${PORT} localhost:5901\n' \
    > /start.sh && chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
