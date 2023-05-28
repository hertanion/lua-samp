local function ARGBtoRGB(color) return bit32 or bit.band(color, 0xFFFFFF) end -- from mimgui chat

local function ServerMessage(bs)
    local color = bs:readInt32()
    local msg = bs:readString32()

    color = bit.tohex(ARGBtoRGB(color)):gsub('^00', '')
    chat_pool:add(tonumber(color, 16), msg)
end

local function InitGame(bs)
    local zoneNames = bs:readBool()
    local useCJWalk = bs:readBool()
    local allowWeapons = bs:readBool()
    local limitGlobalChatRadius = bs:readBool()
    local globalChatRadius = bs:readFloat()
    local stuntBonus = bs:readBool()
    local nametagDrawDist = bs:readFloat()
    local disableEnterExits = bs:readBool()
    local nametagLOS = bs:readBool()
    local tirePopping = bs:readBool()
    local classesAvailable = bs:readInt32()
    local playerId = bs:readInt16()
    local showPlayerTags = bs:readBool()
    local playerMarkersMode = bs:readInt32()
    local worldTime = bs:readInt8()
    local worldWeather = bs:readInt8()
    local gravity = bs:readFloat()
    local lanMode = bs:readBool()
    local deathMoneyDrop = bs:readInt32()
    local instagib = bs:readBool()

    local normalOnfootSendrate = bs:readInt32()
    local normalIncarSendrate = bs:readInt32()
    local normalFiringSendrate = bs:readInt32()
    local sendMultiplier = bs:readInt32()
    local lagCompMode = bs:readInt32()
    local hostName = bs:readString8()

    localplayer:SetLocalPlayerID(playerId)
    setGravity(gravity)
    enableStuntBonus(stuntBonus)
    disableAllEntryExits(disableEnterExits)
    displayZoneNames(zoneNames)
    localplayer:HandleClassSelection()
    setTimeOfDay(worldTime, 0)
    forceWeatherNow(worldWeather)
    memory.setuint8(0x969168, 1, true)
    localplayer.connected = true
    localplayer.spawned = false

    chat_pool:add(0x80DAEB, "Connected to {FFFFFF}" .. hostName)
end

local function SetPlayerPos(bs)
    local x, y, z = bs:readFloat(), bs:readFloat(), bs:readFloat()

    setCharCoordinatesNoOffset(PLAYER_PED, x, y, z)
end

local function Chat(bs)
    local playerId = bs:readInt16() + 1
    local text = bs:readString8()

    if players.list[playerId] ~= nil then
        if playerId - 1 == localplayer:GetLocalPlayerID() then
            return chat_pool:add(0xFF0000, ("%s[%d]: {FFFFFF}%s"):format(localplayer:GetLocalPlayerName(), localplayer:GetLocalPlayerID(), text))
        end
        local color = tonumber(players.list[playerId].color, 16)
        chat_pool:add((color == 0) and 0xFFFFFF or color, ("%s[%d]: {FFFFFF}%s"):format(players.list[playerId].nickname, playerId - 1, text))
    end
end

local function ServerJoin(bs)
    local playerId = bs:readInt16() + 1
    local color = bs:readInt32()
    local isNPC = bs:readInt8()
    local nickname = bs:readString8()

    color = bit.tohex(ARGBtoRGB(color)):gsub('^00', '')

    players.list[playerId] = {
        nickname = nickname,
        color = color,
        npc = isNPC,
        skin = 0, 
        health = 100,
        armour = 0,
        score = 0, 
        ping = 0
    }
end

local function ServerQuit(bs)
    local playerId = bs:readInt16() + 1
    players.remove(playerId)
end

local function RequestClass(bs)
    local canSpawn = bs:readInt8()
    local team = bs:readInt8()
    local skin = bs:readInt32()
    local _unused = bs:readInt8()

    local x, y, z = bs:readFloat(), bs:readFloat(), bs:readFloat()
    local rotation = bs:readFloat()

    if canSpawn then
        localplayer:SetSpawnInfo(team, skin, x, y, z, rotation)
        localplayer:HandleClassSelectionOutcome(true)
    else
        localplayer:HandleClassSelectionOutcome(false)
    end
