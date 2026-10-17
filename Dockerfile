FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV DISPLAY=:1

# Install LXDE, TigerVNC, and required packages
RUN apt-get update && apt-get install -y \
    lxde \
    lxterminal \
    dbus-x11 \
    tigervnc-standalone-server \
    tigervnc-common \
    x11-xserver-utils \
    sudo \
    nano \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure VNC password
RUN mkdir -p /root/.vnc && \
    printf '%s\n' 'waseemqpeiis29#(' 'waseemqpeiis29#(' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Configure VNC desktop startup
RUN printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startlxde\n' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# VNC port
EXPOSE 5901

# Start VNC server
CMD ["sh", "-c", "vncserver :1 -geometry 1280x800 -depth 24 -localhost no && tail -F /root/.vnc/*.log"]
