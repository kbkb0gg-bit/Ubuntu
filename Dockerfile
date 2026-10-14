FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV VNC_RESOLUTION=1280x800
ENV VNC_DEPTH=24

# Install XFCE desktop, VNC server and required utilities
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    tigervnc-standalone-server \
    tigervnc-common \
    sudo \
    nano \
    curl \
    wget \
    net-tools \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create VNC configuration directory
RUN mkdir -p /root/.vnc

# Configure VNC startup
RUN printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec startxfce4\n' > /root/.vnc/xstartup \
    && chmod +x /root/.vnc/xstartup

# Create startup script
RUN printf '#!/bin/bash\n\
set -e\n\
mkdir -p /root/.vnc\n\
if [ -z "$VNC_PASSWORD" ]; then\n\
  echo "ERROR: Set VNC_PASSWORD environment variable."\n\
  exit 1\n\
fi\n\
printf "%s\\n" "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd\n\
chmod 600 /root/.vnc/passwd\n\
vncserver :1 -fg -localhost no -geometry "$VNC_RESOLUTION" -depth "$VNC_DEPTH" -rfbauth /root/.vnc/passwd\n' > /usr/local/bin/start-vnc.sh \
    && chmod +x /usr/local/bin/start-vnc.sh

EXPOSE 5901

CMD ["/usr/local/bin/start-vnc.sh"]
