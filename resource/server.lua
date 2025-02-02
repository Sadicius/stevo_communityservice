lib.versionCheck('stevoscriptsteam/stevo_communityservice')
if not lib.checkDependency('stevo_lib', '1.7.4') then error('stevo_lib version 1.7.4 is required for stevo_communityservice to work!') return end
local stevo_lib = exports['stevo_lib']:import()
local config = lib.require('config')
local insertSQL = [[CREATE TABLE IF NOT EXISTS `stevo_communityservice` (`id` INT NOT NULL AUTO_INCREMENT,`identifier` VARCHAR(50) NOT NULL,`actions` VARCHAR(8) NOT NULL, PRIMARY KEY (`id`))]]
local selectSQL = 'SELECT 1 FROM stevo_communityservice'
lib.locale()


RegisterNetEvent('stevo_communityservice:sentencePlayer')
AddEventHandler('stevo_communityservice:sentencePlayer', function (playerid, sentence) 
    local src = source

    if not DoesPlayerExist(playerid) then 
        TriggerClientEvent('stevo_communityservice:notifyPlayer', src, locale("notify.targetDoesntExist"), 'warning', 3000)
        return 
    end 

    local targetName = stevo_lib.GetName(playerid)
    local identifier = stevo_lib.GetIdentifier(playerid)
    local existingSentence = MySQL.single.await('SELECT actions FROM `stevo_communityservice` WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })

    if existingSentence then 
        TriggerClientEvent('stevo_communityservice:notifyPlayer', src, locale("notify.targetAlreadySentenced"), 'warning', 3000)
        return 
    end
    

    local sentenced = MySQL.insert.await(
        'INSERT INTO `stevo_communityservice` (identifier, actions) VALUES (@identifier, @actions)',
        {
            ['@identifier'] = identifier,
            ['@actions'] = sentence
        }
    )

    if sentenced then 
        TriggerClientEvent('stevo_communityservice:notifyPlayer', src, locale("notify.sentencedTarget", targetName), 'success', 3000)
        TriggerClientEvent('stevo_communityservice:sentencePlayer', playerid, sentence)
    end
end)

RegisterNetEvent('stevo_communityservice:finishedService')
AddEventHandler('stevo_communityservice:finishedService', function () 
    if Player(source).stevo_comserv ~= 0 then 
        if config.dropCheaters then 
            DropPlayer(source, 'Trying to exploit stevo_communityservice')
        end 
    end

    local identifier = stevo_lib.GetIdentifier(source)
    local existingSentence = MySQL.single.await('SELECT actions FROM `stevo_communityservice` WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })

    if not existingSentence then 
        return 
    end

    MySQL.query('DELETE FROM `stevo_communityservice` WHERE identifier = ?', { identifier })
end)


lib.callback.register('stevo_communityservice:fetchSentence', function()

    local identifier = stevo_lib.GetIdentifier(source)
    local actions = MySQL.query.await('SELECT `actions` from `stevo_communityservice` WHERE `identifier` = ?', {
        identifier
    })

    if actions and #actions > 0 then 
        actions = actions[1].actions
    else 
        actions = nil 
    end 
    return actions
end)


AddEventHandler('onResourceStart', function(resource)
    
    if resource ~= cache.resource then return end

    local tableExists, _ = pcall(MySQL.scalar.await, selectSQL)

    if not tableExists then
        MySQL.query(insertSQL)

        lib.print.info('[Stevo Scripts] Deployed database table for stevo_communityservice')
    end
end)




 