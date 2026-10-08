local mercadoClass = require("ScappingClasses.MercadoLivreSrapinClass")

local classeMercado = mercadoClass:new("https://meli.la/2Jby9Xh")
local polyContent = classeMercado:polyContent()
print(classeMercado:title())
print(classeMercado:picture())
print(classeMercado:currentPrice(polyContent))
print(classeMercado:previousPrice(polyContent))
print(classeMercado:discountPercentage(polyContent))
print(classeMercado:priceInstallments(polyContent))

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
