getgenv().SZDUN = nil

local URL = "https://raw.githubusercontent.com/Yxnael/SzLoading/main/Szhub.lua"

local f, e = loadstring("-- teste 🇺🇸 Türkçe")
print("[DIAG] encoding ok:", f ~= nil)

print("[DIAG] placeId:", tostring(game.PlaceId), "| gameId:", tostring(game.GameId))

local ok1, src = pcall(game.HttpService.GetAsync, game:GetService("HttpService"), URL)
print("[DIAG] download ok:", ok1)
if not ok1 then print("[DIAG] ERRO no download: " .. tostring(src)) return end
print("[DIAG] tamanho:", tostring(#src))

local fn, err2 = loadstring(src)
print("[DIAG] compila ok:", fn ~= nil)
if not fn then print("[DIAG] ERRO de compilacao:\n" .. tostring(err2)) return end

local ok, err3 = xpcall(fn, debug.traceback)
print("[DIAG] resultado:", ok)
if not ok then
    print("[DIAG] ERRO:\n" .. tostring(err3))
else
    print("[DIAG] rodou sem erro — se nada aparecer, e renderizacao de UI no Delta")
end
