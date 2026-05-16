-- ==========================================
-- 🛠️ ส่วนตั้งค่า (Configuration)
-- แก้ไขตรงนี้ได้ง่ายๆ เลยครับ
-- ==========================================
getgenv().Config = {
    ["Folder Mon"] = {"Enemies", "Mobs", "Monsters"}, -- ชื่อโฟลเดอร์มอนสเตอร์ (ใส่ได้หลายชื่อ)
    ["Instant Kill"] = true,                          -- เปิด/ปิด ระบบฆ่าอัตโนมัติ
    ["Radius"] = 5000,                                  -- ระยะออร่าฆ่ามอนสเตอร์ (สตาร์ทที่ 50)
    
    ["HitboxSize"] = Vector3.new(100, 100, 100),         -- ขนาดฮิตบ็อกซ์ที่ขยาย
    ["HitboxColor"] = BrickColor.new("Really blue"),   -- สีของฮิตบ็อกซ์
    ["HitboxTransparency"] = 0.7                      -- ความโปร่งใส
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
local targetsCache = {} -- ตัวเก็บรายชื่อมอนสเตอร์เพื่อลดอาการแลค

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Name = "UltimateKillGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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
ToggleButton.Text = "HACK: OFF"
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

-- 🔍 1. ฟังก์ชันค้นหามอนสเตอร์ในโฟลเดอร์ที่กำหนด (สแกนทุกๆ 1 วินาทีเพื่อไม่ให้เกมค้าง)
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

-- 🔴 2. ลูปทำงานฝั่ง Client (ขยาย Hitbox เพื่อความสะใจ/มองง่าย)
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

-- 💀 3. ลูปสำหรับ Instant Kill (ออร่าฆ่าเมื่อเข้าใกล้ระยะ)
task.spawn(function()
    while task.wait(0.1) do
        if active and getgenv().Config["Instant Kill"] then
            pcall(function()
                local character = LocalPlayer.Character
                local chrp = character and character:FindFirstChild("HumanoidRootPart")
                if not chrp then return end

                -- Bypass Simulation Radius ยึดสิทธิ์ Network
                sethiddenproperty(LocalPlayer, "SimulationRadius", 112412400000)
                sethiddenproperty(LocalPlayer, "MaxSimulationRadius", 112412400000)

                for _, humanoid in ipairs(targetsCache) do
                    if humanoid and humanoid.Parent and humanoid.Health > 0 then
                        local hrp = humanoid.Parent:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = (hrp.Position - chrp.Position).Magnitude
                            -- ตรวจสอบระยะ ถ้าเข้าใกล้... สั่งตายทันที!
                            if dist <= getgenv().Config["Radius"] then
                                humanoid.Health = 0
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 🔄 4. ฟังก์ชันรีเซ็ตค่ามอนสเตอร์กลับเป็นปกติเวลาปิด GUI
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

-- ปุ่ม เปิด/ปิด
ToggleButton.MouseButton1Click:Connect(function()
    active = not active
    if active then
        ToggleButton.Text = "HACK: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        ToggleButton.Text = "HACK: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        resetEverything()
    end
end)
