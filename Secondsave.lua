local pps = game:GetService("ProximityPromptService")

pps.PromptButtonHoldBegan:Connect(function(prompt)
    fireproximityprompt(prompt)
end)
