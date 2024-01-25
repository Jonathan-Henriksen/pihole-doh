FROM pihole/pihole:latest

ENV TERM xterm

ENV UPSTREAM https://cloudflare-dns.com/dns-query

RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update \
  && apt-get install -y python3 curl net-tools \
  && rm -rf /var/lib/apt/lists/* \
  && curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb \
  && yes | sudo dpkg -i cloudflared.deb

CMD /bin/bash -c "cloudflared proxy-dns --address $WEB_BIND_ADDR --port 5053 --upstream $UPSTREAM"