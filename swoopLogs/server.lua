local proxy = module("vrp", "lib/Proxy")
vRP = proxy.getInterface("vRP")

local discordHook = ""

function getDiscordProfileID(source)
    local discordID = nil
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in next, identifiers do
        if string.find(identifier, "discord:") then
            discordID = identifier
            break
        end
    end
    if discordID == nil then
        return 0
    end

    if string.find(discordID, "discord:") then
        discordID = string.sub(discordID, 9)
        return discordID
    else
        return 0
    end
end

function getSteamProfileID(source)
    local steamHex = nil
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in next, identifiers do
        if string.find(identifier, "steam:") then
            steamHex = identifier
            break
        end
    end
    if not steamHex then
        return 0
    end
    if not string.find(steamHex, "steam:") then
        return 0
    end
    local steamId = tonumber(string.gsub(steamHex,"steam:", ""),16)
    if not steamId then
        return 0
    end
    return steamId
end

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
	deferrals.defer()
    local _source = source
    
	deferrals.update('Tjekker steam')
	Citizen.Wait(100)

	local allowed = false
	local steamNumber
	for number,id in ipairs(GetPlayerIdentifiers(_source)) do
		if string.find(id, "steam:") then
			allowed = true
			steamNumber = number
			break
		end
	end

    if allowed and steamNumber == 1 then
        deferrals.done()
        Citizen.Wait(60000)
        local steamID = getSteamProfileID(_source)
        local discordID = getDiscordProfileID(_source)
        local userID = vRP.getUserId({_source})

        if steamID == nil or steamID == 0 then steamID = "Kunne ikke findes! brug spillerID" end
        if discordID == nil or discordID == 0 then discordID = "Kunne ikke findes! brug spillerID" end
        if userID == nil or userID == 0 then userID = "Kunne ikke findes!" end
        local dname = "[DU] Spiller tilsluttede"
        local dmessage = "```\nID: " .. userID .. 
                         "\nSteam: " .. steamID .. 
                         "\nDiscord: " .. discordID .. "\n```"	
        PerformHttpRequest(discordHook, function(err, text, headers) end, 'POST', json.encode({username = dname, content = dmessage}), { ['Content-Type'] = 'application/json' })

	elseif steamNumber ~= 1 then
		deferrals.done('Kunne ikke finde dit korrekte steam ID | Genstart venligst dit spil samt steam')
	else
		deferrals.done('Steam er påkrævet for at spille på Danish Universe')
	end
end)