local api = require('telegram-bot-lua').configure(os.getenv("TELEGRAM_TOKEN"))

function api.on_message(message)
    local cmd = api.extract_command(message)
    if cmd and cmd.command == 'start' then
        api.send_reply(message, 'Olá, como começaremos?')
    end
end

api.run({ timeout = 60 })
