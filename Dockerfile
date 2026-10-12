FROM alpine:3.22

ENV DISPLAY=:1
ENV LANG=C.UTF-8
ENV HOME=/root

# Install XFCE desktop and VNC packages
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
    adwaita-icon-theme \
    hicolor-icon-theme

# Configure VNC password
RUN mkdir -p /root/.vnc && \
    printf 'ChangeMe123!\n' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Configure XFCE startup
RUN printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec dbus-launch --exit-with-session startxfce4\n' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Find the installed VNC server executable
RUN VNC_BIN="$(command -v Xvnc || command -v Xtigervnc || find /usr -type f \( -name Xvnc -o -name Xtigervnc \) -print -quit)" && \
    test -n "$VNC_BIN" && \
    printf '%s\n' "$VNC_BIN" > /vnc-bin

# Start VNC and XFCE
RUN cat > /start.sh <<'EOF'
#!/bin/sh
set -eu

VNC_BIN="$(cat /vnc-bin)"

mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

exec "$VNC_BIN" :1 \
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
