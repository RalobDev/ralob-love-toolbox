# Viewport

A 2D Viewport library for LÖVE (Love2D) that allows rendering scenes to a virtual canvas and projecting them onto the screen with scaling, rotation, and precise coordinate conversion.

## ✨ **Features**

- Offscreen canvas rendering
- Configurable scale modes
- Viewport rotation
- Bidirectional coordinate conversion
- Support for multiple viewports
- Preserves previous canvas (nestable)
- Simple and predictable API

## 📦 Installation

Copy the `viewport.lua` file into your project and require it normally:

```lua
local Viewport = require("viewport")
```

## 🚀 Basic Usage

**Creating a Viewport**

```lua
local viewport = Viewport:new(320, 180, "pixel_perfect")
```

Parameters:
- `width`: virtual viewport width
- `height`: virtual viewport height
- `scale_mode` (optional): scale mode
- `settings` (optional): canvas configuration

**Drawing to the Viewport**

```lua
function love.draw()
	viewport:open()

	-- everything here is drawn in viewport space
	love.graphics.circle("fill", 160, 90, 10)

	viewport:close()
end
```

## 🔁 Coordinate Conversion

**Screen → Viewport (e.g. mouse)**

```lua
local mx, my = love.mouse.getPosition()
local vx, vy = viewport:toViewport(mx, my)
```

**Viewport → Screen**

```lua
local sx, sy = viewport:toScreen(160, 90)
```

## 🔄 Scale Modes (Viewport.ScaleMode)

| Mode | Description |
| ---- | --------- |
| `keep_size` | Uniform scaling while preserving aspect ratio |
| `pixel_perfect` | Integer scaling (ideal for pixel art) |
| `stretch` | Stretches to fill the screen |
| `none` | Uses absolute position and size |

Example:
```lua
viewport:setScaleMode("pixel_perfect")
```

## 🔃 Rotation

The viewport can be freely rotated:

```lua
viewport.rotation = math.rad(15)
```

Rotation affects:
- Rendering
- `toViewport`
- `toScreen`

Everything remains mathematically consistent.

## 🎨 Clear Color

The `clear_color` defines the color used to clear the viewport canvas whenever it is opened.

By default:
```lua
viewport.clear_color = { 0.1, 0.1, 0.1, 1.0 }
```

This value is applied internally via `love.graphics.clear()` every time `viewport:open()` is called.

## 🧩 Nested Multiple Viewports

The library safely supports nested viewports.

Internally, a viewport:
- Saves the currently active canvas
- Sets its own canvas
- Restores the previous canvas when closed

This allows scenarios such as:
- Game viewport + HUD viewport
- Minimap
- Layered rendering
- Simple post-processing effects

Example:
```lua
function love.draw()
	viewport:open()
    -- game world

   	viewport_mini:open()
    -- minimap
    viewport_mini:close()

    viewport:close()
end
```

Each viewport maintains its own:
- Dimensions
- Scale
- Rotation
- Coordinate conversions

## ⚙️ Canvas Settings

The `settings` parameter allows configuring options for `love.graphics.newCanvas`.

These options are passed directly to the LÖVE API.

Example when creating a viewport:
```lua
local viewport = Viewport:new(320, 180, "pixel_perfect", {
	msaa = 4,
    dpiscale = 1
})
```

Or changing them later:
```lua
viewport:setSettings({
	msaa = 8
})
```

See the available `settings` directly on the official LÖVE [wiki](https://love2d.org/wiki/love.graphics.newCanvas)

> [!IMPORTANT]
> Whenever `settings` is changed, the viewport canvas is automatically recreated.

## 🖥️ DPI Scale (dpiscale)

dpiscale controls how the canvas handles high-density (HiDPI) displays.

Common values:
- 1 → default scale
- `love.window.getDPIScale()` → respects the system’s actual DPI

For low-resolution games, such as 320x180, transformations applied to images can be very noticeable. One solution is to use values such as 2, 4, or 6 for the viewport’s `dpiscale`.

## ⚠️ Canvas Creation and Performance Considerations

Some operations in `Viewport` force the recreation of the internal canvas.
Since creating a `love.Canvas` is a relatively costly operation, these functions should be used with care, preferably outside of love.update or `love.draw`.

### 🔁 When is a new canvas created?

A new canvas will be automatically created on the next call to `viewport:open()` when any of the following functions are used:

- `Viewport:new(...)`
- `viewport:setWidth(width)`
- `viewport:setHeight(height)`
- `viewport:setScaleMode(scale_mode)`
- `viewport:setSettings(settings)`

Internally, these functions mark the viewport as `_need_canvas_update = true`, and the canvas is recreated only when necessary.

---

### ✅ Best Practices

✔ Configure dimensions, scale mode, and settings **during game initialization**
✔ Change these properties only during specific events (resize, scene changes, graphics options)
✔ Avoid calling setters every frame

❌ Do not change width/height/scale_mode in frequent loops
❌ Do not modify `settings` dynamically without necessity

---

### 🧠 Technical Note

Canvas recreation is intentionally deferred until `viewport:open()` is called.
This ensures:
- Better control over the canvas lifecycle
- Avoidance of redundant recreations
- Compatibility with nested viewports

Even so, the cost still exists — treat these operations as **structural**, not real-time adjustments.
