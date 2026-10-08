#!/bin/sh

echo "Aguardando Splash acordar..."
until curl -sf $SPLASH_URL > /dev/null; do
  echo "Splash dormindo, tentando novamente..."
  sleep 5
done
echo "Splash pronto!"

# Registra webhook
curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setWebhook?url=${RENDER_EXTERNAL_URL}/webhook"

exec lua5.3 server.lua