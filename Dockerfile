FROM lscr.io/linuxserver/chromium:latest

ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Karachi

EXPOSE 3000 3001

VOLUME ["/config"]
