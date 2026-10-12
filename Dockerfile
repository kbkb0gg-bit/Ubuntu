FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# Install LXDE and VNC server
RUN apt-get update && apt-get install -y \
    lxde-core \
    lxterminal \
    dbus-x11 \
    tigervnc-standalone-server \
    tigervnc-common \
    xterm \
    procps \
    sudo \
    nano \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure VNC password and desktop startup
RUN mkdir -p /root/.vnc && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec dbus-launch --exit-with-session startlxde\n' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    printf 'ChangeMe123!\n' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Startup script
RUN printf '#!/bin/sh\n\
set -e\n\
vncserver :1 -geometry 1280x800 -depth 24 -localhost no\n\
exec tail -F /root/.vnc/*.log\n' > /start.sh && \
    chmod +x /start.sh

# Railway TCP port
EXPOSE 5901

CMD ["/start.sh"]
