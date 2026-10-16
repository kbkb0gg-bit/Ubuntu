FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NOVNC_PORT=6080
ENV VNC_PASSWORD=debian123

RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    websockify \
    xterm \
    sudo \
    ca-certificates \
    procps \
    net-tools \
    fonts-dejavu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc

RUN printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' \
    > /root/.vnc/xstartup \
    && chmod +x /root/.vnc/xstartup

RUN printf '#!/bin/bash\n\
set -e\n\
mkdir -p /root/.vnc\n\
printf "%s\\n" "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd\n\
chmod 600 /root/.vnc/passwd\n\
vncserver :1 -geometry 1280x800 -depth 24 -localhost no\n\
websockify --web=/usr/share/novnc/ 0.0.0.0:6080 localhost:5901 &\n\
exec tail -f /dev/null\n' > /start.sh \
    && chmod +x /start.sh

EXPOSE 5901 6080

CMD ["/start.sh"]
