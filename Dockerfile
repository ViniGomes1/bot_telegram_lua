FROM alpine:3.20

RUN apk add --no-cache \
    lua5.3 \
    lua5.3-dev \
    luarocks5.3 \
    curl \
    build-base \
    openssl-dev

RUN luarocks-5.3 install luasec
RUN luarocks-5.3 install luasocket
RUN luarocks-5.3 install lua-cjson
RUN luarocks-5.3 install htmlparser

WORKDIR /app
COPY . .

COPY start-server.sh /start-server.sh
RUN chmod +x /start-server.sh

CMD ["/start-server.sh"]