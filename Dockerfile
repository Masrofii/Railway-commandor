FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget git gnupg openssh-server sudo \
    python3 python3-pip python3-venv python3-dev build-essential \
    sqlite3 jq nano vim-tiny tree htop tmux screen \
    dnsutils iputils-ping iproute2 procps lsof rsync unzip zip \
    figlet toilet iproute2 \
    openssl \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g pm2 pnpm yarn typescript tsx nodemon \
    && mkdir -p /run/sshd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY branding/commandor-welcome.sh /etc/profile.d/commandor-welcome.sh

RUN chmod +x /entrypoint.sh /etc/profile.d/commandor-welcome.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
