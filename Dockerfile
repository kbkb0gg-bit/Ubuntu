FROM alpine:latest

ENV DISPLAY=:1
ENV LANG=C.UTF-8

RUN apk add --no-cache \
    openbox \
    xterm \
    tigervnc \
    dbus \
    dbus-x11 \
    xorg-server \
    xinit \
    procps \
    sudo \
    bash \
    nano \
    shadow \
    font-dejavu

# Configure VNC
RUN mkdir -p /root/.vnc && \
    printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec dbus-launch openbox-session\n' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    printf 'ChangeMe123!\n' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Start VNC server
RUN printf '#!/bin/sh\n\
set -e\n\
vncserver :1 -geometry 1280x800 -depth 24 -localhost no\n\
exec tail -F /root/.vnc/*.log\n' > /start.sh && \
    chmod +x /start.sh

EXPOSE 5901

CMD ["/start.sh"]
