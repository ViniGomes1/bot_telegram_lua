#!/bin/sh

echo "Aguardando Splash acordar..."
until curl -sf "$SPLASH_URL" > /dev/null; do
  echo "Splash dormindo, tentando novamente..."
  sleep 5
done
echo "Splash pronto!"

if [ -n "$RENDER_EXTERNAL_URL" ]; then
  echo "Ambiente com Webhook: registrando $RENDER_EXTERNAL_URL..."
  curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setWebhook?url=${RENDER_EXTERNAL_URL}/webhook"
else
  echo "Ambiente local sem URL externa: desativando webhook..."
  curl -s "https://api.telegram.org/bot${TELEGRAM_TOKEN}/deleteWebhook"
fi

exec lua5.3 server.lua
