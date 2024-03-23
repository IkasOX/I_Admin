ESX = exports["es_extended"]:getSharedObject()

_k = Citizen

local id = GetPlayerServerId(PlayerId())
local name = GetPlayerFromServerId(PlayerId())
local playerName = GetPlayerName(PlayerId())
local grade = ESX.PlayerData.job.grade_name
local money = ESX.PlayerData.money
local GetPlayer = GetActivePlayers()
local playerSrc = PlayerPedId(id)
local coords = GetEntityCoords(playerSrc)
local ifservice = false
local options = nil
local nbreport = 0
local conumber = 0
local rpec = 0
local nbpec = 0
local report_disabled = true

---@class Players
k.Players = {} or {}
k.PlayersStaff = {} or {}
---@class GamerTags
k.GamerTags = {} or {};

annonceD = false
teleportationD = false
pedD = false
propsD = false
serveurD = false
joueursD = false

function RetrievePlayersDataByID(source)
  local player = {};
  for i, v in pairs(k.Players) do
      if (v.source == source) then
          player = v;
      end
  end
  return player;
end

local recoverPlayerSkin = function()
  ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
    local isMale = skin.sex == 0
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
            TriggerEvent('esx:restoreLoadout')
        end)
  end)
end

function RespawnPed(ped, coords, heading)
  SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
  NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
  SetPlayerInvincible(ped, false)
  ClearPedBloodDamage(ped)

  TriggerEvent('esx_basicneeds:resetStatus')
  TriggerServerEvent('esx:onPlayerSpawn')
  TriggerEvent('esx:onPlayerSpawn')
  TriggerEvent('playerSpawned') -- compatibility with old scripts, will be removed soon
end

function EndDeathCam()
  ClearFocus()
  RenderScriptCams(false, false, 0, true, false)
  DestroyCam(cam, false)
  cam = nil
end

local choosePed = function()
  local input = lib.inputDialog('Menu Ped', {{label = 'Nom du Ped', description = 'Cherche "Ped model" et inscris le nom du ped.', type = 'input'}, {label = 'Enlever', type = 'checkbox'}})
  if input[2] then
    recoverPlayerSkin()
  end
  local player = PlayerId()
  local pedHash = GetHashKey(input[1])
  RequestModel(pedHash)
  while not HasModelLoaded(pedHash) do
    Citizen.Wait(1)
  end
  SetPlayerModel(player, pedHash)
  SetModelAsNoLongerNeeded(pedHash)
  lib.notify({
    title = 'Administration',
    description = 'le ped : '..input[1]..' a bien été chargé !',
    position = 'top',
    duration = '500',
    style = {
        backgroundColor = '#141517',
        color = '#FFFFFF',
        ['.description'] = {
          color = '#909296'
        },
    },  
    type = 'success',
  })
end

