-- Taken from SWS mod

-- Retrieve local function in a non-local function
-- Useful if you need to override a local function in a local function with ReplaceLocals but lack a reference to it.
function GetLocalFunction(originalFunction, localFunctionName)

    local index = 1
    while true do
        
        local n, v = debug.getupvalue(originalFunction, index)
        if not n then
           break
        end
            
        if n == localFunctionName then
            return v
        end
            
        index = index + 1
            
    end
    
    return nil
    
end

if Server then
    function GetClientFromPlayer(player)
        if player ~= nil and player:isa("Player") then
            return Server.GetOwner(player) -- the client object
        end
        return nil
    end
end