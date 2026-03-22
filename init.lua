--mod-version:3
local core = require "core"
local common = require "core.common"
local config = require "core.config"
local command = require "core.command"
local keymap = require "core.keymap"
local style = require "core.style"

local View = require "core.view"


-------
-- ? --
-------

local services = {}


---------------------------
-- Configuration Options --
---------------------------

config.plugins.services = common.merge({
  -- ?
  drawer_size = 300,
  -- ?
  error_pattern = "^%s*([^:]+):(%d+):(%d*):? %[?(%w*)%]?:? (.+)",
  file_pattern = "^%s*([^:]+):(%d+):(%d*):? (.+)",
  -- ?
  good_color = style.good,
  warning_color = style.warn,
  error_color = style.error
}, config.plugins.services)


----------
-- FONT --
----------

if not style.services then style.services = {} end
style.services.font = style.code_font:copy(style.code_font:get_height()*0.7)


-----------------------
-- Utility Functions --
-----------------------

-- ?


------------------
-- Service View --
------------------

local ServiceMessageView = View:extend()
function ServiceMessageView:new()
  ServiceMessageView.super.new(self)
  self.messages = { }
  self.target_size = config.plugins.services.drawer_size
  self.minimized = false
  self.scrollable = true
  self.init_size = true
  self.hovered_message = nil
  self.visible = false
  self.active_message = nil
  self.active_file = nil
  self.active_line = nil
end

function ServiceMessageView:update()
  -- ?
  local dest = self.visible and ((self.minimized and style.code_font:get_height() + style.padding.y * 2) or self.target_size) or 0
  if self.init_size then
    self.size.y = dest
    self.init_size = false
  else
    self:move_towards(self.size, "y", dest)
  end
  ServiceMessageView.super.update(self)
end

function ServiceMessageView:set_target_size(axis, value)
  if axis == "y" then
    self.target_size = value
    return true
  end
end

function ServiceMessageView:clear_messages()
  -- ?
end

function ServiceMessageView:add_message()
  -- ?
end

function ServiceMessageView:get_item_height()
  return style.services.font:get_height() + style.padding.y
end

function ServiceMessageView:get_h_scrollable_size()
  return math.huge
end

function ServiceMessageView:get_scrollable_size()
  return #self.messages and self:get_item_height() * (#self.messages + 1)
end

function ServiceMessageView:on_mouse_moved()
  -- ?
end

function ServiceMessageView:draw()
  -- ?
  self:draw_background(style.background3)
  -- TEST
  local x, y = self:get_content_offset()
  renderer.draw_text(
    style.code_font,
    "This is the MessageView",
    x,
    y,
    { common.color "#C88CDC" }
  )
  -- ?
  self:draw_scrollbar()
end


------------------
-- Data Storage --
------------------

function services.add_template()
	return function (t)
    table.insert(modules, t)
  end
end

local function parse_modules_list()
	local list = system.list_dir(USERDIR .. "/plugins/services/modules")
  local list_matched = {}
  local temp_string = ""
  for k, v in pairs(list) do
    temp_string = string.gsub(list[k], ".lua", "")
    table.insert(list_matched, temp_string)
  end
  return list_matched
end

function services.load()
  local modules_list = parse_modules_list()
  for _, v in ipairs(modules_list) do
    require("plugins.services.modules." .. v)
    core.log("Loaded service module: " .. v)
  end
end


----------
-- Main --
----------

-- ?
services.message_view = ServiceMessageView()

-- ?
-- TODO: place MessageView in the node of the DocView, not in the root node (look at build)
local node = core.root_view:get_active_node()
services.message_view_node = node:split("down", services.message_view, { y = true }, true)


--------------
-- Commands --
--------------

command.add(nil, {
  ["services:toggle-drawer"] = function()
    services.message_view.visible = not services.message_view.visible
  end,
  ["services:install-service"] = function()
    -- TODO: check if service is already installed
    -- TODO: add conflicting-services table ?
    core.log("TEST: install service")
  end
})


-----------------
-- Keybindings --
-----------------

keymap.add({
  ["f7"] = "services:toggle-drawer"
})


-------
-- ? --
-------

core.add_thread(function() services.load() end)

return services
