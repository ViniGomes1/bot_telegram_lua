-- bot.lua
local cjson = require("cjson")
local http  = require("socket.http")  -- usa resty.http, não socket.http

TelegramApiConfigure = {}
TelegramApiConfigure.__index = TelegramApiConfigure

function TelegramApiConfigure:new()
    local self = setmetatable({}, TelegramApiConfigure)
    local token = os.getenv("TELEGRAM_TOKEN")
    if not token then
        error("TELEGRAM_TOKEN não definido!")
    end
    self.api_url = "https://api.telegram.org/bot" .. token
    return self
end

function TelegramApiConfigure:send_message(chat_id, text, opts)
    opts = opts or {}
    local httpc = http.new()
    local body  = cjson.encode({
        chat_id = chat_id, 
        text = text,
        parse_mode = opts.parse_mode
    })

    local res, err = httpc:request_uri(self.api_url .. "/sendMessage", {
        method  = "POST",
        body    = body,
        headers = {
            ["Content-Type"] = "application/json",
        },
        ssl_verify = false,
    })

    if not res then
        io.stderr:write("Erro ao enviar mensagem: ", err)
    end
end

function TelegramApiConfigure:send_photo(chat_id, photo, caption, opts)
    opts = opts or {}
    local httpc = http.new()
    local body  = cjson.encode({
        chat_id = chat_id, 
        caption = caption,
        photo = photo,
        parse_mode = opts.parse_mode
    })

    local res, err = httpc:request_uri(self.api_url .. "/sendPhoto", {
        method  = "POST",
        body    = body,
        headers = {
            ["Content-Type"] = "application/json",
        },
        ssl_verify = false,
    })

    if not res then
        io.stderr:write("Erro ao enviar mensagem: ", err)
    end
end

return TelegramApiConfigure