# -*- mode: dockerfile -*-

# Build the host Janet instance
FROM alpine:3.10.1 AS build

RUN apk add --update git gcc make libc-dev
WORKDIR /usr/src
RUN git clone https://github.com/janet-lang/janet /usr/src/janet && cd /usr/src/janet && make && make install

# Add the janet project dependencies here
WORKDIR /app
RUN mkdir -p /app/janet_modules
RUN jpm --modpath=./janet_modules install https://github.com/janet-lang/sqlite3.git
RUN jpm --modpath=./janet_modules install https://github.com/janet-lang/circlet.git
RUN jpm --modpath=./janet_modules install https://github.com/janet-lang/json.git

COPY ./Makefile /app/
COPY ./find-deps.sh /app/
RUN make deps

FROM alpine:3.10.1

COPY --from=build /app/deps /app/deps
COPY --from=build /usr/local/bin/janet /usr/local/bin/
COPY . /app
WORKDIR /app

CMD ["/usr/local/bin/janet", "/app/myserver.janet"]
