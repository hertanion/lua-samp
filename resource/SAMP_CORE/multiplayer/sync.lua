local sync = {}

-- local function key_to_bit(key)
--     local def = 0x1
--     for i = 1, key do
--       def = def * 2
--     end
--     return def
-- end

-- local function store_keys()
--     -- local keys = 0
--     -- for i = 2, 21 do
--     --   local res = getPadState(PLAYER_HANDLE, i)
--     --   local to_bit = key_to_bit(i)
--     --   if res and res ~= 0 then
--     --     keys = bit.bor(keys, to_bit)
--     --   end
--     -- end
--     -- if getPadState(PLAYER_HANDLE, 0) == -128 then
--     --   keys = bit.bor(keys, key_to_bit(22))
--     -- elseif getPadState(PLAYER_HANDLE, 0) == 128 then
--     --   keys = bit.bor(keys, key_to_bit(23))
--     -- end
--     -- if getPadState(PLAYER_HANDLE, 1) == -128 then
--     --   keys = bit.bor(keys, key_to_bit(24))
--     -- elseif getPadState(PLAYER_HANDLE, 1) == 128 then
--     --   keys = bit.bor(keys, key_to_bit(25))
--     -- end
--     -- return keys
--     local key = 0
--     for i = 2, 16 do
--         local res = getPadState(PLAYER_HANDLE, i)
--         if res and res ~= 0 then
--             key = bit.bor(i, 1)
--             key = bit.lshift(key, 1)
--         end
--     end
--     return key
-- end

function sync.updateOnFoot()
    if localplayer.spawned and localplayer.connected and not isPauseMenuActive() then
        local data = mb.getPlayerData()
        local x, y, z = getCharCoordinates(PLAYER_PED)
        local mx, my, mz = getCharMoveSpeed(PLAYER_PED)
        local qx, qy, qz, qw = getCharQuaternion(PLAYER_PED)
        local lrKey = getPadState(PLAYER_HANDLE, 0)
        local udKey = getPadState(PLAYER_HANDLE, 1)
        --local keys = store_keys()

        data.leftRightKeys = lrKey
        data.upDownKeys = udKey
        data.keysData = 0 -- fix this

        data.quaternion.x = qx
        data.quaternion.y = -qy
        data.quaternion.z = -qz
        data.quaternion.w = qw

        data.position.x = x
        data.position.y = y
        data.position.z = z

        data.moveSpeed.x = mx
        data.moveSpeed.y = my
        data.moveSpeed.z = mz

        data.weapon = getCurrentCharWeapon(PLAYER_PED)

        data.health = getCharHealth(PLAYER_PED)
        data.armor = getCharArmour(PLAYER_PED)
        client:sendPlayerData(data)
    end
end

return sync