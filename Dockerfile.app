FROM bobbych/redash-base:xenial

COPY . /opt/redash/current
RUN chown -R redash /opt/redash/current

# Setting working directory
WORKDIR /opt/redash/current

RUN pip install peewee==2.6.1 wtf-peewee==0.2.3

RUN curl https://deb.nodesource.com/setup_4.x | bash - && \
  apt-get install -y nodejs && \
  sudo -u redash -H make deps && \
  rm -rf node_modules client/node_modules /home/redash/.npm /home/redash/.cache && \
  apt-get purge -y nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Setup supervisord
RUN mkdir -p /opt/redash/supervisord && \
    mkdir -p /opt/redash/logs && \
    cp /opt/redash/current/setup/docker/supervisord/supervisord.conf /opt/redash/supervisord/supervisord.conf

# Fix permissions
RUN chown -R redash /opt/redash

# Expose ports
EXPOSE 5000
EXPOSE 9001

# Startup script
CMD ["supervisord", "-c", "/opt/redash/supervisord/supervisord.conf"]
