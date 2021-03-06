FROM ruby:2.3.6-stretch


ENV HTTP_PROXY="http://lproxy1.procempa.com.br:3128/"
ENV http_proxy="http://lproxy1.procempa.com.br:3128/"
ENV HTTPS_PROXY="http://lproxy1.procempa.com.br:3128/"
ENV https_proxy="http://lproxy1.procempa.com.br:3128/"
ENV NO_PROXY="localhost, 127.0.0.*, 10.*, 192.168.*, *.procempa.com.br, *.portoalegre.rs.gov.br, *.pmpa.ad, lpmpa-*, lintranet*, lsisweb*, intranet*, sisweb*, webmailpmpa.portoalegre.rs.gov.br, pmpa-intranet, pmpa.ad"
# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client nodejs netcat imagemagick sudo

# Files created inside the container repect the ownership
RUN adduser --shell /bin/bash --disabled-password --gecos "" consul \
  && adduser consul sudo \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN echo 'Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bundle/bin"' > /etc/sudoers.d/secure_path
RUN chmod 0440 /etc/sudoers.d/secure_path

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/consul

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
COPY Gemfile Gemfile

COPY Gemfile.lock Gemfile.lock

COPY Gemfile_custom Gemfile_custom

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
#RUN gem install bundler --force

# Finish establishing our Ruby enviornment
RUN bundle install --full-index

# Copy the Rails application into place
COPY . .

# Define the script we want run once the container boots
# Use the "exec" form of CMD so our script shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "./app_cmd.sh" ]
