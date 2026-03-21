--- @class Viewport
--- @field x number
--- @field y number
--- @field rotation number
--- @field clear_color number[]
--- @field private _width number
--- @field private _height number
--- @field private _scale_mode Viewport.ScaleMode
--- @field private _canvas love.Canvas
--- @field private _settings table
--- @field private _need_canvas_update boolean
--- @field private _previous_canvas love.Canvas
local Viewport = {}
Viewport.__index = Viewport

--- @enum (key) Viewport.ScaleMode
local ScaleMode = {
    keep_size = "keep_size",
    pixel_perfect = "pixel_perfect",
    stretch = "stretch",
    none = "none"
}

--#region Local Methods

--- Returns a canvas based on the viewport parameters.
--- @nodiscard
--- @param viewport Viewport
--- @return love.Canvas
local function createCanvas(viewport)
    return love.graphics.newCanvas(viewport:getWidth(), viewport:getHeight(), viewport:getSettings())
end

--- Returns the scale that should be applied to the viewport canvas.
--- @nodiscard
--- @param viewport Viewport
--- @param canvas love.Canvas
--- @param base_canvas? love.Canvas
--- @return integer, integer
local function getCanvasScale(viewport, canvas, base_canvas)
    local baseW = base_canvas and base_canvas:getWidth() or love.graphics.getWidth()
    local baseH = base_canvas and base_canvas:getHeight() or love.graphics.getHeight()
    local canvasW, canvasH = canvas:getDimensions()
    local scaleX, scaleY

    if viewport:getScaleMode() == "keep_size" then
        scaleX = math.min(baseW / canvasW, baseH / canvasH)
        scaleY = scaleX
    elseif viewport:getScaleMode() == "pixel_perfect" then
        scaleX = math.floor(math.min(baseW / canvasW, baseH / canvasH))
        scaleY = scaleX
    elseif viewport:getScaleMode() == "stretch" then
        scaleX = baseW / canvasW
        scaleY = baseH / canvasH
    elseif viewport:getScaleMode() == "none" then
        scaleX = viewport:getWidth() / canvasW
        scaleY = viewport:getHeight() / canvasH
    end

    return scaleX, scaleY
end

--- Returns the position of the viewport canvas.
--- @nodiscard
--- @param viewport Viewport
--- @param base_canvas love.Canvas
--- @return number, number
local function getCanvasPosition(viewport, base_canvas)
    local baseW = base_canvas and base_canvas:getWidth() or love.graphics.getWidth()
    local baseH = base_canvas and base_canvas:getHeight() or love.graphics.getHeight()
    local canvasX, canvasY

    if viewport:getScaleMode() == "none" then
        canvasX, canvasY = viewport.x, viewport.y
    else
        canvasX = baseW / 2
        canvasY = baseH / 2
    end

    return canvasX, canvasY
end

--#endregion


--#region Public Methods

--- Creates a new Viewport.
--- @nodiscard
--- @param width number
--- @param height number
--- @param scale_mode? Viewport.ScaleMode
--- @param settings? table
--- @return Viewport
function Viewport:new(width, height, scale_mode, settings)
    local obj = setmetatable({}, self)

    obj.x = 0
    obj.y = 0
    obj.rotation = 0
    obj.clear_color = { 0.1, 0.1 , 0.1, 1.0 }
    obj._width = width
    obj._height = height
    obj._scale_mode = scale_mode or "keep_size"
    obj._settings = settings or {}
    obj._need_canvas_update = true
    obj._previous_canvas = nil

    obj:_updateCanvas()

    return obj
end

--- Opens the Viewport for drawing operations.
function Viewport:open()
    -- Updates the Viewport canvas if necessary.
    self:_updateCanvas()

    -- Sets the Viewport canvas as the current canvas.
    self._previous_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self._canvas)
    love.graphics.clear(self.clear_color)
end

