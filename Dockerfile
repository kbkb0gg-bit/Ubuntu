FROM alpine:3.22

ENV LANG=C.UTF-8
ENV DISPLAY=:1
ENV HOME=/root

RUN apk update && apk upgrade && apk add --no-cache \
    bash \
    sudo \
    dbus \
    dbus-x11 \
    xorg-server \
    xf86-video-dummy \
    mesa-dri-gallium \
    font-dejavu \
    ttf-dejavu \
    lxqt-desktop \
    openbox \
    xterm \
    tigervnc \
    novnc \
    websockify \
    xkeyboard-config \
    procps \
    coreutils \
    shadow \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /root/.vnc /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

RUN printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec dbus-launch startlxqt\n' > /root/.vnc/xstartup \
    && chmod +x /root/.vnc/xstartup

RUN printf '#!/bin/sh\n\
set -e\n\
mkdir -p /root/.vnc\n\
if [ ! -f /root/.vnc/passwd ]; then\n\
    echo "Set VNC_PASSWORD before starting the container."\n\
    exit 1\n\
fi\n\
vncserver :1 -geometry "${RESOLUTION:-1280x800}" -depth 24 -localhost no\n\
exec websockify --web=/usr/share/novnc/ 0.0.0.0:6080 localhost:5901\n' \
    > /usr/local/bin/start-desktop \
    && chmod +x /usr/local/bin/start-desktop

EXPOSE 5901 6080

CMD ["/bin/sh", "-c", "mkdir -p /root/.vnc && printf '%s' \"$VNC_PASSWORD\" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd && exec /usr/local/bin/start-desktop"]
