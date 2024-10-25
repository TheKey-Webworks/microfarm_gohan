print("V1.45----------------")

local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local userId = Player.UserId
local playerData = ReplicatedStorage.Datas[userId]
local activeQuest = playerData.Quest
local questProgress = playerData.QuestProgress

local teleportEvent = ReplicatedStorage.Package.Events.TP
local getQuestEvent = ReplicatedStorage.Package.Events.Qaction
local punchEvent = ReplicatedStorage.Package.Events.p
local rebEvent = ReplicatedStorage.Package.Events.reb
local chargeEvent = ReplicatedStorage.Package.Events.cha
local mel = ReplicatedStorage.Package.Events.mel

local function getCharacter() 
    local c = Player.Character or Player.CharacterAdded:Wait()
    return c
end

local function getQuest(questName)
    local questGiver = workspace.Others.NPCs[questName]
    local c = getCharacter()
    c.HumanoidRootPart.CFrame = questGiver.HumanoidRootPart.CFrame
    task.wait(1.5) -- Reducido para hacer más ágil el proceso
    getQuestEvent:InvokeServer(questGiver)
end

local function farmNPC(npc)
    local gohan = workspace.Living:WaitForChild(npc)
    if not gohan or not gohan:FindFirstChild("Humanoid") then return end

    if gohan.Humanoid.Health > 0 then
        while _G.farm and gohan.Humanoid.Health > 0 and task.wait(1) do

            -- Bloqueo optimizado para menos espera
         --   coroutine.wrap(function()
             --   while _G.farm and task.wait(5) do
               --     game:GetService("ReplicatedStorage").Package.Events.block:InvokeServer(true)
               -- end
          --  end)()

            -- Movimiento al NPC solo si está fuera del rango de ataque
            coroutine.wrap(function()
                local c = getCharacter()
                local cHRP = c:FindFirstChild("HumanoidRootPart") or c:WaitForChild("HumanoidRootPart")
                local eHRP = gohan:FindFirstChild("HumanoidRootPart") or gohan:WaitForChild("HumanoidRootPart")

                while _G.farm and gohan.Humanoid.Health > 0 and task.wait() do
                    if not eHRP then break end
                    local distance = (cHRP.Position - eHRP.Position).Magnitude
                    if distance > 2.5 then
                        local direction = (eHRP.Position - cHRP.Position).unit
                        local targetPosition = eHRP.Position - direction * 2.5
                        cHRP.CFrame = CFrame.new(targetPosition, eHRP.Position)
                    end
                end
            end)()

            -- Ataque en bucle más frecuente
            for i = 1, 4 do  -- Incrementa el número de ataques
                punchEvent:FireServer("Blacknwhite27", i)
                task.wait(1)  -- Reducción del tiempo entre golpes
            end
        end
    end
end

-- main loop
while _G.farm and task.wait() do
    if _G.rebirth then
        rebEvent:InvokeServer()
    end

    local currentTime = game.Lighting.ClockTime
    if currentTime > 0 and currentTime < 12 then 
        teleportEvent:InvokeServer("Earth")
    end

    coroutine.wrap(function() 
        while _G.farm and task.wait(1) do  -- Ajuste del tiempo para menos carga de eventos
            chargeEvent:InvokeServer("Blacknwhite27")
        end
    end)()
    
    if activeQuest.Value == "" then
        getQuest("Kid Nohag")
    elseif activeQuest.Value ~= "" then
        farmNPC("Kid Nohag")
    end
end
