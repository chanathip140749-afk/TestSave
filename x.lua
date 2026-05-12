local modulePath = game:GetService("Players").Thongtang1.Backpack.AK47.ConfigMods.CConfig
local config = require(modulePath)
local mod = {
    cooldown = 0.05,        -- ฟันรัวแบบแทบไม่มี Delay
    finalCooldown = 0.05,
    attackSpeed = 3,         -- Animation เร็วสะใจ
    resetTime = 10           -- เก็บ Combo ไว้ได้นานๆ
}

-- เริ่มการ Hook
local oldHook
oldHook = hookfunction(slashingCoreFunc, function(p1, p2)
    p2 = p2 or {}
    for key, value in pairs(cheatConfig) do
        p2[key] = value
    end
    
    print("Hooked:" .. tostring(p1))
    return oldHook(p1, p2)
end)

local modulePath = game:GetService("Players").Thongtang1.Backpack.AK47.ConfigMods.CConfig
local slashingCoreFunc = require(modulePath)
local cheatConfig = {
    Ammo = 99999             
local oldHook
oldHook = hookfunction(slashingCoreFunc, function(p1, p2)
    p2 = p2 or {}
    for key, value in pairs(cheatConfig) do
        p2[key] = value
    end    
    print("Hooked:" .. tostring(p1))
    return oldHook(p1, p2)
end)

print("hooked!")
