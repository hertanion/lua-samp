localplayer = {
    selectedClass = 0,
    id = -1,
    nick = client_data.name,
    spawn_info = {
        team = 0,
        skin = 0,
        position = {
            x = 0,
            y = 0,
            z = 0
        },
        rotation = 0
    },
    allowedClass = false,
    waitingForSpawnReply = false,
    hasSpawnInfo = false,
    connected = false,
    spawned = false
}

function localplayer:HandleClassSelection()
    if doesCharExist(PLAYER_PED) then
        setCharHealth(PLAYER_PED, 100)
        lockPlayerControl(false)
        client:sendRequestClass(localplayer.selectedClass)
    end
end

function localplayer:ClassHandle(next)
    localplayer.selectedClass = next and localplayer.selectedClass + 1 or localplayer.selectedClass - 1
    client:sendRequestClass(localplayer.selectedClass)
end

function localplayer:SetLocalPlayerID(playerid)
    localplayer.id = playerid
end

function localplayer:GetLocalPlayerID()
    return localplayer.id
end

function localplayer:GetLocalPlayerName()
    return localplayer.nick
end

function localplayer:SetSpawnInfo(team, skin, x, y, z, rotation)
    localplayer.spawn_info.team = team
    localplayer.spawn_info.skin = skin

    localplayer.spawn_info.position.x = x
    localplayer.spawn_info.position.y = y
    localplayer.spawn_info.position.z = z

    localplayer.spawn_info.rotation = rotation
    localplayer.hasSpawnInfo = true
end

function localplayer:HandleClassSelectionOutcome(outcome)
    if outcome then
        if doesCharExist(PLAYER_PED) then
            removeAllCharWeapons(PLAYER_PED)
            setSkin(localplayer.spawn_info.skin)
            localplayer.allowedClass = true
        end
    else
        localplayer.allowedClass = false
    end
end

function localplayer:Spawn()
    if localplayer.hasSpawnInfo == false then 
        return false 
    end

    restoreCamera()
    setCameraBehindPlayer()
    displayHud(true)
    displayRadar(true)
    lockPlayerControl(false)

    requestCollision(localplayer.spawn_info.position.x, localplayer.spawn_info.position.y)
    addHospitalRestart(localplayer.spawn_info.position.x, localplayer.spawn_info.position.y, localplayer.spawn_info.position.z, localplayer.spawn_info.rotation, 0)
    setSkin(localplayer.spawn_info.skin)
    removeAllCharWeapons(PLAYER_PED)
    setCharSuffersCriticalHits(PLAYER_PED, false)
    switchRandomTrains(false)
    disableCameraFade()
    setCharHeading(PLAYER_PED, localplayer.spawn_info.rotation)

    localplayer.waitingForSpawnReply = false
    client:sendRequestSpawn()
    client:sendSpawn()
    localplayer.allowedClass = false
    localplayer.spawned = true
end