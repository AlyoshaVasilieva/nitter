FROM nimlang/nim:2.0.0-ubuntu-regular as nim
LABEL maintainer="setenforce@protonmail.com"

RUN apt-get update && apt-get install -y libsass-dev libpcre3-dev build-essential

WORKDIR /src/nitter

COPY nitter.nimble .
RUN nimble install -y --depsOnly

COPY . .
RUN nimble build -d:danger -d:lto -d:strip \
    && nimble scss \
    && nimble md

FROM ubuntu:latest
WORKDIR /src/
RUN apt-get update && apt-get install -y libpcre3-dev ca-certificates libssl-dev curl wget
COPY --from=nim /src/nitter/nitter ./
COPY --from=nim /src/nitter/nitter.example.conf ./nitter.conf
COPY --from=nim /src/nitter/public ./public
EXPOSE 8080
RUN adduser -h /src/ -D -s /bin/sh nitter
USER nitter
CMD ./nitter
