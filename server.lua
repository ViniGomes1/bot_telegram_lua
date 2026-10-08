local socket = require("socket")
local cjson = require("cjson")

-- Carrega o módulo do bot
local ok, bot = pcall(require, "bot")
if not ok then
    io.stderr:write("Erro ao carregar bot.lua: " .. tostring(bot) .. "\n")
end

local port = tonumber(os.getenv("PORT")) or 10000
local server = assert(socket.bind("0.0.0.0", port))
print("Servidor Lua ouvindo na porta " .. port .. "...")

while true do
    -- O processo fica ocioso aqui até receber uma conexão TCP
    local client = server:accept()
    client:settimeout(10)

    local request_line = client:receive("*l")
    if request_line then
        local method, path = request_line:match("^(%a+)%s+(%S+)")
        local content_length = 0

        -- Lê os headers HTTP
        while true do
            local line = client:receive("*l")
            if not line or line == "" then break end
            local key, val = line:match("^([^:]+):%s*(.*)$")
            if key and key:lower() == "content-length" then
                content_length = tonumber(val) or 0
            end
        end

        -- Se for a rota do webhook
        if method == "POST" and path == "/webhook" then
            local body = ""
            if content_length > 0 then
                body = client:receive(content_length) or ""
            end

            -- Responde 200 OK de imediato ao Telegram
            local response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 2\r\nConnection: close\r\n\r\nOK"
            client:send(response)
            client:close()

            -- Processa o update do Telegram
            if body ~= "" and bot and bot.process_update then
                local ok_json, update = pcall(cjson.decode, body)
                if ok_json then
                    local ok_proc, err = pcall(bot.process_update, update)
                    if not ok_proc then
                        io.stderr:write("Erro no process_update: " .. tostring(err) .. "\n")
                    end
                end
            end
        else
            -- Rota padrão / healthcheck do Render
            local res = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 2\r\nConnection: close\r\n\r\nOK"
            client:send(res)
            client:close()
        end
    else
        client:close()
    end
end