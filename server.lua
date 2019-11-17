local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
func = {}
Tunnel.bindInterface("vrp_prosegur",func)


function func.giveawards()
    local source = source
    local user_id = vRP.getUserId(source)
    local amount = parseInt(math.random(900,3000))
    vRP.giveMoney(user_id,amount)
end


function func.giveDirtMoney()
    local source = source
    local user_id = vRP.getUserId(source)
    local amount = parseInt(math.random(900,5000))
    vRP.giveInventoryItem(user_id,"dinheirosujo",amount)
end    