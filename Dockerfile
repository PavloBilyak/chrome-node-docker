FROM ubuntu:jammy

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# add google linux repo
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends wget curl ca-certificates gnupg \
 && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install chrome
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends google-chrome-stable \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# create user
RUN groupadd --gid 1000 user \
 && useradd --uid 1000 --gid user --shell /bin/bash --create-home user \
 && usermod -a -G sudo user \
 && echo "ALL ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && echo "user:password" | chpasswd
USER user
ENV HOME=/home/user
WORKDIR $HOME

# install node with volta
ENV VOLTA_HOME="$HOME/.volta"
ENV PATH="$VOLTA_HOME/bin:$PATH"

RUN curl https://get.volta.sh | bash -s -- --skip-setup

ARG NODE_VERSION=lts
RUN volta install node@$NODE_VERSION

# install latest npm, yarn & pnpm with corepack
RUN npm i -g npm@latest corepack@latest \
 && corepack prepare --all --activate

CMD ["google-chrome", "--version"]
