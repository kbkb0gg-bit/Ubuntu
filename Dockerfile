FROM alpine:3.22

ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV RESOLUTION=1280x720
ENV DEPTH=24

RUN apk update && apk add --no-cache sudo
&& mkdir -p /root/.vnc

RUN printf '#!/bin/sh\n
set -eu\n
mkdir -p /root/.vnc\n
PASS="${VNC_PASSWORD:-alpine123}"\n
printf "%s\n%s\n\n" "$PASS" "$PASS" | vncpasswd -f > /root/.vnc/passwd\n
chmod 600 /root/.vnc/passwd\n
cat > /root/.vnc/xstartup <<EOF\n
#!/bin/sh\n
unset SESSION_MANAGER\n
unset DBUS_SESSION_BUS_ADDRESS\n
exec dbus-run-session startlxqt\n
EOF\n
chmod +x /root/.vnc/xstartup\n
exec tigervncserver :1 -fg -localhost no -geometry "${RESOLUTION}" -depth "${DEPTH}" -rfbport "${VNC_PORT}" -SecurityTypes VncAuth -PasswordFile /root/.vnc/passwd\n' > /start.sh 
&& chmod +x /start.sh

EXPOSE 5901

CMD ["/start.sh"]
