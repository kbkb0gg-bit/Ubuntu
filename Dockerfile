FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV DISPLAY=:1

RUN apt-get update && apt-get install -y xfce4 xfce4-terminal dbus-x11 tigervnc-standalone-server tigervnc-tools x11-xserver-utils nano curl wget ca-certificates && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc && printf 'dockerpass\n' | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd && printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec dbus-launch --exit-with-session startxfce4\n' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

EXPOSE 5901

CMD ["/bin/bash", "-lc", "vncserver :1 -geometry 1280x800 -depth 24 -localhost no -SecurityTypes VncAuth -rfbport 5901 && tail -F /root/.vnc/*.log"]
