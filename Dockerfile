FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root

# Install XFCE desktop, VNC server and required utilities
RUN apt-get update && apt-get install -y \
    xfce4\
    xfce4-terminal \
    dbus-x11 \
    tigervnc-standalone-server \
    tigervnc-common \
    sudo \
    nano \
    wget \
    curl \
    ca-certificates \
    x11-xserver-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set VNC password and configure desktop startup
RUN mkdir -p /root/.vnc && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    printf 'docker123\n' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# VNC display :1 = port 5901
EXPOSE 5901

CMD ["sh", "-c", "vncserver :1 -geometry 1280x800 -depth 24 -localhost no && tail -F /root/.vnc/*.log"]
