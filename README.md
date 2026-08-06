# SzLoading




print("1 compila ok")
local f, e = loadstring("-- teste 🇺🇸")
print("2 emoji loadstring:", f ~= nil, e)
print("3 guard travado:", getgenv().SZDUN)
print("4 gameId:", tostring(game.GameId))
