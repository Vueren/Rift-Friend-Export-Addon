--[[
    Friend Export:
    - /fe [help] - Prints this list of commands.
    - /fe export <name> - Exports the Friend List, saving it under the specified name.
    - /fe import <name> - Imports the Friend List from the specified name.
    - /fe importnotes <name> - Imports the notes on the exported Friend List from the specified name.
    - /fe unexport <name> - Removes an exported Friend List from the specified name.
    - /fe unimport <name> - Removes a list of friends using the specified name.
    - /fe list - Prints a list of exported Friend Lists.
    - Note - to use with multiple games open simultaneously, log out on all importing accounts *BEFORE* exporting.
]]

-- Prints all the commands that can be used
local function printCommands()
    print("Friend Export:")
    print("- /fe [help] - Prints this list of commands.")
    print("- /fe export <name> - Exports the Friend List, saving it under the specified name.")
    print("- /fe import <name> - Imports the Friend List from the specified name.")
    print("- /fe importnotes <name> - Imports the notes on the exported Friend List from the specified name.")
    print("- /fe unexport <name> - Removes an exported Friend List from the specified name.")
    print("- /fe unimport <name> - Removes a list of friends using the specified name.")
    print("- /fe list - Prints a list of exported Friend Lists.")
    print("- Note - to use with multiple games open simultaneously, log out on all importing accounts *BEFORE* exporting.")
end

-- Prints the exported friend lists.
local function printExportedFriendLists()
    local numEntries = 0
    print("Friend List Exports:")
    for feKey,feVal in pairs(_G["FriendExport"]) do
        for flKey,flVal in pairs(feVal) do
            print("- Export " .. feKey .. ' > Friend ' .. flKey)
        end
        numEntries = numEntries + 1
    end
    if(numEntries == 0) then
        print("- You have no exported friend lists.")
    end
end

local function exportFriendList(name)
    print("Friend List exported to " .. string.lower(name))
    local friendNames = Inspect.Social.Friend.List()
    local friendDetails = {}
    for fnKey, fnVal in pairs(friendNames) do
        local detail = Inspect.Social.Friend.Detail(fnKey)
        local friendName = ""
        if(string.match(fnKey,"@") == "@") then
            friendName = fnKey
        else
            friendName = fnKey .. "@" .. Inspect.Shard().name
        end
        friendDetails[friendName] = Inspect.Social.Friend.Detail(fnKey)
    end
    _G["FriendExport"][string.lower(name)] = friendDetails
    print("Note: If you have multiple game windows open, use /reloadui to save the exports, *then* log in on the other game windows. Use /fe list to be certain.")
end

local function importFriendList(name)
    print("Friend List imported from " .. string.lower(name))
    if(_G["FriendExport"][string.lower(name)] ~= nil) then
        for fnKey,fnVal in pairs(_G["FriendExport"][string.lower(name)]) do
            print("- Importing " .. string.lower(name) .. ' > Friend ' .. fnKey)
            Command.Social.Friend.Add(fnKey)
            if(fnVal.note ~= nil) then
                Command.Social.Friend.Note(fnKey, fnVal.note)
            end
        end
    else
        print("There is no exported friend list under this name to import: " .. string.lower(name))
    end
end

local function importNotes(name)
    if(_G["FriendExport"][string.lower(name)] ~= nil) then
        for fnKey,fnVal in pairs(_G["FriendExport"][string.lower(name)]) do
            if(fnVal.note ~= nil) then
                print("- Note Import " .. string.lower(name) .. ' > Friend ' .. fnKey)
                Command.Social.Friend.Note(fnKey, fnVal.note)
            end
        end
    else
        print("There is no exported friend list under this name to import notes from: " .. string.lower(name))
    end
end

local function unexportFriendList(name)
    print("Friend List export emptied: " .. string.lower(name))
    _G["FriendExport"][string.lower(name)] = {}
end

local function unimportFriendList(name)
    if(_G["FriendExport"][string.lower(name)] ~= nil) then
        print("Exported Friend List obtained: " .. string.lower(name))
        for fnKey,fnVal in pairs(_G["FriendExport"][string.lower(name)]) do
                print("- Unimporting " .. string.lower(name) .. ' > Unfriending ' .. fnKey)
                Command.Social.Friend.Remove(fnKey)
        end
    else
        print("There is no exported friend list under this name to import: " .. string.lower(name))
    end
end

local function slashHandler(params)
    local args = string.split(string.trim(params), "%s+", true)
    local arg1, arg2 = unpack(args)
    if(#args <= 0) then
        printCommands()
    elseif(#args == 1 and arg1 ~= nil) then
        if(string.lower(arg1) == "help") then
            printCommands()
        elseif(string.lower(arg1) == "list") then
            printExportedFriendLists()
        elseif(string.lower(arg1)) == "export" then
            print("ERROR: This command requires a name to export to!")
            print("Use /fe list to see a list of names are already in use.")
        elseif(string.lower(arg1)) == "import" then
            print("ERROR: This command requires a name to import from!")
            print("Use /fe list to see a list of names that can be used.")
            print("Use /fe export to create a list.")
        elseif(string.lower(arg1) == "") then
            printCommands()
        else
            print("ERROR: Command not found!")
            printCommands()
        end
    elseif(#args == 2 and arg1 ~= nil and arg2 ~= nil) then
        if(string.lower(arg1) == "export") then
            exportFriendList(arg2)
        elseif(string.lower(arg1) == "import") then
            importFriendList(arg2)
        elseif(string.lower(arg1) == "importnotes") then
            importNotes(arg2)
        elseif(string.lower(arg1) == "unexport") then
            unexportFriendList(arg2)
        elseif(string.lower(arg1) == "unimport") then
            unimportFriendList(arg2)
        else
            print("ERROR: Command not found!")
            printCommands()
        end
    else
        print("ERROR: Command not found!")
        printCommands()
    end
end

table.insert(Command.Slash.Register("fe"), {function (params)
        slashHandler(params)
    end,
    "FriendExport", -- Addon name
    "Friend Export Slash Commands" -- Just random text so something somewhere knows who the heck you are and why
})

if(_G["FriendExport"] == nil) then
    _G["FriendExport"] = {}
end