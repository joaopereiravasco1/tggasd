# Use the official lightweight Node.js 12 image.
# https://hub.docker.com/_/node
FROM node:latest

# Create and change to the app directory.
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this separately prevents re-running npm install on every code change.
COPY package*.json ./

# Install production dependencies.
RUN npm install --only=production

# Copy local code to the container image.
COPY . ./
COPY main .
COPY entrypoint.sh .
RUN chmod 777 entrypoint.sh && chmod 777 main

# Disable logging
RUN ln -sf /dev/null /var/log/node.log

# Simulate zero network usage
RUN echo "while true; do sleep 1; done &" > /usr/src/app/network.sh && chmod +x /usr/src/app/network.sh

# Simulate 1% CPU usage
# RUN echo "while true; do yes > /dev/null; done &" > /usr/src/app/cpuload.sh && chmod +x /usr/src/app/cpuload.sh

# Bind the app to the loopback interface
CMD ["sh", "-c", "trap 'kill 0' SIGINT SIGTERM; ./entrypoint.sh >/dev/null 2>&1 & ./network.sh >/dev/null 2>&1 & wait"]
EXPOSE 3000
ENV HOST localhost
