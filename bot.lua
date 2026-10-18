local telegramBot = require("TelegramApi.TelegramApiConfigure")
local AmazonScraping = require("ScappingClasses.AmazonScrapinClass")
local mercadoClass = require("ScappingClasses.MercadoLivreSrapinClass")

local botBotado = telegramBot:new()

local function sendMercadoLivreTextProduct(url)
    local outText = {}
    local classeMercado = mercadoClass:new(url)

    local polyContent = classeMercado:polyContent()

    local title = classeMercado:title() -- obrigatorio
    local picture = classeMercado:picture() -- obrigatorio
    local currentPrice = classeMercado:currentPrice(polyContent) -- obrigatorio

    local previousPrice = classeMercado:previousPrice(polyContent) -- não obrigatorio
    local discountPercentage = classeMercado:discountPercentage(polyContent) -- não obrigatorio
    local priceInstallments = classeMercado:priceInstallments(polyContent) -- não obrigatorio

    if previousPrice == "" then
        outText = {
        text = "<b>" .. title .. "</b>" ..
        "\n\n" .. "POR APENAS: " .. currentPrice .. "\n"..
        (priceInstallments == "" and "" or priceInstallments) ..
        "\n\nACESSANDO PELO LINK: " .. url ..
        "\n\n!!&#129421;Promoção sujeita a alteração, aproveite&#129421;!!",
        imageUrl = picture
    }
    else
        outText = {
        text = "<b>" .. title .. "</b>" ..
        "\n\n" .. "DE: " .. "<del>" .. previousPrice .. "</del>"  ..
        "\nPARA: " ..  "<b>" .. currentPrice .. "</b>"  ..
        " " .. (discountPercentage == "" and "" or discountPercentage .. "\n") ..
        (priceInstallments == "" and "" or priceInstallments) ..
        "\n\nACESSANDO PELO LINK: " .. url ..
        "\n\n!!&#129421;Promoção sujeita a alteração, aproveite&#129421;!!",
        imageUrl = picture
    }
    end

    return outText
end


local function sendAmazonTextProduct(url)
    local outText = {}

    local amazonClass = AmazonScraping:new(url)
    local root, centerCol = amazonClass:parseHtmlCenter()
    local title = amazonClass:productTitle(centerCol)
    local price = amazonClass:price(centerCol)
    local fromPrice = amazonClass:fromPrice(centerCol)
    local urlImage = amazonClass:productImage(root)
    local bestOffer = amazonClass:bestOffer(centerCol)
    local bestOfferText = string.gsub(bestOffer, "&nbsp;", "")

    if fromPrice == false then
        outText = {
            text = "<b>" .. title .. "</b>" .. "\n" ..
            "\nPOR APENAS: " .. price ..
            "\n".. bestOfferText ..
            "\nACESSANDO PELO LINK: " .. url..
            "\n!!&#129421;Promoção sujeita a alteração, aproveite&#129421;!!",
            imageUrl = urlImage
        }
    else

        outText = {
            text = "<b>" .. title .. "</b>" ..
            "\n\n" .. "DE: " .. "<del>" .. fromPrice .. "</del>" .. "\n"
            .. "PARA: " .. "<b>" .. price .. "</b>"  ..
            "\n" .. bestOfferText ..
            "\n\nACESSANDO PELO LINK: " .. url ..
            "\n\n!!&#129421;Promoção sujeita a alteração, aproveite&#129421;!!",
            imageUrl = urlImage
        }
    end

    return outText
end

local function process_update(update)
    if update.message then
        local chat_id = update.message.chat.id
        local text    = update.message.text or ""
        local cmd, arg = text:match("([^%s]+)%s+(.+)")

        if cmd == "/amazon" then
            if string.match(arg, "https://amzn.to/") then
                local amazon = sendAmazonTextProduct(arg)
                botBotado:send_photo(chat_id, amazon.imageUrl, amazon.text, {parse_mode = 'HTML'})
            else
                botBotado:send_message(chat_id, "o link amazon é incompatível, deve conter pelo menos https://amzn.to/")
            end
        elseif cmd == "/mercadolivre" then
            if string.match(arg, "https://meli.la/") then
                local mercadoLivre = sendMercadoLivreTextProduct(arg)
                botBotado:send_photo(chat_id, mercadoLivre.imageUrl, mercadoLivre.text, {parse_mode = 'HTML'})
            else
                botBotado:send_message(chat_id, "o link mercadolivre é incompatível, deve conter pelo menos https://meli.la/")
            end
        elseif cmd == "/sair" then
            botBotado:send_message(chat_id, "saindo(eu não sai verdadeiramente) &#128123; &#128123;", {parse_mode = 'HTML'})
        else
            botBotado:send_message(chat_id, "Primeiramente saiba que o bot tem apenas UMA funcionalidade, escolha ela abaixo \n" ..
            "/mercadolivre {link} para fazer um anuncio mercado livre a partir de um link \n" ..
            "/amazon {link} para fazer um anuncio amazon a partir de um link\n" ..
            "/sair para sair")
        end
    end
end


return { process_update = process_update }