--- Closes the Viewport drawing operations and renders it.
function Viewport:close()
    love.graphics.setCanvas(self._previous_canvas)

    local canvasW, canvasH = self._canvas:getDimensions()
    local scaleX, scaleY = getCanvasScale(self, self._canvas, self._previous_canvas)
    local canvasX, canvasY = getCanvasPosition(self, self._previous_canvas)

    local blendmode, alphamode = love.graphics.getBlendMode()
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self._canvas, canvasX, canvasY, self.rotation, scaleX, scaleY, canvasW/2, canvasH/2)
    love.graphics.setBlendMode(blendmode, alphamode)
end

--- Converts a screen position to a point in the Viewport.
--- @param x number
--- @param y number
--- @return number, number
function Viewport:toViewport(x, y)
    local scaleX, scaleY = getCanvasScale(self, self._canvas)
    local canvasX, canvasY = getCanvasPosition(self, self._previous_canvas)
    local canvasW, canvasH = self._canvas:getDimensions()

    local px = x - canvasX
    local py = y - canvasY

    if self.rotation ~= 0 then
        local cosr = math.cos(-self.rotation)
        local sinr = math.sin(-self.rotation)

        local rx = px * cosr - py * sinr
        local ry = px * sinr + py * cosr

        px, py = rx, ry
    end

    px = px/scaleX + canvasW/2
    py = py/scaleY + canvasH/2

    return px, py
end

--- Converts a Viewport position to a point on the screen.
--- @param x number
--- @param y number
--- @return number, number
function Viewport:toScreen(x, y)
    local scaleX, scaleY = getCanvasScale(self, self._canvas)
    local canvasX, canvasY = getCanvasPosition(self, self._previous_canvas)
    local canvasW, canvasH = self._canvas:getDimensions()

    local px = (x - canvasW/2) * scaleX
    local py = (y - canvasH/2) * scaleY

    if self.rotation ~= 0 then
        local cosr = math.cos(self.rotation)
        local sinr = math.sin(self.rotation)

        local rx = px * cosr - py * sinr
        local ry = px * sinr + py * cosr

        px, py = rx, ry
    end

    px, py = px + canvasX, py + canvasY

    return px, py
end

--#endregion


--#region Private Methods

--- Updates the viewport canvas.
--- @private
function Viewport:_updateCanvas()
    if self._need_canvas_update then
        self._canvas = createCanvas(self)
        self._need_canvas_update = false
    end
end

--#endregion


--#region Setters

--- Sets the Viewport position.
--- @param x number
--- @param y number
function Viewport:setPosition(x, y)
    self.x, self.y = x, y
end

--- Sets the Viewport width.
--- @param width number
function Viewport:setWidth(width)
    self._width = width
    self._need_canvas_update = true
end

--- Sets the Viewport height.
--- @param height number
function Viewport:setHeight(height)
    self._height = height
    self._need_canvas_update = true
end

--- Sets the Viewport dimensions.
--- @param widht number
--- @param height number
function Viewport:setDimensions(widht, height)
    self:setWidth(widht)
    self:setHeight(height)
end

--- Sets the Viewport scale mode.
--- @param scale_mode Viewport.ScaleMode
function Viewport:setScaleMode(scale_mode)
    self._scale_mode = scale_mode
    self._need_canvas_update = true
end

--- Sets the Viewport settings.
--- @param settings table
function Viewport:setSettings(settings)
    for k, v in pairs(settings) do
        self._settings[k] = v
    end
    self._need_canvas_update = true
end

--#endregion


--#region Getters

--- Returns the Viewport position.
--- @nodiscard
--- @return number, number
function Viewport:getPosition()
    return self.x, self.y
end

--- Returns the Viewport width.
--- @nodiscard
--- @return number
function Viewport:getWidth()
    return self._width
end

--- Returns the Viewport height.
--- @nodiscard
--- @return number
function Viewport:getHeight()
    return self._height
end

--- Returns the Viewport dimensions.
--- @nodiscard
--- @return number, number
function Viewport:getDimensions()
    return self:getWidth(), self:getHeight()
end

--- Returns the Viewport scale mode.
--- @nodiscard
--- @return Viewport.ScaleMode
function Viewport:getScaleMode()
    return self._scale_mode
end

--- Returns the Viewport settings. These values should not be modified directly.
--- @nodiscard
--- @return table
function Viewport:getSettings()
    return self._settings
end

--#endregion

return Viewport
