FROM alpine:3.22

ENV LANG=en_US.UTF-8
ENV DISPLAY=:1
ENV USER=root

# Install LXQt desktop, X11, VNC and noVNC dependencies
RUN apk update && apk add --no-cache \
    lxqt-desktop \
    openbox \
    xterm \
    dbus \
    dbus-x11 \
    x11vnc \
    xvfb \
    novnc \
    websockify \
    bash \
    supervisor \
    ttf-dejavu \
    fontconfig \
    mesa-gl \
    mesa-dri-gallium \
    && rm -rf /var/cache/apk/*

# Create startup script
RUN mkdir -p /root/.config/openbox

RUN printf '#!/bin/sh\n\
mkdir -p /run/dbus\n\
dbus-daemon --system --fork || true\n\
Xvfb :1 -screen 0 1280x800x24 -ac &\n\
sleep 2\n\
export DISPLAY=:1\n\
openbox-session &\n\
sleep 2\n\
xterm &\n\
x11vnc -display :1 -forever -shared -nopw -rfbport 5900 &\n\
exec websockify --web=/usr/share/novnc/ 6080 localhost:5900\n' \
> /start.sh && chmod +x /start.sh

EXPOSE 5900 6080

CMD ["/start.sh"]
