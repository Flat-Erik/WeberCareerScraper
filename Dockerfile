FROM ruby:2.2

RUN apt-get update 
RUN apt-get install -y apt-utils
RUN apt-get install -y build-essential nodejs

RUN mkdir -p /app
WORKDIR /app

COPY . .
RUN gem install bundler -v 1.17.3 && bundle install --jobs 20 --retry 5
RUN rake db:migrate

EXPOSE 3000

ENTRYPOINT [ "bundle", "exec" ]

CMD [ "rails", "server", "-b", "0.0.0.0" ]