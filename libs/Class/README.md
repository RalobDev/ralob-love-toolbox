# Class

Class is a reinterpretation of the [rxi](https://github.com/rxi) Classic module, with Lua LSP-compatible type annotations and some changes to the class implementation.

The goal of this library is to provide a simple way to work with classes in Lua while keeping the code small, direct, and easy to understand.

## 📚 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Basic Usage](#-basic-usage)
  - [Creating a class](#creating-a-class)
  - [Instantiating a class](#instantiating-a-class)
- [Class scope](#class-scope)
- [Inheritance](#inheritance)
- [Instance methods](#instance-methods)
- [Overriding methods](#overriding-methods)
- [Calling parent class methods](#calling-parent-class-methods)
- [Mixins](#mixins)
- [Class comparison](#class-comparison)
- [Visibility with `@private` and `@protected`](#visibility-with-private-and-protected)
- [Suggested organization](#suggested-organization)
- [Best practices](#best-practices)
- [API](#api)
- [Complete example](#complete-example)
- [License](#license)

## ✨ Features

- Class creation
- Inheritance
- Mixins
- Class comparison
- Type annotation support for the Lua Language Server

## 📦 Installation

Copy the `class.lua` file into your project and require it normally:

```lua
local Class = require("class")
```

> [!NOTE]
> The path used in `require` depends on your project folder structure.
>
> For example, if the file is located at `libs/class.lua`, use:
>
> ```lua
> local Class = require("libs.class")
> ```

## 🚀 Basic Usage

### Creating a class

First, create a class by extending the base `Class` class.

> [!TIP]
> Keep your classes in separate files. This helps keep the project organized as it grows.

```lua
-- shape.lua
local Class = require("class")

--- @class Shape: Class
local Shape = Class:extend()

--- Creates a Shape instance.
--- @nodiscard
--- @return Shape
function Shape:new()
    local obj = Class.new(self) --- @cast obj Shape

    -- Class constructor

    return obj
end

return Shape
```

### Instantiating a class

```lua
-- main.lua
local Shape = require("shape")

local shape_a = Shape:new()
local shape_b = Shape:new()
```

> [!NOTE]
> Type annotations using `--- @` do not change how the code runs, but they are very useful for helping the Lua LSP understand your project better.
>
> Learn more in the [Lua Language Server documentation](https://luals.github.io/wiki/annotations/).

## Class scope

How you organize your files is up to you. However, it is recommended to keep class references in local scope.

```lua
local Player = require("player")
local Enemy = require("enemy")
local World = require("world")
```

At first, using `require` in every file may seem repetitive. However, in larger projects, this helps keep the global scope clean, makes dependencies explicit, and makes it easier to understand where each class comes from.

Avoid this:

```lua
Player = require("player")
Enemy = require("enemy")
```

Prefer this:

```lua
local Player = require("player")
local Enemy = require("enemy")
```

## Inheritance

Creating a class by extending the base `Class` is already an example of inheritance, because the created class inherits the methods and properties from its parent class.

### Creating the base class

Let's use the previously created `Shape` class as a base and add some properties to it.

```lua
-- shape.lua
local Class = require("class")

--- @class Shape: Class
--- @field x number
--- @field y number
local Shape = Class:extend()

--- Creates a Shape instance.
--- @nodiscard
--- @param x number
--- @param y number
--- @return Shape
function Shape:new(x, y)
    local obj = Class.new(self) --- @cast obj Shape

    obj.x = x
    obj.y = y

    return obj
end

return Shape
```

Notice that when adding properties in the class constructor, we assign them to the `obj` table. Do not use `self` to store instance data at this point.

```lua
obj.x = x
obj.y = y
```

In this case, `self` represents the class being used to create the instance. The `obj` variable represents the newly created instance.

### Inheriting from the base class

Now we can create a `Square` class that inherits from `Shape`.

```lua
-- square.lua
local Shape = require("shape")

--- @class Square: Shape
--- @field width number
--- @field height number
local Square = Shape:extend()

--- Creates a Square instance.
--- @nodiscard
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @return Square
function Square:new(x, y, width, height)
    local obj = Shape.new(self, x, y) --- @cast obj Square

    obj.width = width
    obj.height = height

    return obj
end

return Square
```

In this example, `Square` inherits from `Shape`. Because of that, it also has the `x` and `y` properties.

The line below calls the parent class constructor:

```lua
local obj = Shape.new(self, x, y) --- @cast obj Square
```

Notice that we use `Shape.new(self, x, y)` instead of `Shape:new(x, y)`.

This is important because we want the created object to use `Square` as its final class, not `Shape`.

## Instance methods

Besides the `new` constructor, you can create methods normally using `:`.

```lua
-- shape.lua
local Class = require("class")

--- @class Shape: Class
--- @field x number
--- @field y number
local Shape = Class:extend()

--- @nodiscard
--- @param x number
--- @param y number
--- @return Shape
function Shape:new(x, y)
    local obj = Class.new(self) --- @cast obj Shape

    obj.x = x
    obj.y = y

    return obj
end

--- Moves the shape.
--- @param dx number
--- @param dy number
function Shape:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

return Shape
```

Usage:

```lua
local Shape = require("shape")

local shape = Shape:new(10, 20)
shape:move(5, -2)

print(shape.x) -- 15
print(shape.y) -- 18
```

When using `:`, Lua automatically passes the object itself as the first argument to the function.

That means:

```lua
shape:move(5, -2)
```

is equivalent to:

```lua
shape.move(shape, 5, -2)
```

## Overriding methods

Child classes can override parent class methods. This happens when the child class defines a method with the same name as a method that already exists in the parent class.

Let's add a `getType` method to `Shape`:

```lua
-- shape.lua
local Class = require("class")

--- @class Shape: Class
--- @field x number
--- @field y number
local Shape = Class:extend()

--- @nodiscard
--- @param x number
--- @param y number
--- @return Shape
function Shape:new(x, y)
    local obj = Class.new(self) --- @cast obj Shape

    obj.x = x
    obj.y = y

    return obj
end

--- Returns the shape type.
--- @nodiscard
--- @return string
function Shape:getType()
    return "shape"
end

return Shape
```

Now, in `Square`, we can create another method called `getType`. Since `Square` inherits from `Shape`, this new method overrides the inherited behavior.

```lua
-- square.lua
local Shape = require("shape")

--- @class Square: Shape
--- @field width number
--- @field height number
local Square = Shape:extend()

--- @nodiscard
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @return Square
function Square:new(x, y, width, height)
    local obj = Shape.new(self, x, y) --- @cast obj Square

    obj.width = width
    obj.height = height

    return obj
end

--- Returns the square type.
--- @nodiscard
--- @return string
function Square:getType()
    return "square"
end

return Square
```

Usage:

```lua
local Shape = require("shape")
local Square = require("square")

local shape = Shape:new(10, 20)
local square = Square:new(0, 0, 16, 16)

print(shape:getType())  -- shape
print(square:getType()) -- square
```

In this example, both `Shape` and `Square` have a method called `getType`, but each class has its own implementation.

## Calling parent class methods

If a child class overrides a method, it is still possible to call the parent class version directly.

```lua
-- shape.lua
function Shape:draw()
    print("Drawing shape")
end
```

```lua
-- square.lua
function Square:draw()
    Shape.draw(self)
    print("Drawing square")
end
```

Usage:

```lua
local square = Square:new(0, 0, 16, 16)
square:draw()
```

Output:

```txt
Drawing shape
Drawing square
```

Notice that when calling the parent class method, we use `.` and pass `self` manually:

```lua
Shape.draw(self)
```

## Mixins

Mixins allow you to copy methods from a table into a class.

This is useful when you want to share behavior between different classes without necessarily creating an inheritance relationship between them.

### Creating a mixin

```lua
-- drawable.lua
local Drawable = {}

function Drawable:draw()
    print("Drawing object")
end

return Drawable
```

### Implementing the mixin in a class

```lua
-- player.lua
local Class = require("class")
local Drawable = require("drawable")

--- @class Player: Class
local Player = Class:extend()

Player:implement(Drawable)

--- @nodiscard
--- @return Player
function Player:new()
    local obj = Class.new(self) --- @cast obj Player
    return obj
end

return Player
```

Usage:

```lua
local Player = require("player")

local player = Player:new()
player:draw()
```

> [!IMPORTANT]
> The `implement` method only copies functions that do not already exist in the class.
>
> If the class already has a method with the same name, it will not be overwritten.

Example:

```lua
local Drawable = {}

function Drawable:draw()
    print("Drawing from mixin")
end

local Player = Class:extend()

function Player:draw()
    print("Drawing from player")
end

Player:implement(Drawable)

local player = Player:new()
player:draw() -- Drawing from player
```

## Class comparison

The `is` method allows you to check whether an instance belongs to a class or inherits from it.

```lua
local Class = require("class")
local Shape = require("shape")
local Square = require("square")

local square = Square:new(0, 0, 16, 16)

print(square:is(Square)) -- true
print(square:is(Shape))  -- true
print(square:is(Class))  -- true
```

This happens because `Square` inherits from `Shape`, which in turn inherits from `Class`.

It is also possible to compare an instance with a class it does not inherit from:

```lua
local Enemy = require("enemy")

print(square:is(Enemy)) -- false
```

## Visibility with `@private` and `@protected`

Lua does not have native visibility modifiers such as `private`, `protected`, and `public`. In other words, these annotations do not prevent code from running.

Even so, they are useful for documentation and for helping the Lua LSP better understand the intent of your code.

### `@private`

Use `@private` to indicate that a field or method should only be used internally by the class itself.

```lua
local Class = require("class")

--- @class Player: Class
--- @field private _health number
local Player = Class:extend()

--- @nodiscard
--- @param health number
--- @return Player
function Player:new(health)
    local obj = Class.new(self) --- @cast obj Player

    obj._health = health

    return obj
end

--- @private
function Player:_die()
    print("Player died")
end

function Player:takeDamage(amount)
    self._health = self._health - amount

    if self._health <= 0 then
        self:_die()
    end
end
```

By convention, private fields and methods usually start with `_`:

```lua
self._health = 100
self:_die()
```

This makes it clear that this part of the class was not designed to be accessed directly from the outside.

Avoid doing this outside the class:

```lua
player._health = 999
player:_die()
```

Prefer exposing public methods to interact with the object:

```lua
player:takeDamage(10)
```

### `@protected`

Use `@protected` to indicate that a field or method should be used by the class itself and by child classes.

```lua
local Class = require("class")

--- @class Entity: Class
--- @field protected _x number
--- @field protected _y number
local Entity = Class:extend()

--- @nodiscard
--- @param x number
--- @param y number
--- @return Entity
function Entity:new(x, y)
    local obj = Class.new(self) --- @cast obj Entity

    obj._x = x
    obj._y = y

    return obj
end

--- @protected
function Entity:_printPosition()
    print(self._x, self._y)
end

return Entity
```

A child class can use these fields and methods:

```lua
local Entity = require("entity")

--- @class Player: Entity
local Player = Entity:extend()

--- @nodiscard
--- @param x number
--- @param y number
--- @return Player
function Player:new(x, y)
    local obj = Entity.new(self, x, y) --- @cast obj Player
    return obj
end

function Player:debug()
    self:_printPosition()
end

return Player
```

In this case, `_printPosition` was not designed to be called by any part of the game, but it can be used by classes that inherit from `Entity`.

### Summary

```lua
--- @field private _health number
--- @field protected _x number

--- @private
function Player:_die()
end

--- @protected
function Entity:_printPosition()
end
```

- `@private`: internal use by the class itself.
- `@protected`: internal use by the class and its child classes.
- None of these annotations block access at runtime.
- They are used to document intent and help the LSP.

## Suggested organization

A simple organization for small or medium-sized projects could look like this:

```txt
project/
├── libs/
│   └── class.lua
├── objects/
│   ├── shape.lua
│   └── square.lua
└── main.lua
```

In this case, the files could be imported like this:

```lua
local Class = require("libs.class")
local Shape = require("objects.shape")
local Square = require("objects.square")
```

## Best practices

### Use `Class.new(self)` inside a base class

In a class that directly inherits from `Class`, use:

```lua
local obj = Class.new(self)
```

Example:

```lua
function Shape:new(x, y)
    local obj = Class.new(self) --- @cast obj Shape

    obj.x = x
    obj.y = y

    return obj
end
```

### Use `Parent.new(self, ...)` in child classes

In a class that inherits from another class, use the parent class constructor:

```lua
local obj = Parent.new(self, ...)
```

Example:

```lua
function Square:new(x, y, width, height)
    local obj = Shape.new(self, x, y) --- @cast obj Square

    obj.width = width
    obj.height = height

    return obj
end
```

### Avoid storing instance data in the class

Avoid this:

```lua
function Shape:new(x, y)
    self.x = x
    self.y = y
    return self
end
```

Prefer this:

```lua
function Shape:new(x, y)
    local obj = Class.new(self) --- @cast obj Shape

    obj.x = x
    obj.y = y

    return obj
end
```

The class should work as a blueprint. Data specific to each object should be stored in the instance.

## API

### `Class:new()`

Creates a new class instance.

```lua
local obj = Class.new(self)
```

Usually, you will not call `Class:new()` directly outside a constructor. It is used internally to create the object and apply the correct metatable.

### `Class:extend()`

Creates a new class that inherits from the current class.

```lua
local Shape = Class:extend()
local Square = Shape:extend()
```

### `Class:implement(...)`

Copies methods from one or more tables into the class.

```lua
Player:implement(Drawable, Updatable)
```

Only functions are copied, and only if the class does not already have a property with the same name.

### `Class:is(T)`

Checks whether the instance belongs to a class or inherits from it.

```lua
if player:is(Entity) then
    print("player is an Entity")
end
```

Returns `true` or `false`.

## Complete example

```lua
-- libs/class.lua
-- library file
```

```lua
-- shape.lua
local Class = require("libs.class")

--- @class Shape: Class
--- @field x number
--- @field y number
local Shape = Class:extend()

--- @nodiscard
--- @param x number
--- @param y number
--- @return Shape
function Shape:new(x, y)
    local obj = Class.new(self) --- @cast obj Shape

    obj.x = x
    obj.y = y

    return obj
end

function Shape:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

return Shape
```

```lua
-- square.lua
local Shape = require("shape")

--- @class Square: Shape
--- @field width number
--- @field height number
local Square = Shape:extend()

--- @nodiscard
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @return Square
function Square:new(x, y, width, height)
    local obj = Shape.new(self, x, y) --- @cast obj Square

    obj.width = width
    obj.height = height

    return obj
end

--- @nodiscard
--- @return number
function Square:getArea()
    return self.width * self.height
end

return Square
```

```lua
-- main.lua
local Shape = require("shape")
local Square = require("square")

local shape = Shape:new(10, 20)
local square = Square:new(0, 0, 16, 16)

shape:move(5, 5)
square:move(10, 0)

print(shape.x, shape.y)     -- 15 25
print(square.x, square.y)   -- 10 0
print(square:getArea())     -- 256

print(square:is(Square))    -- true
print(square:is(Shape))     -- true
```

## License

This library is based on rxi's Classic module.

- Original library: [classic](https://github.com/rxi/classic)
- Original author: rxi
- Modifications: Rafael Lopes

Distributed under the MIT License. See the `LICENSE` file for more details.
