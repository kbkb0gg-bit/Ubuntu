FROM fedora:latest

ENV LANG=C.UTF-8
ENV DISPLAY=:1

# Install desktop environment and VNC
RUN dnf -y upgrade && \
    dnf -y install \
    @lxde-desktop \
    tigervnc-server \
    dbus-x11 \
    xterm \
    procps-ng \
    sudo \
    nano \
    shadow-utils \
    hostname \
    && dnf clean all

# Configure VNC password and desktop startup
RUN mkdir -p /root/.vnc && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec dbus-launch --exit-with-session startlxde\n' \
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
