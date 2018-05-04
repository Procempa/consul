FROM ruby:2.3.4
RUN mkdir /myapp

ENV HTTP_PROXY="http://lproxy1.procempa.com.br:3128/"
ENV http_proxy="http://lproxy1.procempa.com.br:3128/"
ENV HTTPS_PROXY="http://lproxy1.procempa.com.br:3128/"
ENV https_proxy="http://lproxy1.procempa.com.br:3128/"
ENV NO_PROXY="localhost, 127.0.0.*, 10.*, 192.168.*, *.procempa.com.br, *.portoalegre.rs.gov.br, *.pmpa.ad, lpmpa-*, lintranet*, lsisweb*, intranet*, sisweb*, webmailpmpa.portoalegre.rs.gov.br, pmpa-intranet, pmpa.ad"

WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
ADD . /myapp
RUN bundle install
