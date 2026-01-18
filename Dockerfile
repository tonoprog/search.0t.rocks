# Single-container demo for search.0t.rocks (educational/demo)
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  wget unzip openjdk-11-jdk nodejs npm python3 python3-pip supervisor procps curl \
  && rm -rf /var/lib/apt/lists/*

# make npm newer (optional)
RUN npm install -g npm@9 || true

WORKDIR /app
COPY . /app

# If package.json exists, install deps and try to build
RUN /bin/sh -c 'if [ -f package.json ]; then npm install --production || true; npm run build || true; fi'

# install Solr (8.x archived release) for demo
ENV SOLR_VERSION=8.11.2
RUN wget -qO /tmp/solr.tgz https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz \
  && tar xzf /tmp/solr.tgz -C /opt \
  && mv /opt/solr-${SOLR_VERSION} /opt/solr \
  && rm /tmp/solr.tgz

# supervisord to run both Solr and the web app
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 3000 8983
