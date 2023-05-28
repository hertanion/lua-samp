script_name("Lua SAMP")
script_authors("SLMP-Team", "Heroku")
script_version("1.0.1"); script_version_number(1)
script_properties("work-in-pause", "forced-reloading-only")
script_description("SA Multiplayer based on MoonLoader")
script_moonloader(26)

WORKING_DIRECTORY = "moonloader\\resource\\SAMP_CORE\\"
-- in WORKING_DIRECTORY we have to collect all SAMP core files and resources

package.path = package.path..";"..WORKING_DIRECTORY.."?.lua"
package.path = package.path..";"..WORKING_DIRECTORY.."?\\init.lua"
package.cpath = package.cpath..";"..WORKING_DIRECTORY.."?.dll"

ffi = require("ffi")
memory = require("memory")
mb = require('MoonBot')
imgui = require("mimgui")
encoding = require("encoding")

client = nil
encoding.default = 'CP1251'
u8 = encoding.UTF8

ffi.cdef[[
  void *malloc(size_t size);
  void free(void *ptrmem);
  char *GetCommandLineA();
  void exit(int status);
  unsigned long GetActiveWindow(void);
  bool SetWindowTextA(unsigned long hwnd, const char *lpString);
  int MessageBoxA(unsigned long hwnd, const char* lpText, const char* lpCaption, unsigned int uType);
]]

local function get_argument(argname)
    local args_str = ffi.string(ffi.C.GetCommandLineA())
    args_str = args_str:sub(11, #args_str)
    local value = args_str:match("-"..argname.."=\"(.-)\"")
    return value
end

client_data = {
    host = get_argument("h"),
    port = get_argument("p"),
    name = get_argument("n")
}

special_skins={[3]='ANDRE',[4]='BBTHIN',[5]='BB',[298]='CAT',[292]='CESAR',[190]='COPGRL3',[299]='CLAUDE',[194]='CROGRL3',[268]='DWAYNE',
[6]='EMMET',[272]='FORELLI',[195]='GANGRL3',[191]='GUNGRL3',[267]='HERN',[8]='JANITOR',[42]='JETHRO',[296]='JIZZY',[65]='KENDL',[2]='MACCER',
[297]='MADDOGG',[192]='MECGRL3',[193]='NURGRL2',[293]='OGLOC',[291]='PAUL',[266]='PULASKI',[290]='ROSE',[271]='RYDER',[86]='RYDER3',[119]='SINDACO',
[269]='SMOKE',[149]='SMOKEV',[208]='SUZIE',[270]='SWEET',[273]='TBONE',[265]='TENPEN',[295]='TORINO',[1]='TRUTH',[294]='WUZIMU',[289]='ZERO',
[300]='LAPDNA',[301]='SFPDNA',[302]='LVPDNA',[303]='LAPDPC',[304]='LAPDPD',[305]='LVPDPC',[306]='WFYCLPD',[307]='VBFYCPD',[308]='WFYCLEM',
[309]='WFYCLLV',[310]='CSHERNA',[311]='DSHERNA',[312]='COPGRL1'}

if not client_data.name or not client_data.port or not client_data.host then 
    ffi.C.MessageBoxA(ffi.C.GetActiveWindow(), "Unable to start Lua SAMP. Check the startup arguments gta_sa.exe", "Lua SAMP Error", 0x50000)
    return thisScript():unload() 
end
ffi.C.SetWindowTextA(ffi.C.GetActiveWindow(), "Lua SAMP")

players = require("multiplayer.pools.player")
sync = require("multiplayer.sync")

require("multiplayer.patches").prepare() -- SA:MP Patches
require("multiplayer.graphics")
require("multiplayer.net")
require("multiplayer.game")

function connect_to_server(next)
    chat_pool:add(0x80DAEB, "Connecting to "..client_data.host..":"..client_data.port.."...")
    client:connect(client_data.host, tonumber(client_data.port))
    setFixedCameraPosition(1074.19, -2060.90, 55.9, 0.0, 0.0, 0.0)
    pointCameraAtPoint(993.56, -1990.02, 5.9, 2)
    displayRadar(false)
	displayHud(false)
    lockPlayerControl(true)
end

function sampGetCurrentServerAddress() -- fix moonbot
    return client_data.host, tonumber(client_data.port)
end

function RegisterRPCs()
    mb.registerIncomingRPC(93) -- ServerMessage
    mb.registerIncomingRPC(139) -- InitGame 
    mb.registerIncomingRPC(101) -- Chat
    mb.registerIncomingRPC(137) -- ServerJoin
    mb.registerIncomingRPC(138) -- ServerQuit
    mb.registerIncomingRPC(128) -- RequestClass
    mb.registerIncomingRPC(129) -- RequestSpawn
    mb.registerIncomingRPC(68) -- SpawnInfo
    mb.registerIncomingRPC(156) -- Interior
    mb.registerIncomingRPC(12) -- SetPlayerPos
    mb.registerIncomingRPC(15) -- ToggleControllable
    mb.registerIncomingRPC(157) -- SetCameraPos
    mb.registerIncomingRPC(158) -- SetCameraLookAt
    mb.registerIncomingRPC(19) -- FacingAngle
    mb.registerIncomingRPC(32) -- WorldPlayerAdd
    mb.registerIncomingRPC(163) -- WorldPlayerRemove
end

function main()
    require("multiplayer.patches").apply()
    require("multiplayer.patches").antipause()

    chat_pool:add(0x80DAEB, "Lua {FFFFFF}SA-MP 0.3.7 {80DAEB}Started.")
    RegisterRPCs()
    mb.disconnectAfterUnload(true)
    client = mb.add(client_data.name)
    connect_to_server()

    lua_thread.create(function()
        while true do wait(50)
          sync.updateOnFoot()
        end
    end)

    while true do 
        wait(0)
        mb.updateCallbacks()
        players.nametags()
    end
end

addEventHandler("onQuitGame", function()
    if thisScript() == script then
        mb.unload()
    end
end)

addEventHandler("onScriptTerminate", function(script)
    if thisScript() == script then
        mb.unload()
    end
end)