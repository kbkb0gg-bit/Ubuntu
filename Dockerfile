FROM alpine:3.22

ENV DISPLAY=:1
ENV LANG=C.UTF-8
ENV HOME=/root

# Install complete XFCE desktop and VNC server
RUN apk add --no-cache \
    xfce4 \
    xfce4-terminal \
    thunar \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xfdesktop \
    xfwm4 \
    tigervnc \
    dbus \
    dbus-x11 \
    xterm \
    font-dejavu \
    ttf-liberation \
    procps \
    bash \
    nano \
    sudo \
    shadow \
    adwaita-icon-theme \
    hicolor-icon-theme

# Configure VNC password
RUN mkdir -p /root/.vnc && \
    printf 'ChangeMe123!\n' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Configure desktop startup
RUN printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec dbus-launch --exit-with-session startxfce4\n' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Start VNC server and desktop
RUN cat > /start.sh <<'EOF'
#!/bin/sh
set -eu

mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

exec Xtigervnc :1 \
    -geometry 1280x800 \
    -depth 24 \
    -rfbport 5901 \
    -localhost no \
    -SecurityTypes VncAuth \
    -PasswordFile /root/.vnc/passwd \
    -AlwaysShared \
    -desktop "Alpine XFCE Desktop" \
    -xstartup /root/.vnc/xstartup
EOF

RUN chmod +x /start.sh

EXPOSE 5901

CMD ["/start.sh"]
