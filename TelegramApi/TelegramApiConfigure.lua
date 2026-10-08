-- TelegramApiConfigure.lua
local cjson = require("cjson")
local https = require("ssl.https")
local ltn12 = require("ltn12")

local TelegramApiConfigure = {}
TelegramApiConfigure.__index = TelegramApiConfigure

function TelegramApiConfigure:new()
    local self = setmetatable({}, TelegramApiConfigure)
    local token = os.getenv("TELEGRAM_TOKEN")
    --
    if not token then
        error("TELEGRAM_TOKEN não definido!")
    end
    self.api_url = "https://api.telegram.org/bot" .. token
    return self
end

local function post_json(url, payload_table)
    local body = cjson.encode(payload_table)
    local response_body = {}

    local res, code, headers, status = https.request({
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#body),
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response_body),
    })

    if not res or (code and code >= 400) then
        local err_msg = table.concat(response_body)
        io.stderr:write("Erro HTTP (" .. tostring(code) .. "): " .. err_msg .. "\n")
        return nil, err_msg
    end

    return table.concat(response_body)
end

function TelegramApiConfigure:send_message(chat_id, text, opts)
    opts = opts or {}
    local payload = {
        chat_id = chat_id,
        text = text,
        parse_mode = opts.parse_mode,
    }
    return post_json(self.api_url .. "/sendMessage", payload)
end

function TelegramApiConfigure:send_photo(chat_id, photo, caption, opts)
    opts = opts or {}
    local payload = {
        chat_id = chat_id,
        photo = photo,
        caption = caption,
        parse_mode = opts.parse_mode,
    }
    return post_json(self.api_url .. "/sendPhoto", payload)
end

return TelegramApiConfigure