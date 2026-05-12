local pps = game:GetService("ProximityPromptService")
pps.PromptButtonHoldBegan:Connect(function(prompt)
    fireproximityprompt(prompt)
end)

local pps = game:GetService("ProximityPromptService")
pps.PromptShown:Connect(function(prompt)
    fireproximityprompt(prompt)
end)

local pps = game:GetService("ProximityPromptService")
pps.PromptShown:Connect(function(prompt)
    task.spawn(function()
        while prompt.Enabled and prompt.Parent do
            fireproximityprompt(prompt)
            task.wait() 
            if not prompt:IsDescendantOf(game) then break end
        end
    end)
end)
