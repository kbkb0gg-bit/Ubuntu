FROM alpine:3.22

ENV LANG=C.UTF-8
ENV DISPLAY=:1
ENV HOME=/root
ENV RESOLUTION=1280x800

# Install Alpine Linux desktop and VNC packages
RUN apk add --no-cache \
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
    && mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

# Configure LXQt session
RUN cat > /usr/local/bin/xstartup <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session startlxqt
EOF

RUN chmod +x /usr/local/bin/xstartup

# Configure desktop startup
RUN cat > /usr/local/bin/start-desktop <<'EOF'
#!/bin/sh
set -eu

: "${VNC_PASSWORD:?Set VNC_PASSWORD environment variable}"

mkdir -p /root/.config/tigervnc

# Generate VNC password file
printf '%s\n' "$VNC_PASSWORD" \
    | vncpasswd -f > /root/.config/tigervnc/passwd

chmod 600 /root/.config/tigervnc/passwd

# Start VNC X server directly
Xvnc :1 \
    -geometry "${RESOLUTION:-1280x800}" \
    -depth 24 \
    -rfbauth /root/.config/tigervnc/passwd \
    -rfbport 5901 \
    -localhost no \
    -SecurityTypes VncAuth \
    -AlwaysShared &

XVNC_PID=$!

cleanup() {
    kill "$WEB_PID" "$SESSION_PID" "$XVNC_PID" 2>/dev/null || true
}

WEB_PID=""
SESSION_PID=""

trap cleanup EXIT INT TERM

# Wait until the X server is ready
READY=0
i=0

while [ "$i" -lt 15 ]; do
    if ! kill -0 "$XVNC_PID" 2>/dev/null; then
        echo "ERROR: Xvnc exited unexpectedly"
        wait "$XVNC_PID" || true
        exit 1
    fi

    if [ -S /tmp/.X11-unix/X1 ]; then
        READY=1
        break
    fi

    sleep 1
    i=$((i + 1))
done

if [ "$READY" -ne 1 ]; then
    echo "ERROR: Xvnc failed to initialize"
    exit 1
fi

export DISPLAY=:1

# Start LXQt desktop session
/usr/local/bin/xstartup &
SESSION_PID=$!

# Start noVNC web access
websockify \
    --web=/usr/share/novnc \
    0.0.0.0:6080 \
    127.0.0.1:5901 &
WEB_PID=$!

echo "LXQt desktop started."
echo "VNC port: 5901"
echo "noVNC port: 6080"

# Keep container alive while Xvnc is running
wait "$XVNC_PID"
EOF

RUN chmod +x /usr/local/bin/start-desktop

EXPOSE 5901 6080

CMD ["/usr/local/bin/start-desktop"]
