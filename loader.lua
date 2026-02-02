-- GreyXMenu | Loader Protegido

if getgenv().GreyXMenuLoader then
    warn("[GreyXMenu] Loader já executado!")
    return
end
getgenv().GreyXMenuLoader = true

-- Aguarda o jogo carregar
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Configurações
local CONFIG = {
    Name = "GreyXMenu",
    Version = "1.0",
    Main = "https://raw.githubusercontent.com/PMQUIMICO/GreyXMenu/main/main.lua",
    AllowedPlaces = {
        -- opcional: PlaceIds permitidos
        -- 123456789
    }
}

-- Verificação de PlaceId (opcional)
if #CONFIG.AllowedPlaces > 0 then
    local allowed = false
    for _, id in ipairs(CONFIG.AllowedPlaces) do
        if game.PlaceId == id then
            allowed = true
            break
        end
    end
    if not allowed then
        return warn("[GreyXMenu] Jogo não autorizado!")
    end
end

-- Banner
print("===================================")
print(CONFIG.Name .. " Loader")
print("Versão: " .. CONFIG.Version)
print("Carregando menu...")
print("===================================")

-- Carregar script principal
local ok, err = pcall(function()
    loadstring(game:HttpGet(CONFIG.Main))()
end)

if ok then
    print("[GreyXMenu] Menu carregado com sucesso!")
else
    warn("[GreyXMenu] Erro ao carregar:")
    warn(err)
end
