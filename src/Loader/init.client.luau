--!strict
--!native
--!optimize 2

repeat task.wait(2) until game:IsLoaded()

require(script.Client)()