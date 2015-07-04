FROM ruby:2.2.2
MAINTAINER DevOps <devops@activestate.com>

RUN apt-get update && apt-get install -y cmake && apt-get clean

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

ENV RACK_ENV=production
EXPOSE 4567

CMD ["/usr/local/bin/ruby", "server.rb"]

