local playerCount = 0
local playerList = {}
local runnersDead = 0
local playerReady = 0
local runningInProgress = false
local placing = 0
local runnersTeam = 0
local copsTeam = 0
local runnerWon = 0
local cops = {}
local runners = {}

local function SetTeam()
    --a tester a plusieurs:
    --team = math.random(1,2)
    --if team == 1 then
    --elseif team == 2 then
    if runnersTeam == copsTeam then 
        copsTeam = copsTeam + 1
        print("nombre de flics: "..copsTeam)
        print("nombre de runners: "..runnersTeam)
        TriggerClientEvent('hc:setTeamCop', source)
        TriggerClientEvent("chatMessage", source, '', { 0, 0, 0 }, "^0* Tu es ^4Flic!")
        if not cops[source] then
            cops[source] = true 
        elseif runners[source] then
            runners[source] = nil
        end
    elseif runnersTeam ~= copsTeam then
        runnersTeam = runnersTeam + 1
        print("nombre de flics: "..copsTeam)
        print("nombre de runners: "..runnersTeam)
        TriggerClientEvent('hc:setTeamRunner', source)
        TriggerClientEvent("chatMessage", source, '', { 0, 0, 0 }, "^0* Tu es ^1Runner!")
        if not runners[source] then
            runners[source] = true 
        elseif cops[source] then
            cops[source] = nil
        end
    end
end

RegisterServerEvent('hc:newTeam')
AddEventHandler('hc:newTeam', function()
    SetTeam()
end)

RegisterServerEvent('hc:firstJoin')
AddEventHandler('hc:firstJoin', function()
    playerCount = playerCount + 1
    print("nombre de joueur: "..playerCount)
    TriggerClientEvent('hc:numOfPlayers', -1, playerCount)
    name = GetPlayerName(source)
    TriggerClientEvent("chatMessage", n, '', { 0, 0, 0 }, "^1* Numero "..source.." et nom "..name)
    SetTeam()
    if not playerList[source] then
        playerList[source] = true
    end
    if runningInProgress then
        TriggerClientEvent('hc:joinSpectate', source)
    else
        TriggerClientEvent('hc:selectCar', source)
    end
end)


RegisterServerEvent('hc:carSelected')
AddEventHandler('hc:carSelected', function()
--  Wait(500)
    placing = playerReady + 1
    TriggerClientEvent('hc:startingBlock', source, placing)
end)

RegisterServerEvent('hc:plyReady')
AddEventHandler('hc:plyReady', function()
    playerReady = playerReady + 1
    print("PLayer Ready: "..playerReady)
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* "..playerReady.."/^2"..playerCount.."^1 prêt(s)")
    if playerReady == playerCount then
        print("Go Go Go")
        TriggerClientEvent('hc:startRun', -1)
        runningInProgress = true
    end
end)

RegisterServerEvent('hc:damageRunner')
AddEventHandler('hc:damageRunner', function(n)
    TriggerClientEvent('hc:runnerTouched', n)
    local name = GetPlayerName(source)
    TriggerClientEvent("chatMessage", n, '', { 0, 0, 0 }, "^0* Tu t'es fais ^1Touché ^0par "..name)
end)

RegisterServerEvent('hc:runnerWon')
AddEventHandler('hc:runnerWon', function()
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* Les Runners ont gagné!")
    runnerWon = runnerWon + 1
    if runnerWon == runnersTeam then
        TriggerClientEvent('hc:endRun', -1)
        TriggerClientEvent('hc:selectCar', -1)
        runnersDead = 0
        playerReady = 0
        runningInProgress = false
        copsTeam = 0
        runnersTeam = 0
        runnerWon = 0
    end
end)

RegisterServerEvent('hc:runnerDead')
AddEventHandler('hc:runnerDead', function()
	runnersDead = runnersDead + 1
    local name = GetPlayerName(source)
	TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* "..name.." s'est fait avoir!!!")
    TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* plus que "..runnersTeam.." runners!!")
	print(source.." est mort")
    if runnersTeam == runnersDead then
		TriggerClientEvent('hc:endRun', -1)
		runnersDead = 0
        playerReady = 0
		runningInProgress = false
		TriggerClientEvent("chatMessage", -1, '', { 0, 0, 0 }, "^1* Nombre de joueur mort: "..runnersDead)
        TriggerClientEvent('hc:selectCar', -1)
        copsTeam = 0
        runnersTeam = 0
        runnerWon = 0
	else
		TriggerClientEvent('hc:joinSpectate', source)
	end
end)


AddEventHandler('playerDropped', function()
    playerCount = playerCount - 1
    if playerList[source] then
        playerList[source] = nil
        print("nombre de joueur: "..playerCount)
    end
    if playerReady ~= 0 then
        playerReady = playerReady - 1
    end
    if runners[source] then
        runners[source] = nil
        runnersTeam = runnersTeam - 1
        print("nombre de runner: "..runnersTeam)
    elseif cops[source] then
        cops[source] = nil
        copsTeam = copsTeam - 1
        print("nombre de cop: "..copsTeam)
    end
    if runnersTeam == 0 then
        runningInProgress = false
        TriggerClientEvent('hc:endRun', -1)
        TriggerClientEvent('hc:selectCar', -1)
        TriggerClientEvent('hc:numOfPlayers', -1, playerCount)
    end
end)