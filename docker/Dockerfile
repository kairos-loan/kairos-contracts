# ##### FOUNDRY IMAGE #######
FROM ghcr.io/foundry-rs/foundry:latest as base

# Install missing bin
# Git is already installed in base parent image
RUN apk add --no-cache --update nodejs-current yarn npm entr

# Install python for node
RUN apk -Uuv add groff less python3 python3-dev g++ make

# Add the wait script to the image
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait /usr/bin/wait
RUN chmod +x /usr/bin/wait

# Install Solidity compiler v0.8.17
# To update if we update pragma
RUN apk add --no-cache wget\
  && cd /tmp \
  && wget https://github.com/ethereum/solidity/releases/download/v0.8.17/solc-static-linux \
  && mv /tmp/solc-static-linux /usr/bin/solc \
  && chmod +x /usr/bin/solc \
  && apk del wget

RUN npm install -g ts-node

WORKDIR  /usr/app

ENTRYPOINT ["/bin/sh -c"]