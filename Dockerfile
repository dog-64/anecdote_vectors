#https://medium.com/simform-engineering/dockerize-your-rails-7-app-3223cc851129

FROM ruby:3.1.2-bullseye as base

ARG OPEN_AI_KEY
ENV OPEN_AI_KEY=$OPEN_AI_KEY
ARG PINECONE_API_KEY
ENV PINECONE_API_KEY=$OPEN_AI_KEY
ARG PINECONE_ENVIRONMENT
ENV PINECONE_ENVIRONMENT=$PINECONE_ENVIRONMENT

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES 1
ENV LANG en_US.UTF-8
ENV RAILS_LOG_TO_STDOUT 1

RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs

WORKDIR /docker/app

RUN mkdir -p /docker/app/tmp/pids

RUN gem install bundler

COPY Gemfile* ./

RUN bundle install

ADD . /docker/app

#ARG DEFAULT_PORT 3000

#EXPOSE ${DEFAULT_PORT}

#CMD [ "bundle","exec", "puma", "config.ru"] # CMD ["rails","server"] # you can also write like this.