RegisterNetEvent('annonce_ttm')
AddEventHandler('annonce_ttm', function()
  PlaySoundFrontend(-1, "CHARACTER_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
end)

function service()
  if ifservice == true then
    options = {
      {
        title = 'Service',
        description = 'Statut actuel : En service',
        icon = 'toggle-on',
        iconColor = '#E8FFE1',
        onSelect = function()
          ifservice = false
          Wait(100)
          service()
        end
      },
      {
        title = ' ',
        progress = '100',
      },
      {
        title = 'Personnel',
        description = 'Affecte que vous.',
        icon = 'user',
        iconColor = '#FFDDD2',
        onSelect = function()
          Wait(100)
          lib.showContext('perso')
        end
      },
      {
        title = 'Reports',
        description = 'Nombres de reports : '..nbreport,
        icon = 'paper-plane',
        iconColor = '#E1F3FF',
        onSelect = function()
          Wait(100)
          lib.showContext('reports_admin')
        end
      },
      {
        title = "Véhicule",
        description = 'Gestion véhicule.',
        icon = 'car-side',
        onSelect = function()
          Wait(100)
          lib.showContext('gestion_veh')
        end,
      },
      {
        title = 'Annonce',
        description = 'Envoie une notification a tout le serveur.',
        icon = 'bullhorn',
        iconColor = '#E2E2FF',
        disabled = annonceD,
        onSelect = function()
            local input = lib.inputDialog('Annonce', {{label = 'Titre', description = 'Envoie une annonce à tout le serveur !', icon = 'bullhorn', type = 'input'}, {label = 'Accepter', type = 'checkbox', required = true}})
            local annonce = input[1]
            if input[1] then
              TriggerServerEvent('notifevery', annonce)
              TriggerServerEvent('sendDiscordAnnonce', message, id, annonce)
            end
        end,
      },
      {
        title = ' ',
        progress = '100',
      },
      {
        title = 'Gestion joueurs',
        description = 'Acceder à la gestion des joueurs.',
        icon = 'gear',
        arrow = true,
        iconColor = '#D2FFD4',
        onSelect = function()
          TriggerEvent('list')
        end,
      },     
    }
    lib.registerContext({
      id = 'administration',
      title = 'Administration',
      options = options
    })
    lib.showContext('administration')
    TriggerEvent('connexion')
    for _, player in ipairs(GetActivePlayers()) do
      local ped = GetPlayerPed(player)
      local formatted;
      local group = 0;
      local permission = 0;
      local fetching = RetrievePlayersDataByID(GetPlayerServerId(player));
      if fetching.group ~= nil then
          if fetching.group ~= "user" then
              formatted = string.format('[' .. gamertag[fetching.group] .. '] %s | %s [%s]', GetPlayerName(player), GetPlayerServerId(player), ESX.PlayerData.job.name)
          else
              formatted = string.format('[%d] %s [%s]', GetPlayerServerId(player), GetPlayerName(player), ESX.PlayerData.job.name)
          end
      else
          formatted = string.format('[%d] %s [%s]', GetPlayerServerId(player), GetPlayerName(player), ESX.PlayerData.job.name)
      end
      if (fetching) then
          group = fetching.group
          permission = fetching.permission
      end

      k.GamerTags[ped] = {
          player = player,
          ped = ped,
          group = group,
          permission = permission,
          tags = CreateFakeMpGamerTag(ped, formatted)
      };
    end
    ifservice = true
    if conumber == 0 then 
    conumber = conumber + 1
    end
    if conumber == 1 then
      PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 1)
      rpec = 0
      if k.ped == true then
      local player = PlayerId()
      local pedHash = GetHashKey(k.ped_model)
      RequestModel(pedHash)
      while not HasModelLoaded(pedHash) do
        Citizen.Wait(1)
      end
      SetPlayerModel(player, pedHash)
      SetModelAsNoLongerNeeded(pedHash)
      end
    TriggerServerEvent('sendDiscordMessage', message, id)
    Wait(300)
    print("Connection : " .. playerName)
    lib.notify({
      title = 'Administration',
      description = "Statut actuel : En service",
      position = 'top',
      duration = '500', -- 5000 millisecondes (5 secondes)
      style = {
        backgroundColor = '#141517',
        color = '#FFFFFF',
        ['.description'] = {
          color = '#909296'
        },
      },
      icon = 'toggle-on',
      iconColor = '#E8FFE1',
    })
    conumber = conumber + 1
    end
  elseif ifservice == false then
    options = {
      {
        title = 'Service',
        description = 'Statut actuel : Hors service',
        icon = 'toggle-off',
        iconColor = '#FFDEDE',
        onSelect = function()
          ifservice = true
          Wait(100)
          service()
        end
      }
    }
    lib.registerContext({
      id = 'on_staff',
      title = 'Administration',
      options = options
    })
    lib.showContext('on_staff')
    local pedHash = GetHashKey(k.ped_model)
    local hash = GetEntityModel(PlayerPedId())
    if hash == pedHash then
      ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        local isMale = skin.sex == 0
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                TriggerEvent('skinchanger:loadSkin', skin)
                TriggerEvent('esx:restoreLoadout')
            end)
      end)
    end
    for i, v in pairs(k.GamerTags) do
    RemoveMpGamerTag(v.tags)
    end
    ifservice = false
    if conumber == 2 then
    PlaySoundFrontend(-1, "Click", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
    TriggerServerEvent('sendDiscordMessageOff', message, id)
    Wait(300)
    print("Déconnection : " ..playerName)
    lib.notify({
      title = 'Administration',
      description = "Statut actuel : Hors service",
      position = 'top',
      duration = '500',
      style = {
          backgroundColor = '#141517',
          color = '#FFFFFF',
          ['.description'] = {
            color = '#909296'
          },
      },  
      icon = 'toggle-off',
      iconColor = '#FFDEDE',
    })
    end
    conumber = 0
  end
end

RegisterNetEvent('ReportNotification')
AddEventHandler('ReportNotification', function(id, reason, name)
  if ifservice then
      PlaySoundFrontend(-1, "On_Call_Player_Join", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
      lib.notify({
        title = 'Administration',
        description = "Nouveau report :"..
        "\n- ID : "..id..
        "\n- Raison : "..reason,
        position = 'top',
        duration = '500',
        style = {
            backgroundColor = '#141517',
            color = '#FFFFFF',
            ['.description'] = {
              color = '#909296'
            },
        },  
      })
  end
  nbreport = nbreport + 1
end)

RegisterNetEvent('TakeReportNotification')
AddEventHandler('TakeReportNotification', function(id, name)
  if ifservice then
      PlaySoundFrontend(-1, "CHALLENGE_UNLOCKED", "HUD_AWARDS", 1)
      lib.notify({
        title = 'Administration',
        description = "Report de l'ID ["..id.."] pris en charge par "..name,
        position = 'top',
        duration = '750',
        style = {
            backgroundColor = '#141517',
            color = '#FFFFFF',
            ['.description'] = {
              color = '#909296'
            },
        },  
      })
  end
end)

RegisterNetEvent('ReportNotificationDelete')
AddEventHandler('ReportNotificationDelete', function()
  if ifservice then
      PlaySoundFrontend(-1, "Click", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
  end
  nbreport = nbreport - 1
end)

local options_reports = {} -- Initialisation des tables en dehors des fonctions
local gestion_reports = {}
local stats_reports_option = {}

RegisterCommand("report", function(source, args, rawCommand)
    local src = source
    local input = lib.inputDialog('Report', {{label = 'Raison', description = 'Indique la raison du report.', type = 'input'}})
    local id = GetPlayerServerId(PlayerId()) -- Supposant que le premier argument est l'ID du joueur signalé
    local reason = input[1] -- Supposant que les arguments restants sont la raison du signalement
    local name = GetPlayerName(id)
    if reason then
        TriggerServerEvent('insert_report', id, reason, name)
    else
        print("Utilisation : /report [ID du joueur] [Raison du report]")
    end
end)

local oldpos = nil
local specatetarget = nil
local specateactive = false

function spectate(target)
    if not oldpos then
        TriggerServerEvent("teleport", target)
        oldpos = GetEntityCoords(GetPlayerPed(PlayerId()))
		    SetEntityVisible(GetPlayerPed(PlayerId()), false)
        specatetarget = target
        specateactive = true
    else
        SetEntityCoords(GetPlayerPed(PlayerId()), oldpos.x, oldpos.y, oldpos.z)
        SetEntityVisible(GetPlayerPed(PlayerId()), true)
        SetEntityCollision(GetPlayerPed(PlayerId()), true, true)
        specatetarget = nil
        oldpos = nil
        specateactive = false
    end
end

RegisterNetEvent('teleport')
AddEventHandler('teleport', function(coords)
  ESX.Game.Teleport(PlayerPedId(), coords)
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if IsControlJustPressed(0, 56) then -- https://docs.fivem.net/docs/game-references/controls/ pour changer la touche, to change the key
      TriggerServerEvent('get_perms_admin_stats')
      RegisterNetEvent("player_has_admin_perms_stats")
      AddEventHandler("player_has_admin_perms_stats", function(hasPerms)
      if hasPerms then
        if ifservice then
          lib.registerContext({
            id = "stats_report",
            title = 'Logs reports',
            options = stats_reports_option,
          })
          lib.showContext("stats_report")
        else
          Wait(300)
          lib.notify({
            title = 'Administration',
            description = 'Vous n\'êtes pas en service',
            position = 'top',
            duration = '500', -- 5000 millisecondes (5 secondes)
            style = {
              backgroundColor = '#141517',
              color = '#FFFFFF',
              ['.description'] = {
                color = '#909296'
              },
            },
          })
        end
      else
        Wait(300)
        lib.notify({
          title = 'Administration',
          description = 'Vous n\'avez pas les permissions nécessaires',
          position = 'top',
          duration = '500', -- 5000 millisecondes (5 secondes)
          style = {
            backgroundColor = '#141517',
            color = '#FFFFFF',
            ['.description'] = {
              color = '#909296'
            },
          },
        })
      end
      end)
    end
  end
end)

RegisterNetEvent('show_report_menu')
AddEventHandler('show_report_menu', function(reports)
    ESX.TriggerServerCallback('get_reports', function(reports)
        options_reports = {} -- Réinitialisation des options
        gestion_reports = {}
            for k, v in pairs(reports) do
              table.insert(options_reports, {
                title = v.reason,
                description = 'ID du joueur : '..v.pID,
                onSelect = function()
                    Wait(100)
                    buildReportSubMenu(v)
                end,    
              })
              function buildReportSubMenu(v)
                lib.registerContext({
                  id = "report_nb" .. v.id,
                  title = 'Gestion du report',
                  menu = 'reports_admin',
                  options = {
                    {
                      title = 'Informations : '..v.name,
                      description = "ID : " .. v.pID .. "\n" .. "Raison : " .. v.reason,
                      icon = 'circle-info',
                    },
                    {
                      title = 'Prendre en charge',
                      description = "Prend en charge ce report.",
                      icon = 'hand',
                      onSelect = function()
                        local id = GetPlayerServerId(PlayerId())
                        local playerPEC = GetPlayerName(PlayerId())
                        local iddr = v.id
                        local name = v.name
                        local pID = v.pID
                        local reason = v.reason
                        if rpec == 0 then
                          lib.progressCircle({
                            duration = 1100,
                            position = 'bottom',
                            canCancel = false,
                          })
                          TriggerServerEvent('prise_en_charge', playerPEC, id, iddr, name, pID, reason)
                          lib.showContext("reports_admin")
                          rpec = rpec + 1
                        else
                          local alert = lib.alertDialog({
                            header = 'Administration',
                            content = 'Vous ne pouvez pas prendre en charge plusieurs reports en même temps !',
                            centered = true,
                            cancel = true
                          })
                          Wait(100)
                          lib.showContext("report_nb" .. v.id)
                        end
                      end,
                    },
                    {
                      title = ' ',
                      progress = '100'
                    },
                    {
                      title = 'Goto - Back',
                      description = 'Permet de se téléporter sur '..v.name..'.',
                      icon = 'person-walking-arrow-right',
                      onSelect = function()
                        local input = lib.inputDialog('Goto - Back', {{label = 'Goto', type = 'checkbox'}, {label = 'Back', type = 'checkbox'}})
                        if input[1] then
                          local id = v.pID
                          TriggerServerEvent('function_joueurs', 'goto', id)
                          Wait(100)
                          lib.showContext("report_nb" .. v.id)
                        elseif input [2] then
                          local id = v.pID
                          TriggerServerEvent('function_joueurs', 'gotoback', id)
                          Wait(100)
                          lib.showContext("report_nb" .. v.id)
                        end
                      end,
                    },
                    {
                      title = 'Bring - Back',
                      description = 'Permet de téléporter '..v.name..' sur toi.',
                      icon = 'people-arrows',
                      onSelect = function()
                        local input = lib.inputDialog('Bring - Back', {{label = 'Bring', type = 'checkbox'}, {label = 'Back', type = 'checkbox'}})
                        if input[1] then
                          local id = v.pID
                          TriggerServerEvent('function_joueurs', 'bring', id)
                          Wait(100)
                          lib.showContext("report_nb" .. v.id)
                        elseif input [2] then
                          local id = v.pID
                          TriggerServerEvent('function_joueurs', 'bringback', id)
                          Wait(100)
                          lib.showContext("report_nb" .. v.id)
                        end
                      end,
                    },
                    {
                      title = "Revive",
                      description = 'Permet de revive '..v.name..'.',
                      icon = 'user-nurse',
                      onSelect = function()
                          TriggerServerEvent('esx_ambulancejob:revive', v.pID)
                          Wait(100)
                          lib.showContext("report_nb" .. v.id)
                      end,
                    },
                    { 
                      title = "Heal",
                      description = 'Permet de heal '..v.name..'.',
                      icon = 'notes-medical',
                      onSelect = function()
                          TriggerServerEvent('esx_ambulancejob:heal', v.pID)
                          Wait(100)
                          lib.showContext("report_nb" .. v.id)
                      end,
                    },
                    {
                      title = 'Warn',
                      description = 'Envoie un warn.',
                      icon = 'triangle-exclamation',
                      onSelect = function()
                          local input = lib.inputDialog('Warn', {{label = 'Motif', type = 'input', description = 'Entre un motif valable.', required = true}, {label = 'Accepter', type = 'checkbox', required = true}})
                          local target = v.pID
                          local warn = input[1]
                          TriggerServerEvent('send_warn', target, warn)
                          Wait(100)
                          lib.showContext("report_nb" .. v.id)
                      end,
                    },
                    { 
                      title = "Spectate",
                      description = 'Permet de regarder '..v.name..'.',
                      icon = 'eye',
                      onSelect = function()
                          spectate(v.pID)
                          Wait(100)
                          lib.showContext("report_nb" .. v.id)
                      end,
                    },
                    { 
                      title = ' ',
                      progress = '100'
                    },
                    {
                      title = 'Clôturer',
                      description = 'Supprime ce report définitivement.',
                      icon = 'trash',
                      onSelect = function()
                        local input = lib.inputDialog('Clôturer', {{label = 'Raison', type = 'input', description = 'Entre une raison valable pour clôturer le report.'}, {label = 'Accepter', type = 'checkbox', required = true}})
                        if input then
                          TriggerServerEvent('sendDiscordMessageCloture', message, id, input[1])
                          TriggerServerEvent('delete_report', v.id)
                          ESX.TriggerServerCallback('get_prise_en_charge', function(reports_PEC)
                            for k, v in pairs(reports_PEC) do
                            TriggerServerEvent('delete_stats_report', v.id)
                            end
                          end)
                          rpec = rpec - 1
                          lib.progressCircle({
                            duration = 1100,
                            position = 'bottom',
                            canCancel = false,
                          })
                          lib.notify({
                            title = 'Administration',
                            description = 'Report de l\'ID : ['..v.pID..'] à bien été supprimé.',
                            position = 'top',
                            duration = '500',
                            style = {
                                backgroundColor = '#141517',
                                color = '#FFFFFF',
                                ['.description'] = {
                                  color = '#909296'
                                },
                            },  
                          })
                          service()
                          lib.showContext('reports_admin')
                        else
                          Wait(100)
                          lib.showContext("report_nb" .. v.id)
                        end
                      end
                    }
                  },
                  onBack = function()
                    lib.showContext('reports_admin')
                  end
                })
                lib.showContext("report_nb" .. v.id)
              end
          end
          lib.registerContext({
            id = "reports_admin",
            title = 'Reports',
            menu = 'administration',
            options = options_reports
        })
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        ESX.TriggerServerCallback('get_reports', function(reports)
            TriggerEvent('show_report_menu', reports)
        end)
    end
end)

RegisterNetEvent('show_report_PEC')
AddEventHandler('show_report_PEC', function(reports_PEC)
    ESX.TriggerServerCallback('get_prise_en_charge', function(reports_PEC)
      stats_reports_option = {}
            for k, v in pairs(reports_PEC) do
              table.insert(stats_reports_option, {
                title = "Report pris en charge par : "..v.playerPEC,
                description = 'ID du staff : '..v.PECid,
                icon = "hand",
                onSelect = function()
                  Wait(100)
                  buildStatsSubMenu(v)
                end
              })
              function buildStatsSubMenu(v)
                lib.registerContext({
                  id = "report_stats_gestion" .. v.id,
                  title = 'Gestion',
                  menu = "stats_report",
                  options = {
                    {
                      title = 'Informations : '..v.name,
                      description = "ID : " .. v.pID .. "\n" .. "Raison : " .. v.reason,
                      icon = 'circle-info',
                    },
                    { 
                      title = ' ',
                      progress = '100'
                    },
                    {
                      title = 'Regarder',
                      description = 'Permet de se téléporter sur '..v.name..'.',
                      icon = 'eye',
                      onSelect = function()
                          local command = "goto " .. v.pID
                          ExecuteCommand(command)
                          Wait(100)
                          lib.showContext("report_stats_gestion" .. v.id)
                      end,
                    },
                    {
                      title = 'Warn',
                      description = 'Envoie un warn.',
                      icon = 'triangle-exclamation',
                      onSelect = function()
                          local input = lib.inputDialog('Warn', {{label = 'Motif', type = 'input', description = 'Entre un motif valable.', required = true}, {label = 'Accepter', type = 'checkbox', required = true}})
                          local target = v.pID
                          local warn = input[1]
                          TriggerServerEvent('send_warn', target, warn)
                          Wait(100)
                          lib.showContext("report_stats_gestion" .. v.id)
                      end,
                    },
                    { 
                      title = ' ',
                      progress = '100'
                    },
                    {
                      title = 'Clôturer',
                      description = 'Supprime le report en cours.',
                      icon = 'trash',
                      onSelect = function()
                        local input = lib.inputDialog('Clôturer', {{label = 'Raison', type = 'input', description = 'Entre une raison valable pour clôturer le report.', required = true}, {label = 'Accepter', type = 'checkbox', required = true}})
                        if input then
                          TriggerServerEvent('delete_report', v.iddr)
                          TriggerServerEvent('delete_stats_report', v.id)
                          lib.progressCircle({
                            duration = 1100,
                            position = 'bottom',
                            canCancel = false,
                          })
                          lib.registerContext({
                            id = "stats_report",
                            title = 'Logs reports',
                            options = stats_reports_option,
                          })
                          lib.showContext("stats_report")
                        else
                          Wait(100)
                          lib.showContext("report_stats_gestion" .. v.id)
                        end
                      end
                    },
                  },
                  onBack = function()
                    lib.showContext("stats_report")
                  end
                })
                lib.showContext("report_stats_gestion" .. v.id)
              end
            end
          lib.registerContext({
            id = "stats_report",
            title = 'Statistiques',
            options = stats_reports_option,
          })
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        ESX.TriggerServerCallback('get_prise_en_charge', function(reports_PEC)
            TriggerEvent('show_report_PEC', reports_PEC)
        end)
    end
end)

lib.registerContext({
  id = "perso",
  title = 'Personnel',
  menu = "administration",
  options = {
    {
      title = "Informations",
      description = 'Ce sont tes informations.',
      icon = 'circle-info',
      metadata = {
        {label = 'Id ', value = ' '..id},
        {label = 'Grade ', value = ' '..grade},
        {label = 'Money ', value = ' '..money},
        {label = 'Name ', value = ' '..playerName},
        {label = 'Coords '},
        {label = ' '..coords},
      },
      onSelect = function()
        print('Id : '..id..' | Grade : '..grade..' | Money : '..money..' | Name : '..playerName..' | Coords : '..coords)
        lib.showContext('perso')
      end,
    },
    {
      title = ' ',
      progress = '100',
    },
    {
      title = "Noclip",
      icon = 'person-falling',
      description = 'Activer ou désactiver le noclip.',
      onSelect = function()
        local input = lib.inputDialog('Noclip', {{label = 'Activer', type = 'checkbox'}, {label = 'Désactiver', type = 'checkbox'}})
        if input[1] then
          ExecuteCommand('+noclip')
        elseif input [2] then
          ExecuteCommand('-noclip')
        end
      end,
    },
    {       
      title = 'Ped',
      description = 'Permet de choisir un Ped.',
      icon = 'people-arrows',
      disabled = pedD,
      onSelect = function()
          choosePed()
      end,
    },
    { 
      title = 'Props',
      description = 'Ajouter des props.',
      icon = 'box',
      disabled = propsD,  
      onSelect = function()
          lib.showContext('props')
      end,
    },
    {
      title = "Téléporter au marker",
      description = 'Se téléporter au marker instantanément.',
      icon = 'location-dot',
      onSelect = function()
        ExecuteCommand('tpm')
      end,
    },
    {
      title = "Santé",
      description = 'Permet de se revive ou de se heal.',
      icon = 'kit-medical',
      onSelect = function()
        local input = lib.inputDialog('Santé', {{label = 'Revive', type = 'checkbox'}, {label = 'Heal', type = 'checkbox'}})
        if input[1] then
          TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(PlayerId()))
        elseif input [2] then
          TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(PlayerId()))
        end
      end,
    },
    {
      title = ' ',
      progress = '100',
    },
    {
      title = "Give",
      description = 'Permet de se give des items.',
      icon = 'circle-plus',
      onSelect = function()
        local input = lib.inputDialog('Menu Give', {{label = 'Item', type = 'input', icon = 'bookmark', description = 'Que veut-tu te give ?', required = true}, {label = 'Nombre', type = 'number', min = '0', max = '10000', icon = 'hashtag', description = 'Combien d\'items ?', required = true}, {type = 'checkbox', label = 'Accepter', checked = false, required = true}})
        local item = input[1]
        local amount = input[2]
        TriggerServerEvent('give', item, amount)
        lib.notify({
          id = 'success_give',
          title = 'Administration',
          description = 'Give réussi !',
          position = 'top',
          duration = '500',
          style = {
              backgroundColor = '#141517',
              color = '#FFFFFF',
              ['.description'] = {
                color = '#909296'
              },
          },  
          type = 'success',
        })
      end,
    },
  }
})

lib.registerContext({
  id = "gestion_veh",
  title = 'Gestion Véhicule',
  menu = 'administration',
  options = {
    {
      title = 'Spawn',
      description = 'Fait spawn n\'importe quel véhicule.',
      icon = 'plus',
      onSelect = function()
        local input = lib.inputDialog('Spawn Véhicule', {{label = 'Véhicule', type = 'input', icon = 'car', description = 'Renseigne le nom du véhicule.'}})
        local veh_model = input[1]
        local GetVeh = GetVehiclePedIsIn(PlayerPedId(), false) 
        local HashVeh = GetEntityModel(GetVeh)
        local vehicleModel = GetHashKey(veh_model)
        Wait(100)
        RequestModel(veh_model)
        while not HasModelLoaded(veh_model) do
          Citizen.Wait(1)
        end
        if HasModelLoaded(veh_model) then
          lib.notify({
            title = 'Administration',
            description = 'Modèle valide : '..veh_model,
            position = 'top',
            duration = '500',
            style = {
                backgroundColor = '#141517',
                color = '#FFFFFF',
                ['.description'] = {
                  color = '#909296'
                },
            },  
            type = 'success',
          })
        end
        local source = source
        local player = PlayerPedId(source)
        local veh_coords = GetEntityCoords(player)
        local veh_Heading = 100
        local veh = CreateVehicle(vehicleModel, veh_coords, veh_Heading, true, false)
          Wait(100)
          local seatIndex = -1
          TaskWarpPedIntoVehicle(player, veh, seatIndex)
      end,
    },
    {
      title = "Réparer",
      description = 'Répare ton véhicule.',
      icon = 'wrench',
      onSelect = function()
        local vehicule = GetVehiclePedIsIn(GetPlayerPed(-1), false)

        if DoesEntityExist(vehicule) and not IsEntityDead(vehicule) then
            -- Répare le véhicule
            SetVehicleFixed(vehicule)
            SetVehicleDeformationFixed(vehicule)
            SetVehicleUndriveable(vehicule, false)
            SetVehicleEngineOn(vehicule, true, true)
            lib.notify({
              title = 'Administration',
              description = 'Réparation réussite !',
              position = 'top',
              duration = '500',
              style = {
                  backgroundColor = '#141517',
                  color = '#FFFFFF',
                  ['.description'] = {
                    color = '#909296'
                  },
              },  
              type = 'success',
            })
          else
            lib.notify({
              title = 'Administration',
              description = 'Vous n\'êtes pas dans un véhicule !',
              position = 'top',
              duration = '500',
              style = {
                  backgroundColor = '#141517',
                  color = '#FFFFFF',
                  ['.description'] = {
                    color = '#909296'
                  },
              },  
              type = 'error',
            })
        end
      end,
    },
    {
      title = "Améliorer",
      description = 'Améliore ton véhicule au maximum.',
      icon = 'arrow-up-right-dots',
      onSelect = function()
        local vehicule = GetVehiclePedIsIn(PlayerPedId(), false)

        -- Vérifie si le joueur est dans un véhicule
        if DoesEntityExist(vehicule) and not IsEntityDead(vehicule) then
            -- Améliore les performances du véhicule au maximum
            SetVehicleModKit(vehicule, 0) -- Modifie le kit de modification (0 pour le kit primaire)
            
            -- Améliorations moteur
            ToggleVehicleMod(vehicule, 11, true)
            ToggleVehicleMod(vehicule, 12, true)
            ToggleVehicleMod(vehicule, 13, true)
            ToggleVehicleMod(vehicule, 14, true)
            ToggleVehicleMod(vehicule, 15, true)
      
            -- Améliorations transmission
            ToggleVehicleMod(vehicule, 16, true)
            ToggleVehicleMod(vehicule, 17, true)
            ToggleVehicleMod(vehicule, 18, true)
      
            -- Améliorations suspension
            ToggleVehicleMod(vehicule, 19, true)
            ToggleVehicleMod(vehicule, 20, true)
            ToggleVehicleMod(vehicule, 21, true)
      
            -- Améliorations freins
            ToggleVehicleMod(vehicule, 22, true)
            ToggleVehicleMod(vehicule, 23, true)
      
            -- Améliorations boÃ®te de vitesses
            ToggleVehicleMod(vehicule, 24, true)
      
            -- Ajout des néons
            ToggleVehicleMod(vehicule, 25, true) -- Avant
            ToggleVehicleMod(vehicule, 26, true) -- Arrière
            ToggleVehicleMod(vehicule, 27, true) -- CÃ´té gauche
            ToggleVehicleMod(vehicule, 28, true) -- CÃ´té droit
      
            -- Active les néons sous le véhicule
            SetVehicleNeonLightEnabled(vehicule, 0, true) -- Avant
            SetVehicleNeonLightEnabled(vehicule, 1, true) -- Arrière
            SetVehicleNeonLightEnabled(vehicule, 2, true) -- CÃ´té gauche
            SetVehicleNeonLightEnabled(vehicule, 3, true) -- CÃ´té droit
      
            lib.notify({
              title = 'Administration',
              description = 'Amélioration du véhicule réusit !',
              position = 'top',
              duration = '500',
              style = {
                  backgroundColor = '#141517',
                  color = '#FFFFFF',
                  ['.description'] = {
                    color = '#909296'
                  },
              },  
              type = 'success',
            })
          else
            lib.notify({
              title = 'Administration',
              description = 'Vous n\'êtes pas dans un véhicule !',
              position = 'top',
              duration = '500',
              style = {
                  backgroundColor = '#141517',
                  color = '#FFFFFF',
                  ['.description'] = {
                    color = '#909296'
                  },
              },  
              type = 'error',
            })
        end
      end,
    },
    {
      title = ' ',
      progress = '100',
    },
    {
      title = 'Supprimer',
      description = 'Permet de supprimer ton véhicule !',
      icon = 'trash',
      onSelect = function()
        local GetVeh = GetVehiclePedIsIn(PlayerPedId(), false) 
        local HashVeh = GetEntityModel(GetVeh)
        local test = IsPedInAnyVehicle(PlayerPedId(), false)
        Wait(100)
        if test then
          DeleteEntity(GetVeh)
          lib.notify({
            title = 'Administration',
            description = 'Votre véhicule a été supprimé',
            position = 'top',
            duration = '500',
            style = {
                backgroundColor = '#141517',
                color = '#FFFFFF',
                ['.description'] = {
                  color = '#909296'
                },
            },  
            type = 'success',
          })
          else
            lib.notify({
              title = 'Administration',
              description = 'Vous n\'êtes pas dans un véhicule',
              position = 'top',
              duration = '500',
              style = {
                  backgroundColor = '#141517',
                  color = '#FFFFFF',
                  ['.description'] = {
                    color = '#909296'
                  },
              },  
              type = 'error',
            })
        end
      end,
    },
  }
})

RegisterNetEvent('list')
AddEventHandler('list', function()
    ESX.TriggerServerCallback('getplayers', function(player)
        local players = GetActivePlayers()
        local menu = {}

        if player ~= nil then
          for i=1, #player, 1 do
                table.insert(menu, {
                    title = player[i].name,
                    description = 'ID : ' ..player[i].source..' | Job : '..player[i].job,
                    progress = '100',
                    onSelect = function()
                      Wait(100)
                      buildJoueurSubMenu(i)
                    end,
                })
                function buildJoueurSubMenu(i)
                lib.registerContext({
                  id = "joueurs" .. i,
                  title = 'Gestion joueurs',
                  menu = "list",
                  options = {
                    {
                      title = 'Informations',
                      description = "Nom : " ..player[i].name .. "\n" .. "ID : " .. player[i].source,
                      icon = 'circle-info',
                    },
                    {
                      title = ' ',
                      progress = '100',
                    },
                    {
                      title = "Goto - Back",
                      description = 'Se téléporter sur '..player[i].name..'.',
                      icon = 'person-hiking',
                      onSelect = function()
                        local input = lib.inputDialog('Goto - Back', {{label = 'Goto', type = 'checkbox'}, {label = 'Back', type = 'checkbox'}})
                        if input[1] then
                          local id = player[i].source
                          TriggerServerEvent('function_joueurs', 'goto', id)
                          Wait(100)
                          lib.showContext("joueurs" .. i)
                        elseif input [2] then
                          local id = player[i].source
                          TriggerServerEvent('function_joueurs', 'gotoback', id)
                          Wait(100)
                          lib.showContext("joueurs" .. i)
                        end
                      end,
                    },
                    {
                      title = "Bring - Back",
                      description = 'téléporter '..player[i].name..' sur toi.',
                      icon = 'person-walking-arrow-loop-left',
                      onSelect = function() 
                        local input = lib.inputDialog('Bring - Back', {{label = 'Bring', type = 'checkbox'}, {label = 'Back', type = 'checkbox'}})
                        if input[1] then
                          local id = player[i].source
                          TriggerServerEvent('function_joueurs', 'bring', id)
                          Wait(100)
                          lib.showContext("joueurs" .. i)
                        elseif input [2] then
                          local id = player[i].source
                          TriggerServerEvent('function_joueurs', 'bringback', id)
                          Wait(100)
                          lib.showContext("joueurs" .. i)
                        end
                      end,
                    },
                    {
                      title = "Spectate",
                      icon = 'eye',
                      description = 'Permet de regarder '..player[i].name..'.',
                      onSelect = function()
                        spectate(player[i].source)
                        Wait(100)
                        lib.showContext("joueurs" .. i)
                      end,
                    },
                    {
                      title = "Revive",
                      icon = 'kit-medical',
                      description = 'Permet de se revive '..player[i].name..'.',
                      onSelect = function()
                        TriggerServerEvent('esx_ambulancejob:revive',  player[i].source)
                        Wait(100)
                        lib.showContext("joueurs" .. i)
                      end,
                    },
                    {
                      title = "Heal",
                      icon = 'notes-medical',
                      description = 'Soigner '..player[i].name..'.',
                      onSelect = function()
                        TriggerServerEvent('esx_ambulancejob:heal',  player[i].source)
                        Wait(100)
                        lib.showContext("joueurs" .. i)
                      end,
                    },
                    {
                      title = "Freeze",
                      description = 'Freeze '..player[i].name..'.',
                      icon = 'person',
                      onSelect = function()
                        local id = player[i].source
                        TriggerServerEvent('function_joueurs', 'freeze', id)
                        Wait(100)
                        lib.showContext("joueurs" .. i)
                      end,
                    },
                    {
                      title = "UnFreeze",
                      icon = 'person-walking',
                      description = 'UnFreeze '..player[i].name..'.',
                      onSelect = function()
                        local id = player[i].source
                        TriggerServerEvent('function_joueurs', 'unfreeze', id)
                        Wait(100)
                        lib.showContext("joueurs" .. i)
                      end,
                    },
                    {
                      title = ' ',
                      progress = '100',
                    },
                    {
                      title = 'Warn',
                      description = 'Envoie un warn à '..player[i].name..'.',
                      icon = 'triangle-exclamation',
                      onSelect = function()
                          local input = lib.inputDialog('Warn', {{label = 'Motif', type = 'input', description = 'Entre un motif valable.', required = true}, {label = 'Accepter', type = 'checkbox', required = true}})
                          local target = player[i].source
                          local warn = input[1]
                          TriggerServerEvent('send_warn', target, warn)
                          Wait(100)
                          lib.showContext("joueurs" .. i)
                      end,
                    },
                  }
                })
                lib.showContext("joueurs" .. i)
              end
            end

            lib.registerContext({
                id = 'list',
                title = 'Liste des joueurs',
                menu = 'administration',
                options = menu
            })

            if #menu ~= 0 then
              lib.showContext('list')
            else
                lib.notify({
                    title = 'Administration',
                    description = 'Aucun joueurs en ligne !',
                    position = 'top',
                    duration = '500', -- 5000 millisecondes (5 secondes)
                    style = {
                        backgroundColor = '#141517',
                        color = '#FFFFFF',
                        ['.description'] = {
                            color = '#909296'
                        },
                    },
                    type = 'error',
                })
            end
        else
            lib.notify({
                title = 'Administration',
                description = 'Aucun joueurs en ligne !',
                position = 'top',
                duration = '500', -- 5000 millisecondes (5 secondes)
                style = {
                    backgroundColor = '#141517',
                    color = '#FFFFFF',
                    ['.description'] = {
                        color = '#909296'
                    },
                },
                type = 'error',
            })
        end
    end)
end)

optionsProps = {}

for k,v in pairs(k.props) do
    table.insert(optionsProps, {
        title = v.label, 
        description = 'Model: '..v.model,
        onSelect = function()
            local playerPed = PlayerPedId()
            local wait = 1500
            local _src = source 
            SpawnObj(v.model)
            local nameprops = v.label
            ExecuteCommand("e pickup")
            FreezeEntityPosition(playerPed, true)
            Wait(wait)
            ClearPedTasks(playerPed)
            FreezeEntityPosition(playerPed, false)
            lib.notify({
              title = 'Administration',
              description = 'Vous avez fait spawn : ' ..nameprops,
              position = 'top',
              duration = '500',
              style = {
                  backgroundColor = '#141517',
                  color = '#FFFFFF',
                  ['.description'] = {
                    color = '#909296'
                  },
              },  
              type = 'success',
            })
        end
    })
end

lib.registerContext({
  menu = 'administration',
  id = 'props',
  title = 'Catégorie Props',
  options = optionsProps
})

-- Liste des noms d'administrateurs autorisés

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if IsControlJustPressed(0, 57) then -- https://docs.fivem.net/docs/game-references/controls/ pour changer la touche, to change the key
      TriggerServerEvent('get_perms_admin')
      RegisterNetEvent("player_has_admin_perms")
      AddEventHandler("player_has_admin_perms", function(hasPerms)
          if hasPerms then
            service()
          else
            Wait(300)
            lib.notify({
              title = 'Administration',
              description = 'Vous n\'avez pas les permissions nécessaires',
              position = 'top',
              duration = '500', -- 5000 millisecondes (5 secondes)
              style = {
                backgroundColor = '#141517',
                color = '#FFFFFF',
                ['.description'] = {
                  color = '#909296'
                },
              },
            })
          end
      end)
    end
  end
end)

RegisterCommand('meteo', function()
    local input = lib.inputDialog('Météo', {{label = 'Heure', type = 'checkbox'}, {label = 'Temps', type = 'checkbox'}})
    if input[1] then
      local input = lib.inputDialog('Heure', {{label = 'Matin', type = 'checkbox'}, {label = 'Midi', type = 'checkbox'}, {label = 'Soir', type = 'checkbox'}})
      if input[1] then
        TriggerServerEvent('matin')
      elseif input[2] then
        TriggerServerEvent('midi')
      elseif input[3] then
        TriggerServerEvent('soir')
      end
    elseif input[2] then
      local input = lib.inputDialog('Temps', {{label = 'Pluie', type = 'checkbox'}, {label = 'Soleil', type = 'checkbox'}, {label = 'Nuageux', type = 'checkbox'}, {label = 'Neige', type = 'checkbox'}})
      if input[1] then
        TriggerServerEvent('pluie')
      elseif input[2] then
        TriggerServerEvent('soleil')
      elseif input[3] then
        TriggerServerEvent('nuage')
      elseif input[4] then
        TriggerServerEvent('neige')
      end
    end
end)

local noclip = false
local noclip_speed = 1.5

MOVE_UP_KEY = 20
MOVE_DOWN_KEY = 44
CHANGE_SPEED_KEY = 21
MOVE_LEFT_RIGHT = 30
MOVE_UP_DOWN = 31
NOCLIP_TOGGLE_KEY = 289
NO_CLIP_NORMAL_SPEED = k.speed.noclip_normal
NO_CLIP_FAST_SPEED = k.speed.noclip_run
ENABLE_TOGGLE_NO_CLIP = true
ENABLE_NO_CLIP_SOUND = true

local eps = 0.01
local RESSOURCE_NAME = GetCurrentResourceName();

STARTUP_STRING = ('%s v%s initialized'):format(RESSOURCE_NAME, GetResourceMetadata(RESSOURCE_NAME, 'version', 0))
STARTUP_HTML_STRING = (':business_suit_levitating: %s <small>v%s</small> initialized'):format(RESSOURCE_NAME, GetResourceMetadata(RESSOURCE_NAME, 'version', 0))

-- Variables --
local isNoClipping = false
local playerPed = PlayerPedId()
local playerId = PlayerId()
local speed = NO_CLIP_NORMAL_SPEED
local input = vector3(0, 0, 0)
local previousVelocity = vector3(0, 0, 0)
local breakSpeed = 10.0;
local offset = vector3(0, 0, 1);

local noClippingEntity = playerPed;

function ToggleNoClipMode()
    return SetNoClip(not isNoClipping)
end

function IsControlAlwaysPressed(inputGroup, control) return IsControlPressed(inputGroup, control) or IsDisabledControlPressed(inputGroup, control) end

function IsControlAlwaysJustPressed(inputGroup, control) return IsControlJustPressed(inputGroup, control) or IsDisabledControlJustPressed(inputGroup, control) end

function Lerp (a, b, t) return a + (b - a) * t end

function IsPedDrivingVehicle(ped, veh)
    return ped == GetPedInVehicleSeat(veh, -1);
end

function SetInvincible(val, id)
    SetEntityInvincible(id, val)
    return SetPlayerInvincible(id, val)
end

function SetNoClip(val)

    if (isNoClipping ~= val) then

        noClippingEntity = playerPed;

        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false);
            if IsPedDrivingVehicle(playerPed, veh) then
                noClippingEntity = veh;
            end
        end

        local isVeh = IsEntityAVehicle(noClippingEntity);

        isNoClipping = val;

        if ENABLE_NO_CLIP_SOUND then

            if isNoClipping then
                PlaySoundFromEntity(-1, "SELECT", playerPed, "HUD_LIQUOR_STORE_SOUNDSET", 0, 0)
            else
                PlaySoundFromEntity(-1, "CANCEL", playerPed, "HUD_LIQUOR_STORE_SOUNDSET", 0, 0)
            end

        end

        TriggerEvent('msgprinter:addMessage', ((isNoClipping and ":airplane: No-clip enabled") or ":rock: No-clip disabled"), GetCurrentResourceName());
        SetUserRadioControlEnabled(not isNoClipping);

        if (isNoClipping) then

            TriggerEvent('instructor:add-instruction', { MOVE_LEFT_RIGHT, MOVE_UP_DOWN }, "move", RESSOURCE_NAME);
            TriggerEvent('instructor:add-instruction', { MOVE_UP_KEY, MOVE_DOWN_KEY }, "move up/down", RESSOURCE_NAME);
            TriggerEvent('instructor:add-instruction', { 1, 2 }, "Turn", RESSOURCE_NAME);
            TriggerEvent('instructor:add-instruction', CHANGE_SPEED_KEY, "(hold) fast mode", RESSOURCE_NAME);
            TriggerEvent('instructor:add-instruction', NOCLIP_TOGGLE_KEY, "Toggle No-clip", RESSOURCE_NAME);
            SetEntityAlpha(noClippingEntity, 51, 0)

            -- Start a No CLip thread
            Citizen.CreateThread(function()

                local clipped = noClippingEntity
                local pPed = playerPed;
                local isClippedVeh = isVeh;
                -- We start with no-clip mode because of the above if --
                SetInvincible(true, clipped);

                if not isClippedVeh then
                    ClearPedTasksImmediately(pPed)
                end

                while isNoClipping do
                    Citizen.Wait(0);

                    FreezeEntityPosition(clipped, true);
                    SetEntityCollision(clipped, false, false);

                    SetEntityVisible(clipped, false, false);
                    SetLocalPlayerVisibleLocally(true);
                    SetEntityAlpha(clipped, 51, false)

                    SetEveryoneIgnorePlayer(pPed, true);
                    SetPoliceIgnorePlayer(pPed, true);

                    -- `(a and b) or c`, is basically `a ? b : c` --
                    input = vector3(GetControlNormal(0, MOVE_LEFT_RIGHT), GetControlNormal(0, MOVE_UP_DOWN), (IsControlAlwaysPressed(1, MOVE_UP_KEY) and 1) or ((IsControlAlwaysPressed(1, MOVE_DOWN_KEY) and -1) or 0))
                    speed = ((IsControlAlwaysPressed(1, CHANGE_SPEED_KEY) and NO_CLIP_FAST_SPEED) or NO_CLIP_NORMAL_SPEED) * ((isClippedVeh and 2.75) or 1)

                    MoveInNoClip();

                end

                Citizen.Wait(0);

                FreezeEntityPosition(clipped, false);
                SetEntityCollision(clipped, true, true);

                SetEntityVisible(clipped, true, false);
                SetLocalPlayerVisibleLocally(true);
                ResetEntityAlpha(clipped);

                SetEveryoneIgnorePlayer(pPed, false);
                SetPoliceIgnorePlayer(pPed, false);
                ResetEntityAlpha(clipped);

                Citizen.Wait(500);

                -- We're done with the while so we aren't in no-clip mode anymore --
                -- Wait until the player starts falling or is completely stopped --
                if isClippedVeh then

                    while (not IsVehicleOnAllWheels(clipped)) and not isNoClipping do
                        Citizen.Wait(0);
                    end

                    while not isNoClipping do

                        Citizen.Wait(0);

                        if IsVehicleOnAllWheels(clipped) then

                            -- We hit land. We can safely remove the invincibility --
                            return SetInvincible(false, clipped);

                        end

                    end

                else

                    if (IsPedFalling(clipped) and math.abs(1 - GetEntityHeightAboveGround(clipped)) > eps) then
                        while (IsPedStopped(clipped) or not IsPedFalling(clipped)) and not isNoClipping do
                            Citizen.Wait(0);
                        end
                    end

                    while not isNoClipping do

                        Citizen.Wait(0);

                        if (not IsPedFalling(clipped)) and (not IsPedRagdoll(clipped)) then

                            -- We hit land. We can safely remove the invincibility --
                            return SetInvincible(false, clipped);

                        end

                    end

                end

            end)

        else
            ResetEntityAlpha(noClippingEntity)
            TriggerEvent('instructor:flush', RESSOURCE_NAME);
        end

    end

end

function MoveInNoClip()

    SetEntityRotation(noClippingEntity, GetGameplayCamRot(0), 0, false)
    local forward, right, up, c = GetEntityMatrix(noClippingEntity);
    previousVelocity = Lerp(previousVelocity, (((right * input.x * speed) + (up * -input.z * speed) + (forward * -input.y * speed))), Timestep() * breakSpeed);
    c = c + previousVelocity
    SetEntityCoords(noClippingEntity, c - offset, true, true, true, false)

end

function MoveCarInNoClip()

    SetEntityRotation(noClippingEntity, GetGameplayCamRot(0), 0, false)
    local forward, right, up, c = GetEntityMatrix(noClippingEntity);
    previousVelocity = Lerp(previousVelocity, (((right * input.x * speed) + (up * input.z * speed) + (forward * -input.y * speed))), Timestep() * breakSpeed);
    c = c + previousVelocity
    SetEntityCoords(noClippingEntity, (c - offset) + (vec(0, 0, .3)), true, true, true, false)

end

AddEventHandler('playerSpawned', function()

    playerPed = PlayerPedId()
    playerId = PlayerId()

end)

AddEventHandler('RCC:newPed', function()

    playerPed = PlayerPedId()
    playerId = PlayerId()

end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == RESSOURCE_NAME then
        SetNoClip(false);
        FreezeEntityPosition(noClippingEntity, false);
        SetEntityCollision(noClippingEntity, true, true);

        SetEntityVisible(noClippingEntity, true, false);
        SetLocalPlayerVisibleLocally(true);
        ResetEntityAlpha(noClippingEntity);

        SetEveryoneIgnorePlayer(playerPed, false);
        SetPoliceIgnorePlayer(playerPed, false);
        ResetEntityAlpha(noClippingEntity);
        SetInvincible(false, noClippingEntity);
    end
end)

Citizen.CreateThread(function()

    print("{ Ika's }")
    TriggerEvent('msgprinter:addMessage', STARTUP_HTML_STRING, GetCurrentResourceName());

    if ENABLE_TOGGLE_NO_CLIP then

        RegisterCommand("+noClip", function(source, rawCommand)
            if ifservice == true then
              SetNoClip(true)
            end
        end)
        RegisterCommand("-noClip", function(source, rawCommand)
            if ifservice == true then
              SetNoClip(false)
            end
        end)

        RegisterCommand("toggleNoClip", function(source, rawCommand)
            if ifservice == true then
              ToggleNoClipMode()
            end
        end)
    end

end)

function SpawnObj(obj)
  local playerPed = PlayerPedId()
  local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
  local objectCoords = (coords + forward * 1.0)
  local Ent = nil

  SpawnObject(obj, objectCoords, function(obj)
      SetEntityCoords(obj, objectCoords, 0.0, 0.0, 0.0, 0)
      SetEntityHeading(obj, GetEntityHeading(playerPed))
      PlaceObjectOnGroundProperly(obj)
      Ent = obj
      Wait(1)
  end)
  Wait(1)
  while Ent == nil do Wait(1) end
  SetEntityHeading(Ent, GetEntityHeading(playerPed))
  PlaceObjectOnGroundProperly(Ent)
  local placed = false
  while not placed do
      _k.Wait(1)
      local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
      local objectCoords = (coords + forward * 1.0)
      SetEntityCoords(Ent, objectCoords, 0.0, 0.0, 0.0, 0)
      SetEntityHeading(Ent, GetEntityHeading(playerPed))
      PlaceObjectOnGroundProperly(Ent)
      SetEntityAlpha(Ent, 170, 170)

      if IsControlJustReleased(1, 38) then
          placed = true
      end
  end

  FreezeEntityPosition(Ent, true)
  SetEntityInvincible(Ent, true)
  ResetEntityAlpha(Ent)
end

function SpawnObject(model, coords, cb)
  local model = GetHashKey(model)

  _k.CreateThread(function()
      RequestModels(model)
      Wait(1)
      local obj = CreateObject(model, coords.x, coords.y, coords.z, true, false, true)

      if cb then
          cb(obj)
      end
  end)
end

function RequestModels(modelHash)
  if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
      RequestModel(modelHash)

      while not HasModelLoaded(modelHash) do
          _k.Wait(1)
      end
  end
end