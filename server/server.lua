ESX = exports["es_extended"]:getSharedObject()
exports('sendDiscordMessage', sendDiscordMessage)

RegisterServerEvent("get_perms_admin")
AddEventHandler("get_perms_admin", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerGroup = xPlayer.getGroup()

        for _, group in ipairs(k.groups) do
            if playerGroup == group then
                TriggerClientEvent("player_has_admin_perms", source, true)
                return
            end
        end
    end
    TriggerClientEvent("player_has_admin_perms", source, false)
end)

RegisterServerEvent("get_perms_admin_stats")
AddEventHandler("get_perms_admin_stats", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerGroup = xPlayer.getGroup()

        for _, group in ipairs(k.groups) do
            if playerGroup == group then
                TriggerClientEvent("player_has_admin_perms_stats", source, true)
                return
            end
        end
    end
    TriggerClientEvent("player_has_admin_perms_stats", source, false)
end)


RegisterServerEvent("give")
AddEventHandler("give",function(item, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(item, amount)
end)

local gotoCoords = {}
local bringCoords = {}

RegisterServerEvent('function_joueurs') 
AddEventHandler('function_joueurs', function(type, id)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(id)

    for _,v in pairs(k.groups) do
        if xPlayer.getGroup() == v then
                 
            if type == 'goto' then
                if xTarget then
                    gotoCoords[source] = xPlayer.getCoords()
                    xPlayer.setCoords(xTarget.getCoords())
                end
            elseif type == 'gotoback' then
                if gotoCoords[source] then
                    xPlayer.setCoords(gotoCoords[source])
                    gotoCoords[source] = nil
                end

            elseif type == 'bring' then
                if xTarget then
                    bringCoords[id]= xTarget.getCoords()
                    xTarget.setCoords(xPlayer.getCoords())
                end
            elseif type == 'bringback' then
                if xTarget then
                    if bringCoords[id] then
                        xTarget.setCoords(bringCoords[id])
                        bringCoords[id] = nil
                    end
                end
            elseif type == 'freeze' then
                if xTarget then
                    TaskLeaveAnyVehicle(GetPlayerPed(id), 0, 16)
                    FreezeEntityPosition(GetPlayerPed(id), true)
                end
            elseif type == 'unfreeze' then
                if xTarget then
                    FreezeEntityPosition(GetPlayerPed(id), false)
                end
            end
        end
    end
end)

RegisterServerEvent('notifevery')
AddEventHandler('notifevery', function(annonce)
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        TriggerClientEvent('ox_lib:notify', xPlayers[i], {
            id = 'notif',
            title = 'Annonce',
            description = annonce,
            position = 'top',
            duration = '1000',
            style = {
                backgroundColor = '#141517',
                color = '#FFFFFF',
                ['.description'] = {
                  color = '#909296'
                },
            },
            icon = 'bullhorn',
        })
        TriggerClientEvent('annonce_ttm', -1)
    end
end)

RegisterServerEvent('send_warn')
AddEventHandler('send_warn', function(target, warn)
        TriggerClientEvent('ox_lib:notify', target, {
            title = 'Administration',
            description = 'Warn : '..warn,
            position = 'top',
            duration = '1000',
            style = {
                backgroundColor = '#141517',
                color = '#FFFFFF',
                ['.description'] = {
                  color = '#909296'
                },
            },
        })
end)

--SERVER
local report = {}
local stats_charge = {}

RegisterServerEvent('insert_report')
AddEventHandler('insert_report', function(pID, reason, name)
    table.insert(report, {
        reason = reason,
        pID = pID,
        name = GetPlayerName(pID),
    })
    TriggerClientEvent("ReportNotification", -1, pID, reason, name)
end)

ESX.RegisterServerCallback('get_reports', function(source, cb)
    local ReportCB = {}
    for k, v in pairs(report) do
        table.insert(ReportCB, {reason = v.reason, pID = v.pID, name = v.name, id = k})
    end
    cb(ReportCB)
end)

RegisterServerEvent('prise_en_charge')
AddEventHandler('prise_en_charge', function(playerPEC, PECid, iddr, name, pID, reason)
    table.insert(stats_charge, {
        playerPEC = playerPEC,
        PECid = PECid,
        iddr = iddr,
        name = name,
        pID = pID,
        reason = reason,
    })
    TriggerClientEvent("TakeReportNotification", -1, PECid, playerPEC)
end)

ESX.RegisterServerCallback('get_prise_en_charge', function(source, cb)
    local stats_ReportCB = {}
    for k, v in pairs(stats_charge) do
        table.insert(stats_ReportCB, {playerPEC = v.playerPEC, PECid = v.PECid, iddr = v.iddr, name = v.name, pID = v.pID, reason = v.reason, id = k})
    end
    cb(stats_ReportCB)
end)

RegisterServerEvent("teleport")
AddEventHandler("teleport", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= "user" then
        TriggerClientEvent("teleport", source, GetEntityCoords(GetPlayerPed(id)))
    end
end)

RegisterServerEvent('delete_report')
AddEventHandler('delete_report', function(id)
    for k, v in pairs(report) do
        if k == id then
            table.remove(report, id)
        end
    end
    Wait(1100)
    TriggerClientEvent("ReportNotificationDelete", -1)
end)

RegisterServerEvent('delete_stats_report')
AddEventHandler('delete_stats_report', function(id)
    for k, v in pairs(stats_charge) do
        if k == id then
            table.remove(stats_charge, id)
        end
    end
end)

RegisterServerEvent('matin')
AddEventHandler('matin', function()
    ExecuteCommand('time 8 0')
end)

RegisterServerEvent('midi')
AddEventHandler('midi', function()
    ExecuteCommand('time 14 0')
end)

RegisterServerEvent('soir')
AddEventHandler('soir', function()
    ExecuteCommand('time 22 0')
end)

RegisterServerEvent('pluie')
AddEventHandler('pluie', function()
    ExecuteCommand('weather rain')
end)

RegisterServerEvent('soleil')
AddEventHandler('soleil', function()
    ExecuteCommand('weather extrasunny')
end)

RegisterServerEvent('nuage')
AddEventHandler('nuage', function()
    ExecuteCommand('weather clouds')
end)

RegisterServerEvent('neige')
AddEventHandler('neige', function()
    ExecuteCommand('weather xmas')
end)


RegisterNetEvent("sendDiscordMessage")
AddEventHandler("sendDiscordMessage", function(message, id)
    local src = source
    local name = GetPlayerName(src)
    local ids = ExtractIdentifiers(id); -- Grabs targets Identifiers
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
    steam = "https://steamcommunity.com/profiles/"..steamDec;
    local gameLicense = ids.license;
    local discord = ids.discord;

function sendDiscordMessage(message)
    local embed = {
        {
            ["color"] = 15204321,
            ["title"] = "Connexion [ "..GetPlayerName(id).." ]",
            ["description"] = "- **Id :** ``"..id.."``"..
            "\n- **Game License :** ``"..gameLicense..
            "``\n- **Discord :** ``"..discord:gsub('discord:', '')..
            "``\n- **Tag :** <@!"..discord:gsub('discord:', '')..">"..
            "\n- **Steam :** "..steam,
            ["footer"] = {
                ["text"] = "Connexion [ "..GetPlayerName(id).." ] "..os.date("%x %X %p"),
                ["icon_url"] = "https://cdn.discordapp.com/attachments/1178329521158619187/1188096855293296650/Capture_decran_2023-12-23_124340.png?ex=6599486c&is=6586d36c&hm=97ec32bf5ca80b713e8f8a9ef21b33dfc8e1ef5cfe16f4cb3b0338fce3ffc88e&",
            },
        }
    }

    local data = {
        username = "kAdmin",
        embeds = embed,
        avatar_url = "https://cdn.discordapp.com/attachments/1178329521158619187/1188096855293296650/Capture_decran_2023-12-23_124340.png?ex=6599486c&is=6586d36c&hm=97ec32bf5ca80b713e8f8a9ef21b33dfc8e1ef5cfe16f4cb3b0338fce3ffc88e&",
    }

    PerformHttpRequest(k.webhook.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end
sendDiscordMessage()
end)

RegisterNetEvent("sendDiscordMessageCloture")
AddEventHandler("sendDiscordMessageCloture", function(message, id, reason, pID)
    local src = source
    local name = GetPlayerName(src)
    local ids = ExtractIdentifiers(id); -- Grabs targets Identifiers
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
    steam = "https://steamcommunity.com/profiles/"..steamDec;
    local gameLicense = ids.license;
    local discord = ids.discord;

function sendDiscordMessageCloture(message)
    local embed = {
        {
            ["color"] = 15204321,
            ["title"] = "Report de [ "..GetPlayerName(pID).." ] [ "..pID.." ] clÃ´turer par [ "..GetPlayerName(id).." ]",
            ["description"] = "- **Id du Staff : **``"..id.."``"..
            "\n- **Tag du Staff :** <@!"..discord:gsub('discord:', '')..">"..
            "\n**Raison ** ```"..reason.."```",
            ["footer"] = {
                ["text"] = "Report clÃ´turer par [ "..GetPlayerName(id).." ] "..os.date("%x %X %p"),
                ["icon_url"] = "https://cdn.discordapp.com/attachments/1178329521158619187/1188096855293296650/Capture_decran_2023-12-23_124340.png?ex=6599486c&is=6586d36c&hm=97ec32bf5ca80b713e8f8a9ef21b33dfc8e1ef5cfe16f4cb3b0338fce3ffc88e&",
            },
        }
    }

    local data = {
        username = "kAdmin",
        embeds = embed,
        avatar_url = "https://cdn.discordapp.com/attachments/1178329521158619187/1188096855293296650/Capture_decran_2023-12-23_124340.png?ex=6599486c&is=6586d36c&hm=97ec32bf5ca80b713e8f8a9ef21b33dfc8e1ef5cfe16f4cb3b0338fce3ffc88e&",
    }

    PerformHttpRequest(k.webhook.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end
sendDiscordMessageCloture()
end)

RegisterNetEvent("sendDiscordMessageOff")
AddEventHandler("sendDiscordMessageOff", function(message, id)
    local src = source
    local name = GetPlayerName(src)
    local ids = ExtractIdentifiers(id); -- Grabs targets Identifiers
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
    steam = "https://steamcommunity.com/profiles/"..steamDec;
    local gameLicense = ids.license;
    local discord = ids.discord;

function sendDiscordMessageOff(message)
    local embed = {
        {
            ["color"] = 15204321,
            ["title"] = "Déconnexion [ "..GetPlayerName(id).." ]",
            ["description"] = "- **Id :** ``"..id.."``"..
            "\n- **Game License :** ``"..gameLicense..
            "``\n- **Discord :** ``"..discord:gsub('discord:', '')..
            "``\n- **Tag :** <@!"..discord:gsub('discord:', '')..">"..
            "\n- **Steam :** "..steam,
            ["footer"] = {
                ["text"] = "Déconnexion [ "..GetPlayerName(id).." ] "..os.date("%x %X %p"),
                ["icon_url"] = "https://cdn.discordapp.com/attachments/1178329521158619187/1188096855293296650/Capture_decran_2023-12-23_124340.png?ex=6599486c&is=6586d36c&hm=97ec32bf5ca80b713e8f8a9ef21b33dfc8e1ef5cfe16f4cb3b0338fce3ffc88e&",
            },
        }
    }

    local data = {
        username = "kAdmin",
        embeds = embed,
        avatar_url = "https://cdn.discordapp.com/attachments/1178329521158619187/1188096855293296650/Capture_decran_2023-12-23_124340.png?ex=6599486c&is=6586d36c&hm=97ec32bf5ca80b713e8f8a9ef21b33dfc8e1ef5cfe16f4cb3b0338fce3ffc88e&",
    }

    PerformHttpRequest(k.webhook.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end
sendDiscordMessageOff()
end)

RegisterNetEvent("sendDiscordAnnonce")
AddEventHandler("sendDiscordAnnonce", function(message, id, annonce)
    local src = source
    local name = GetPlayerName(src)
    local ids = ExtractIdentifiers(id); -- Grabs targets Identifiers
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
    steam = "https://steamcommunity.com/profiles/"..steamDec;
    local gameLicense = ids.license;
    local discord = ids.discord;

function sendDiscordAnnonce(message)
    local embed = {
        {
            ["color"] = 15204321,
            ["title"] = "Nouvelle annonce de [ "..GetPlayerName(id).." ]",
            ["description"] = "- **Id :** ``"..id.."``"..
            "\n- **Tag :** <@!"..discord:gsub('discord:', '')..">"..
            "\n**Annonce ** ```"..annonce.."```",
            ["footer"] = {
                ["text"] = "Annonce [ "..GetPlayerName(id).." ] "..os.date("%x %X %p"),
                ["icon_url"] = "https://cdn.discordapp.com/attachments/1178329521158619187/1188096855293296650/Capture_decran_2023-12-23_124340.png?ex=6599486c&is=6586d36c&hm=97ec32bf5ca80b713e8f8a9ef21b33dfc8e1ef5cfe16f4cb3b0338fce3ffc88e&",
            },
        }
    }

    local data = {
        username = "kAdmin",
        embeds = embed,
        avatar_url = "https://cdn.discordapp.com/attachments/1178329521158619187/1188096855293296650/Capture_decran_2023-12-23_124340.png?ex=6599486c&is=6586d36c&hm=97ec32bf5ca80b713e8f8a9ef21b33dfc8e1ef5cfe16f4cb3b0338fce3ffc88e&",
    }

    PerformHttpRequest(k.webhook.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end
sendDiscordAnnonce()
end)

RegisterNetEvent("O-Reports:Server")
AddEventHandler("O-Reports:Server", function(pID, reason)
    prefix = " [ Report ] "
    local src = source
    local name = GetPlayerName(src)
    local ids = ExtractIdentifiers(pID); -- Grabs targets Identifiers
    local steam = ids.steam:gsub("steam:", "");
    local steamDec = tostring(tonumber(steam,16));
    steam = "https://steamcommunity.com/profiles/"..steamDec;
    local gameLicense = ids.license;
    local discord = ids.discord;  

    if pID ~= nil and reason ~= nil then
        if GetPlayerIdentifiers(pID)[1] == nil then
            TriggerClientEvent('chatMessage', src, prefix.."\n^1ERREUR: Le joueur report n'est pas en ligne.")
            return false
        else
            TriggerClientEvent('chatMessage', src, prefix.."\nMerci pour ton report, Un membre du staff regleras ceci sous peu.")
                local players = GetAllPlayers()
                for i=1, #players do
                    if IsPlayerAceAllowed(players[i], "O-Reports.view") then
                        TriggerClientEvent('chatMessage', players[i], 
                        prefix.."\n^1Joueur ^1[^3"..pID.."^1] ^3"..GetPlayerName(pID).." ^1a Ã©tÃ© report: ^1[^3"..src.."^1] ^3"..name.." ^1pour: ^3"..reason)
                    end
                end

            if k.webhook.Screenshot then
                exports["discord-screenshot"]:requestCustomClientScreenshotUploadToDiscord(pID,
                k.webhook.DiscordWebhook,
                {
                    encoding = "png",
                    quality = 1
                },
                {
                    embeds = {
                        {
                            ["color"] = 15204321,
                            ["title"] = "Le joueur ["..pID.."] ["..GetPlayerName(pID).."] a crÃ©er un nouveau report",
                            ["description"] = "- **Raison**: ``"..reason.."``"..
                            "\n- **Game License:** ``"..gameLicense..
                            "``\n- **Discord UID:** ``"..discord:gsub('discord:', '')..
                            "``\n- **Discord-Tag:** <@!"..discord:gsub('discord:', '')..">"..
                            "\n- **Steam:** "..steam,
                            ["footer"] = {
                                ["text"] = "Report par: ["..src.."] "..name,
                                ["icon_url"] = "https://cdn.discordapp.com/attachments/1178329521158619187/1188096855293296650/Capture_decran_2023-12-23_124340.png?ex=6599486c&is=6586d36c&hm=97ec32bf5ca80b713e8f8a9ef21b33dfc8e1ef5cfe16f4cb3b0338fce3ffc88e&",
                            },
                        }
                    }
                },
                30000)
            else
                sendToDisc("Le joueur ["..pID.."] ["..GetPlayerName(pID).."] a crÃ©er un nouveau report", 
                "- **Raison**: ``"..reason.."``"..
                "\n- **Game License:** ``"..gameLicense..
                "``\n- **Discord UID:** ``"..discord:gsub('discord:', '')..
                "``\n- **Discord-Tag:** <@!"..discord:gsub('discord:', '')..">"..
                "\n- **Steam:** "..steam,
                "Report par: ["..src.."] "..name)
            end
            return true
        end
    end
end)

-- Functions
function sendToDisc(title, msg, fmsg)
    local embed = {
        {
            ["color"] = 15204321,
            ["title"] = "**".. title .."**",
            ["description"] = msg,
            ["footer"] = {
                ["text"] = fmsg,
                ["icon_url"] = "https://cdn.discordapp.com/attachments/1178329521158619187/1188096855293296650/Capture_decran_2023-12-23_124340.png?ex=6599486c&is=6586d36c&hm=97ec32bf5ca80b713e8f8a9ef21b33dfc8e1ef5cfe16f4cb3b0338fce3ffc88e&",
            },
        }
    }
    PerformHttpRequest(k.webhook.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function GetAllPlayers()
    local players = {}

    for _, i in ipairs(GetPlayers()) do
        table.insert(players, i)    
    end

    return players
end

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

ESX.RegisterServerCallback('getplayers', function(source, cb)
	local allPlayers = ESX.GetPlayers()
	local player  = {}

	for i=1, #allPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(allPlayers[i])
		table.insert(player, {
			source = xPlayer.source,
			identifier = xPlayer.getIdentifier(),
            name = GetPlayerName(allPlayers[i]),
			job = xPlayer.getJob(),
            group = xPlayer.getGroup(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
		})
	end
	cb(player)
end)