FROM ubuntu:jammy

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install chrome
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends curl ca-certificates sudo \
 && curl -o /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
 && dpkg -i /tmp/google-chrome.deb || true \
 && apt-get install -f -y --no-install-recommends \
 && rm /tmp/google-chrome.deb /etc/apt/sources.list.d/google-chrome.list /etc/apt/trusted.gpg.d/google-chrome.gpg \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# create user
RUN groupadd -g 1000 user \
 && useradd -u 1000 -g 1000 -s /bin/bash -m -l user \
 && usermod -a -G sudo user \
 && echo "ALL ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && echo "user:password" | chpasswd
USER user
ENV HOME=/home/user
WORKDIR $HOME

# install node with volta
ENV VOLTA_HOME="$HOME/.volta"
ENV PATH="$VOLTA_HOME/bin:$PATH"

RUN curl -s https://get.volta.sh | bash -s -- --skip-setup

ARG NODE_VERSION=lts
RUN volta install node@$NODE_VERSION

# install latest npm, yarn & pnpm with corepack
RUN npm i -g npm@latest corepack@latest \
 && corepack prepare --all --activate

CMD ["google-chrome", "--version"]
