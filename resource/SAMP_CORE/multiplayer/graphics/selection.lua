selection = {}

imgui.OnFrame(function() return not isPauseMenuActive() and localplayer.allowedClass end,
function(self)
    local sx, sy = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2((sx) / 2 - 150, sy - 100), imgui.Cond.Always)
    imgui.Begin("SpawnScreen", nil, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.NoMove)
    if imgui.Button("<", imgui.ImVec2(100, 50)) then
        localplayer:ClassHandle(false)
    end
    imgui.SameLine(0, 0)
    if imgui.Button(">", imgui.ImVec2(100, 50)) then
        localplayer:ClassHandle(true)
    end
    imgui.SameLine(0, 0)
    if imgui.Button("Spawn", imgui.ImVec2(100, 50)) then
        localplayer:Spawn()
    end
    imgui.End()
end)