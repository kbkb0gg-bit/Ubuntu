FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1

# Install XFCE desktop, TigerVNC, and useful utilities
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    tigervnc-standalone-server \
    tigervnc-tools \
    sudo \
    xterm \
    fonts-dejavu \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure VNC password and desktop startup
RUN mkdir -p /root/.vnc && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    printf 'vncpassword\nvncpassword\n\n' | vncpasswd /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# VNC display :1 uses TCP port 5901
EXPOSE 5901

# Start VNC server in the foreground
CMD ["sh", "-c", "vncserver :1 -fg -localhost no -geometry 1280x800 -depth 24"]
