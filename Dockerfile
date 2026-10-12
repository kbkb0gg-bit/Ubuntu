FROM alpine:latest

ENV DISPLAY=:1
ENV LANG=C.UTF-8

# Install desktop environment and VNC
RUN apk add --no-cache \
    lxde \
    lxterminal \
    tigervnc \
    dbus \
    dbus-x11 \
    xterm \
    xorg-server \
    xinit \
    procps \
    sudo \
    bash \
    nano \
    shadow

# Configure VNC
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

EXPOSE 5901

CMD ["/start.sh"]
