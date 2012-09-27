--[[--------------------------------------------------------------------------

  LGI testsuite, GObject.Object test suite.

  Copyright (c) 2010, 2011 Pavel Holejsovsky
  Licensed under the MIT license:
  http://www.opensource.org/licenses/mit-license.php

--]]--------------------------------------------------------------------------

local lgi = require 'lgi'
local core = require 'lgi.core'

local check = testsuite.check

-- Basic GObject testing
local gobject = testsuite.group.new('gobject')

function gobject.env_base()
   local GObject = lgi.GObject
   local obj = GObject.Object()
   check(type(core.object.env(obj)) == 'table')
   check(core.object.env(obj) == core.object.env(obj))
   check(next(core.object.env(obj)) == nil)
end

function gobject.env_persist()
   local Gtk = lgi.Gtk
   local window = Gtk.Window()
   local label = Gtk.Label()
   local env = core.object.env(label)
   window:_method_add(label)
   label = nil
   collectgarbage()
   label = window:get_child()
   check(env == core.object.env(label))
end

function gobject.object_new()
   local GObject = lgi.GObject
   local o = GObject.Object()
   o = nil
   collectgarbage()
end

function gobject.initunk_new()
   local GObject = lgi.GObject
   local o = GObject.InitiallyUnowned()

   -- Simulate sink by external container
   o:ref_sink()
   o:unref()

   o = nil
   collectgarbage()
end

function gobject.native()
   local GObject = lgi.GObject
   local o = GObject.Object()
   local p = o._native
   check(type(p) == 'userdata')
   check(GObject.Object(p) == o)
end

function gobject.gtype_create()
   local GObject = lgi.GObject
   local Gio = lgi.Gio
   local m = GObject.Object.new(Gio.ThemedIcon, { name = 'icon' })
   check(Gio.ThemedIcon:is_type_of(m))
end

function gobject.subclass1()
   local GObject = lgi.GObject
   local Derived = GObject.Object:derive('Derived1')
   local der = Derived()
   check(Derived:is_type_of(der))
   check(not Derived:is_type_of(GObject.Object()))
end

function gobject.subclass2()
   local GObject = lgi.GObject
   local Derived = GObject.Object:derive('Derived2')
   local Subderived = Derived:derive('Subderived2')
   local der = Derived()
   check(Derived:is_type_of(der))
   check(not Subderived:is_type_of(der))
   local sub = Subderived()
   check(Subderived:is_type_of(sub))
   check(Derived:is_type_of(sub))
   check(GObject.Object:is_type_of(sub))
end
