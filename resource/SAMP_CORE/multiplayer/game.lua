function setGravity(gravity)
    memory.setfloat(0x863984, gravity, true)
end

function enableStuntBonus(stunt)
    memory.setuint32(0xA4A474, stunt, true)
end

function setSkin(skin)
    local is_special = false
    if special_skins[skin] ~= nil then -- //TODO: try to fix
        chat_pool:add(0xFF0000, "[Warning] The server is trying to set a invalid model to the player! Model: " .. skin .. "(" .. special_skins[skin] .. ").")
        return
    else 
        requestModel(skin) 
        loadAllModelsNow() 
    end

    setPlayerModel(PLAYER_HANDLE, is_special and 290 or skin)
    markModelAsNoLongerNeeded(skin) 
end

function disableCameraFade()
    memory.setuint8(0x50AC20, 0xC2, true)
    memory.setuint8(0x50AC21, 0x08, true)
    memory.setuint8(0x50AC22, 0x00, true)
end

function getCharMoveSpeed(handle)
    local ptr = getCharPointer(handle)

    if ptr ~= 0 then
        local X = memory.getfloat(ptr + 0x44, true)
        local Y = memory.getfloat(ptr + 0x44 + 0x4, true)
        local Z = memory.getfloat(ptr + 0x44 + 0x8, true)
        return X, Y, Z
    end
end