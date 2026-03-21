--
-- Class (based on classic)
--
-- Original library: classic
-- Author: rxi
-- Copyright (c) 2014 rxi
--
-- Modifications and extensions:
-- Copyright (c) 2026 Rafael Lopes
--
-- Licensed under the MIT License
-- See LICENSE for details
--

--- @class Class
local Class = {}
Class.__index = Class

--#region Public Methods

--- Creates a new instance of Class.
--- @return table
function Class:new()
    local obj = setmetatable({}, self)
    return obj
end

--- Extends the class.
--- @generic T : Class
--- @param self T
--- @return T
function Class:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    setmetatable(cls, self)
    return cls
end

--- Implements the methods of a mixin.
--- @param ... table
function Class:implement(...)
    for _, cls in pairs({...}) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
end

--- Returns whether the class type matches T.
--- @param T Class
--- @return boolean
function Class:is(T)
    local mt = getmetatable(self)
    while mt do
        if mt == T then
            return true
        end
        mt = getmetatable(mt)
    end
    return false
end

--#endregion

return Class
