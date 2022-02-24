FROM registry.evn.com.vn/dev/node:14-buster-slim as node-dev

WORKDIR /src

COPY package.json .npmrc ./

RUN  yarn install --development

COPY . .

RUN yarn build

# Using nginx to serve front-end
FROM registry.evn.com.vn/dev/nginx:stable

RUN apt-get update && apt-get install -y net-tools curl iputils-ping telnet nano vim dnsutils

EXPOSE 8080

WORKDIR /var/www/html

USER root
RUN chmod -R g+w /var/cache/
RUN chmod -R g+w /var/run/

# Copy built artifacts
COPY --from=node-dev /src/build/ ./

# Copy nginx configuration folder
COPY ./nginx/conf.d/nginx.conf /etc/nginx/conf.d/default.conf
