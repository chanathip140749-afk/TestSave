-- ==========================================
-- 🛠️ ส่วนตั้งค่า (Configuration)
-- ตั้งชื่อโฟลเดอร์มอนสเตอร์ตรงนี้ได้เลยครับ
-- ==========================================
getgenv().Config = {
    ["Folder Mon"] = {"Enemies", "Mobs", "Monsters"}, -- ชื่อโฟลเดอร์มอนสเตอร์ (ใส่ได้หลายชื่อ)
    ["Bring Mobs"] = true,                           -- ดึงมอนสเตอร์มาล็อกไว้ตรงหน้าเพื่อให้ฟันโดน 100%
    ["Instant Kill After Hit"] = true,               -- ฟัน 1 ทีตายทันที (เพื่อให้ระบบเกมแจก EXP และของ)
    ["Radius"] = 60,                                 -- ระยะที่จะดึงมอนสเตอร์เข้ามาหาตัว
    
    ["HitboxSize"] = Vector3.new(8, 8, 8),           -- ขนาดตัวมอนสเตอร์ตอนเปิด GUI
    ["HitboxColor"] = BrickColor.new("Really blue"),
    ["HitboxTransparency"] = 0.7
}

-- ==========================================
-- 🛑 ระบบหลัก (Core System)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ORIGINAL_SIZE = Vector3.new(2, 2, 1)
local active = false
local targetsCache = {}

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Name = "LegitFarmGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.Size = UDim2.new(0, 200, 0, 80)
MainFrame.Active = true

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 20)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "FARM: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18

-- ระบบลาก GUI
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 🔍 1. ลูปค้นหามอนสเตอร์ตามโฟลเดอร์ที่กำหนด
task.spawn(function()
    while true do
        if active then
            pcall(function()
                local folderConfig = getgenv().Config["Folder Mon"]
                local tempTargets = {}

                for _, obj in pairs(game.Workspace:GetDescendants()) do
                    if (obj:IsA("Folder") or obj:IsA("Model")) and table.find(folderConfig, obj.Name) then
                        for _, descendant in pairs(obj:GetDescendants()) do
                            if descendant:IsA("Humanoid") and descendant.Parent and descendant.Parent:IsA("Model") then
                                local model = descendant.Parent
                                if model ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(model) then
                                    table.insert(tempTargets, descendant)
                                end
                            end
                        end
                    end
                end
                targetsCache = tempTargets
            end)
        end
        task.wait(1)
    end
end)

-- 🔴 2. ลูปขยายตัวมอนสเตอร์ (ฝั่ง Client)
RunService.RenderStepped:Connect(function()
    if not active then return end
    pcall(function()
        local c = getgenv().Config
        for _, humanoid in ipairs(targetsCache) do
            if humanoid and humanoid.Parent then
                local rootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.Size = c["HitboxSize"]
                    rootPart.Transparency = c["HitboxTransparency"]
                    rootPart.BrickColor = c["HitboxColor"]
                    rootPart.Material = Enum.Material.Neon
                    rootPart.CanCollide = false
                end
            end
        end
    end)
end)

-- ⚡ 3. ลูปดึงมอนสเตอร์มาให้ฟัน + สั่ง Instant Kill หลังโดนดาเมจ
task.spawn(function()
    while task.wait() do
        if active then
            pcall(function()
                local character = LocalPlayer.Character
                local chrp = character and character:FindFirstChild("HumanoidRootPart")
                if not chrp then return end

                -- Bypass ยึดสิทธิ์ฟิสิกส์มอนสเตอร์มาไว้ที่เครื่องเรา
                sethiddenproperty(LocalPlayer, "SimulationRadius", 112412400000)
                sethiddenproperty(LocalPlayer, "MaxSimulationRadius", 112412400000)

                for _, humanoid in ipairs(targetsCache) do
                    if humanoid and humanoid.Parent and humanoid.Health > 0 then
                        local hrp = humanoid.Parent:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = (hrp.Position - chrp.Position).Magnitude
                            
                            if dist <= getgenv().Config["Radius"] then
                                -- [ฟีเจอร์ดึงมอน] ล็อกตัวมอนสเตอร์มาไว้ข้างหน้าผู้เล่น 4 ช่อง จะได้ฟันโดนแน่นอน
                                if getgenv().Config["Bring Mobs"] then
                                    hrp.CFrame = chrp.CFrame * CFrame.new(0, 0, -4)
                                    hrp.Velocity = Vector3.new(0,0,0) -- ป้องกันมอนดีดกระเด็น
                                end

                                -- [ฟีเจอร์ฆ่าหลังฟัน] เช็คว่าผู้เล่นฟันโดนแล้วหรือยัง (เลือดลดต่ำกว่า Max)
                                if getgenv().Config["Instant Kill After Hit"] and humanoid.Health < humanoid.MaxHealth then
                                    task.wait(0.1) -- หน่วงเวลานิดนึงให้ Server มั่นใจว่าเราเป็นคนตีเพื่อแจกของ
                                    humanoid.Health = 0 -- สั่งตายทันที!
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 🔄 4. รีเซ็ตค่ามอนสเตอร์ตอนปิดสคริปต์
local function resetEverything()
    pcall(function()
        for _, humanoid in ipairs(targetsCache) do
            if humanoid and humanoid.Parent then
                local rootPart = humanoid.Parent:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.Size = ORIGINAL_SIZE
                    rootPart.Transparency = 1
                    rootPart.BrickColor = BrickColor.new("Medium stone grey")
                    rootPart.Material = Enum.Material.Plastic
                    rootPart.CanCollide = true
                end
            end
        end
    end)
    targetsCache = {}
end

-- ปุ่มเปิด/ปิด GUI
ToggleButton.MouseButton1Click:Connect(function()
    active = not active
    if active then
        ToggleButton.Text = "FARM: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        ToggleButton.Text = "FARM: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        resetEverything()
    end
end)
