FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root
ENV DISPLAY=:1

RUN apt-get update && apt-get install -y 
xfce4 
xfce4-terminal 
tigervnc-standalone-server 
tigervnc-common 
dbus-x11 
sudo 
nano 
curl 
ca-certificates 
&& apt-get clean 
&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc

Set VNC password

RUN printf '%s\n' '29$939(#)&)@' | vncpasswd -f > /root/.vnc/passwd 
&& chmod 600 /root/.vnc/passwd

Configure XFCE session

RUN printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec startxfce4\n' 
> /root/.vnc/xstartup 
&& chmod +x /root/.vnc/xstartup

EXPOSE 5901

CMD ["sh", "-c", "vncserver :1 -geometry 1280x800 -depth 24 -localhost no && tail -F /root/.vnc/*.log"]
