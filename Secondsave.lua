local pps = game:GetService("ProximityPromptService")

pps.PromptButtonHoldBegan:Connect(function(prompt)
    fireproximityprompt(prompt)
end)

local pps = game:GetService("ProximityPromptService")

pps.PromptShown:Connect(function(prompt)
    fireproximityprompt(prompt)
end)
