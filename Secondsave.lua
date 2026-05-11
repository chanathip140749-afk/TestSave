-- Script Path: game:GetService("ReplicatedStorage").FEMeleeKitServerModules.AbilityModule
-- Took 0.73s to decompile.
-- Executor: Delta (1.0.718.1110)

-- https://lua.expert/
require(t)
return {
    {
        AbilityName = "Test",
        AbilityDescription = "TestAbility",
        AbilityCooldown = 5,
        AbilityKeybind = "E",
        PreventExecutionDuringAttackFrame = false,
        AbilityServerFunc = function(p1, p2, p3) --[[ AbilityServerFunc | Line: 15 ]]
            print("This is the ability printing in the Server!")
        end
    }
}
