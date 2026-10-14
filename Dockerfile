FROM debain:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV DISPLAY=:1

# Install XFCE desktop and VNC/web access
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    x11-xserver-utils \
    x11vnc \
    xvfb \
    novnc \
    websockify \
    supervisor \
    sudo \
    ca-certificates \
    fonts-dejavu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure VNC password
RUN mkdir -p /root/.vnc && \
    x11vnc -storepasswd desktop123 /root/.vnc/passwd

# Configure supervisor
RUN mkdir -p /etc/supervisor/conf.d

RUN printf '%s\n' \
    '[supervisord]' \
    'nodaemon=true' \
    '' \
    '[program:xvfb]' \
    'command=/usr/bin/Xvfb :1 -screen 0 1280x800x24 -ac' \
    'autorestart=true' \
    '' \
    '[program:xfce]' \
    'command=/usr/bin/dbus-launch --exit-with-session startxfce4' \
    'environment=DISPLAY=":1"' \
    'autorestart=true' \
    '' \
    '[program:x11vnc]' \
    'command=/usr/bin/x11vnc -display :1 -forever -shared -rfbauth /root/.vnc/passwd -rfbport 5900 -listen 0.0.0.0' \
    'autorestart=true' \
    '' \
    '[program:novnc]' \
    'command=/usr/bin/websockify --web=/usr/share/novnc/ 6080 localhost:5900' \
    'autorestart=true' \
    > /etc/supervisor/conf.d/desktop.conf

EXPOSE 5900 6080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
