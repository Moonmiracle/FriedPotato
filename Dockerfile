# == Engine ==================================================================
FROM node:latest AS build
RUN apt-get update -y && apt-get install -y \
    git
WORKDIR /

# -- Installations -----------------------------------------------------------
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" /dev/null
RUN git clone https://github.com/sevenc-nanashi/sonolus-pjsekai-engine-extended.git engine

# -- Compile -----------------------------------------------------------------
RUN cd engine && npm install && npm run build

# == Server ==================================================================
FROM ruby:3.1
RUN apt-get update -y && apt-get install -y \
    ffmpeg
WORKDIR /root

# -- Installations -----------------------------------------------------------
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle config with production; \
    bundle install

# -- Startup -----------------------------------------------------------------
COPY --from=build /engine/dist/EngineData engine/dist/EngineData
COPY --from=build /engine/dist/EngineConfiguration engine/dist/EngineConfiguration
COPY . .
CMD ["bundle", "exec", "unicorn", "-l", "0.0.0.0:4567"]