--[[
	EzSave apart of EzLibraries
	Warning this code is way messier than the others
	by Todd
]]--

--// Container

local EzSave = {}

--// Exploit Specific

assert(syn or SENTINEL_V2, "EzSave | EzSave is Synapse X and Sentinel only")
local makefolder = syn and makefolder or createdirectory

--// Internals

local HttpService = game:GetService("HttpService")

function Dump(value)
    return string.split(tostring(value),", ")
end

function Serialize(value)
    local function DealTable(value)
        local Reconstructed = {}
        for k,v in pairs(value) do
            if type(v) ~= "table" then
                Reconstructed[k] = Serialize(v)
            else
                Reconstructed[k] = DealTable(v)
            end
        end
        return Reconstructed
    end
    local function Serialize(value)
        if type(value) ~= "table" and type(value) ~= "number" and type(value) ~= "string" and type(value) ~= "boolean" then
            local Invalues = {}
            for k,v in ipairs(Dump(value)) do
                Invalues[k] = v
            end
            return typeof(value).. HttpService:JSONEncode(Invalues)
        else
            return typeof(value).. HttpService:JSONEncode({value})
        end
    end
    if type(value) == "table" then
        return DealTable(value)
    else
        return Serialize(value)
    end
end

function MakeInto(value,Type)
    local Class
    local ConvertedFinal
    if Type ~= "Instance" and Type ~= "boolean" and Type ~= "number" and Type ~= "string" then
        return loadstring("return "..Type..".new("..unpack(value)..")")()
    elseif Type ~= "Instance" then
        return value[1]
    else
        local Pos = game
        for k,v in ipairs(string.split(value[1],".")) do
            Pos = Pos[v]
        end
        ConvertedFinal = Pos
    end
    return ConvertedFinal
end

function DeSerialize(value)
    local function DealTable(value)
        local Reconstructed = {}
        for k,v in pairs(value) do
            if type(v) ~= "table" then
                Reconstructed[k] = DeSerialize(v)
            else
                Reconstructed[k] = DealTable(v)
            end
        end
        return Reconstructed
    end
    local function DeSerialize(value)
        local value = string.split(value,"[")
        local NewValue = ""
        local Type = value[1]
        for k,v in pairs(value) do
            if k ~= 1 then
                NewValue = NewValue.. v
            else
                NewValue = NewValue.. "["
            end
        end
        local value = NewValue
        local value = HttpService:JSONDecode(value)
        return MakeInto(value,Type)
    end
    if type(value) ~= "table" then
        return DeSerialize(value)
    else
        local Reconstructed = {}
        for k,v in pairs(value) do
            if type(v) ~= "table" then
               Reconstructed[k] = DeSerialize(v)
            else
                Reconstructed[k] = DealTable(v)
            end
        end
        return Reconstructed
    end
end 

function Encode(value)
    local value = Serialize(value)
    local Encoded = type(value) == "table" and "T" or "L"
    local Encoded = Encoded.. (type(value) == "table" and HttpService:JSONEncode(value) or HttpService:JSONEncode({value}))
    return Encoded
end

function Decode(value)
    local QuickType = string.sub(value,1,1)
    local value = string.sub(value,2,#value)
    return DeSerialize((QuickType == "T" and HttpService:JSONDecode(value) or HttpService:JSONDecode(value)[1]))
end

--// Functions

EzSave.NewProject = function(id)
    assert(type(id)=="string","EzSave.NewProject | Expected string as argument #1")
    makefolder(id)
    return id
end

EzSave.NewStore = function(project,store)
    assert(type(project)=="string","EzSave.NewStore | Expected string as argument #1")
    assert(type(store)=="string","EzSave.NewStore | Expected string as argument #2")
    local Dir = project.."/"..store
    makefolder(Dir)
    return Dir
end

EzSave.Set = function(store,variablename,value)
    assert(type(store)=="string","EzSave.Set | Expected string as argument #1")
    assert(type(variablename)=="string","EzSave.Set | Expected string as argument #2")
    assert(type(value)~=nil,"EzSave.Set | Expected something as argument #3")
    writefile(store.."/"..variablename..".data",Encode(value))
    return true
end

EzSave.Get = function(store,variablename)
    assert(type(store)=="string","EzSave.Get | Expected string as argument #1")
    assert(type(variablename)=="string","EzSave.Get | Expected string as argument #2")
    return Decode(readfile(store.."/"..variablename..".data"))
end

--// Return

return EzSave
