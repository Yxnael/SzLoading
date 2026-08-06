getgenv().SZDUN = nil   -- limpa qualquer travamento anterior

-- 1) URL do seu script
local URL = "https://raw.githubusercontent.com/Yxnael/SzLoading/main/Szhub.lua"

-- 2) teste de encoding (só pra descartar)
local f, e = loadstring("-- teste 🇺🇸 Türkçe")
print("[DIAG] encoding ok:", f ~= nil)

-- 3) dados do jogo
print("[DIAG] placeId:", tostring(game.PlaceId), "| gameId:", tostring(game.GameId))

-- 4) intercepta task.spawn para nao engolir erros
local realSpawn = task.spawn
task.spawn = function(fn, ...)
    local args = { ... }
    return realSpawn(function()
        local ok2, err2 = xpcall(function() fn(unpack(args)) end, debug.traceback)
        if not ok2 then print("[DIAG] ERRO em task.spawn:\n" .. tostring(err2)) end
    end)
end

-- 5) baixa o script
local ok1, src = pcall(game.HttpService.GetAsync, game:GetService("HttpService"), URL)
print("[DIAG] download ok:", ok1)
if not ok1 then
    print("[DIAG] ERRO no download: " .. tostring(src))
    return
end
print("[DIAG] tamanho:", tostring(#src))

-- 6) compila
local fn, err2 = loadstring(src)
print("[DIAG] compila ok:", fn ~= nil)
if not fn then print("[DIAG] ERRO de compilacao:\n" .. tostring(err2)) return end

-- 7) roda capturando erro com linha
local ok, err3 = xpcall(fn, debug.traceback)
print("[DIAG] resultado:", ok)
if not ok then
    print("[DIAG] ERRO:\n" .. tostring(err3))
else
    print("[DIAG] rodou sem erro — se nada aparecer, e renderizacao de UI no Delta")
end
