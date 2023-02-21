# ##### FOUNDRY IMAGE #######
FROM ghcr.io/foundry-rs/foundry:latest as base

# Install missing bin
# Git is already installed in base parent image
RUN apk add --no-cache --update nodejs-current yarn npm entr

# Add global npm dependencies
RUN npm install -g ts-node typechain

# Add the wait script to the image
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait /usr/bin/wait
RUN chmod +x /usr/bin/wait

# Install Solidity compiler v0.8.18
# To update if we update pragma
RUN apk add --no-cache wget
RUN cd /tmp 
RUN wget https://github.com/ethereum/solidity/releases/download/v0.8.18/solc-static-linux
RUN mv solc-static-linux /usr/bin/solc 
RUN chmod +x /usr/bin/solc 

WORKDIR  /usr/app

ENTRYPOINT ["/bin/sh -c"]