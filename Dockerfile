FROM pihole/pihole:latest

ENV TERM xterm

ENV DOH_UPSTREAM https://cloudflare-dns.com/dns-query
ENV DOH_PORT 5053

ARG TARGETPLATFORM

RUN export ARCH=$(case ${TARGETPLATFORM:-linux/amd64} in \
    "linux/amd64")   echo "amd64"  ;; \
    "linux/arm64")   echo "arm64" ;; \
    *)               echo ""        ;; esac) \
  && echo "ARCH=$ARCH" \
  && DEBIAN_FRONTEND=noninteractive \
  apt-get update \
  && apt-get install -y python3 curl net-tools \
  && rm -rf /var/lib/apt/lists/* \
  && curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}.deb \
  && yes | sudo dpkg -i cloudflared.deb

# Add strict order to prefer DoH even though it is a little slower
COPY ./config/02-strict-order.conf /etc/dnsmasq.d/02-strict-order.conf
RUN chmod +x /etc/dnsmasq.d/02-strict-order.conf

HEALTHCHECK --interval=5m --timeout=5s \
  CMD nslookup google.com $WEB_BIND_ADDR || exit 1

CMD /bin/bash -c "cloudflared proxy-dns --address $WEB_BIND_ADDR --port $DOH_PORT --upstream $DOH_UPSTREAM"