end

local function RequestSpawn(bs)
    local response = bs:readInt8()

    if response == 2 or (response and localplayer.waitingForSpawnReply) then
        localplayer:Spawn()
    else
        localplayer.waitingForSpawnReply = false
    end
end

local function SpawnInfo(bs)
    local team = bs:readInt8()
    local skin = bs:readInt32()
    local _unused = bs:readInt8()

    local x, y, z = bs:readFloat(), bs:readFloat(), bs:readFloat()
    local rotation = bs:readFloat()

    localplayer:SetSpawnInfo(team, skin, x, y, z, rotation)
end

local function SetInterior(bs)
    local interiorId = bs:readInt8()
    setInteriorVisible(interiorId)
    setCharInterior(PLAYER_PED, interiorId)
    local x, y, z = getCharCoordinates(PLAYER_PED)
    requestCollision(x, y, z)
end

local function ToggleControllable(bs)
    local controllable = bs:readInt8()
    lockPlayerControl(controllable)
end

local function SetCameraPos(bs)
    local x, y, z = bs:readFloat(), bs:readFloat(), bs:readFloat()
    setFixedCameraPosition(x, y, z)
end

local function SetCameraLookAt(bs)
    local x, y, z = bs:readFloat(), bs:readFloat(), bs:readFloat()
    local cutType = bs:readInt8()
    pointCameraAtPoint(x, y, z, cutType)
end

local function SetPlayerFacingAngle(bs)
    local rotation = bs:readInt8()
    setCharHeading(PLAYER_PED, rotation)
end

local function WorldPlayerAdd(bs)
    local playerId = bs:readInt16() + 1
    local team = bs:readInt8()
    local modelId = bs:readInt32()
    local x, y, z = bs:readFloat(), bs:readFloat(), bs:readFloat()
    local rotation = bs:readFloat()
    local color = bs:readInt32()
    local fightingStyle = bs:readInt8() -- not supported

    if players.list[playerId] == nil then return end
    local ptr = players.list[playerId]
    if not doesCharExist(ptr.ped) then
        ptr.skin = modelId
        ptr.color = color
        players.spawn(playerId)
        setCharCoordinates(ptr.ped, x, y, z)
        setCharHeading(ptr.ped, rotation)
    end
end

local function WorldPlayerRemove(bs)
    local playerId = bs:readInt16() + 1
    players.remove(playerId)
end

local NetRPCHandles = {
    [15] = ToggleControllable,
    [12] = SetPlayerPos,
    [19] = SetPlayerFacingAngle,
    [68] = SpawnInfo,
    [156] = SetInterior,
    [93] = ServerMessage,
    [101] = Chat,
    [128] = RequestClass,
    [129] = RequestSpawn,
    [137] = ServerJoin,
    [138] = ServerQuit,
    [139] = InitGame,
    [157] = SetCameraPos,
    [158] = SetCameraLookAt,
    [32] = WorldPlayerAdd,
    [163] = WorldPlayerRemove
}

function onBotIncomingRPC(bot, rpcId, bs)
    if NetRPCHandles[rpcId] ~= nil then
        NetRPCHandles[rpcId](bs)
    else
        chat_pool:add(0xFF0000, "[Warning] Client receive bad RPC: " .. rpcId)
    end
end

function onBotIncomingPacket(bot, packetId, bitStream)
    if packetId == 29 then
        chat_pool:add(0x80DAEB, "The server didn`t response.")
        connect_to_server()
    end

    if packetId == 34 then
        chat_pool:add(0x80DAEB, "Connected. Joining the game...")
    end

    if packetId == 33 then
        chat_pool:add(0x80DAEB, "Lost connection to the server...")
        connect_to_server()
    end

    if packetId == 36 then
        chat_pool:add(0x80DAEB, "You are banned from this server.")
        chat_pool:add(0x80DAEB, "Type: /q for exit")
    end

    if packetId == 37 then
        chat_pool:add(0x80DAEB, "Invalid server password.")
        chat_pool:add(0x80DAEB, "Type: /q for exit")
    end

    if packetId == 31 then
        chat_pool:add(0x80DAEB, "The server is full.")
        connect_to_server()
    end
end