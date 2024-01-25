# Pi-hole + Cloudflared DNS over HTTPS (DoH) Proxy

[![Build and Push Docker Image to Docker Hub](https://github.com/Jonathan-Henriksen/pihole-doh/actions/workflows/docker-hub.yml/badge.svg?branch=main)](https://github.com/Jonathan-Henriksen/pihole-doh/actions/workflows/docker-hub.yml)

This project extends the official [Pi-hole](https://github.com/pi-hole/docker-pi-hole) Docker image by seamlessly integrating a Cloudflared DNS over HTTPS (DoH) proxy. Both Pi-hole and Cloudflared operate cohesively within the same container for a simple and efficient deployment.

## How it Works

Cloudflared is installed on top of the official Pi-hole image and configured to start a DNS over HTTPS Proxy, listening on port 5053. Pi-hole can then be configured to use this DoH proxy through the `PIHOLE_DNS_` environment variable(See docker-compose.yml for refernce).

## Environment Variables
### Upstream
This image introduces just a single new environment variable, `UPSTREAM`, allowing you to define the adress of the resolver that should be used for DoH queries. By default, it points to Cloudflare's endpoint: `https://cloudflare-dns.com/dns-query`, so if you're migrating from an existing Pi-hole container, you don't explicitly have to change anything other than the `PIHOLE_DNS_` variable to the address of the Cloudflared proxy, running on port 5053.

### Complete List
For a comprehensive list of environment variables used by Pi-hole, consult the [official Pi-hole GitHub page](https://github.com/pi-hole/docker-pi-hole). This project introduces only one additional variable (`UPSTREAM`).

## Example Usage with Docker Compose

To illustrate, here's a sample `docker-compose.yml` file:

```yaml
version: '3.5'
networks:
  dns-net:
    name: dns-net
    ipam:
      driver: default
      config:
        - subnet: 50.5.0.0/24
          gateway: 50.5.0.1

services:
  pihole:
    container_name: pihole
    hostname: pihole
    image: crunchypancake/pihole-doh:latest
    networks:
      dns-net:
        ipv4_address: 50.5.0.2
    ports:
      - '53:53/tcp'
      - '53:53/udp'
      - '67:67/udp'
      - '1337:80/tcp'
    environment:
      TZ: 'Europe/Copenhagen'
      WEBPASSWORD: 'y0urP@ssW0rD'
      DNSMASQ_LISTENING: 'all'
      WEB_BIND_ADDR: '50.5.0.2'
      FTLCONF_LOCAL_IPV4: '50.5.0.2'
      PIHOLE_DNS_: '50.5.0.2#5053'
    volumes:
      - './etc:/etc/pihole'
      - './dnsmasq.d:/etc/dnsmasq.d'
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
