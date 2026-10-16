FROM alpine:3.22

ENV DISPLAY=:1
ENV LANG=C.UTF-8

RUN apk add --no-cache \
    xvfb \
    x11vnc \
    openbox \
    lxqt \
    dbus \
    dbus-x11 \
    xterm \
    ttf-dejavu

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5900

CMD ["/start.sh"]
