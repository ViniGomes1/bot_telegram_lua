local TelegramApiConfigure = require("TelegramApi.TelegramApiConfigure")

local tg = TelegramApiConfigure:new()
tg:send_message("8009230244", "Teste do bot!")