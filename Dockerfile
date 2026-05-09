FROM jekyll/jekyll:latest
RUN gem install bundler 'jekyll:4.3.2' 'webrick:1.8.1' 'liquid'
WORKDIR /srv/jekyll
EXPOSE 4000
CMD bundle exec jekyll serve --force_polling --host 0.0.0.0 --trace