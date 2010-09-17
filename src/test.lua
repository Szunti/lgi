--[[-- Assorted tests. --]]--

require 'lgi'
local GLib = require 'lgi.GLib'
local Gio = require 'lgi.Gio'

local tests = { 'gio_loadfile_sync', 'gio_loadfile_async', 'gio_loadfile_coro' }

function tests.gio_loadfile_sync()
   local file = Gio.file_new_for_path('test.lua')
   local ok, contents, length, etag = file:load_contents()
   assert(ok and type(contents) == 'string' and type(length) == 'number' and
    type(etag) == 'string')
end

function tests.gio_loadfile_async()
   local file = Gio.file_new_for_path('test.lua')
   local ok, contents, length, etag
   local main = GLib.MainLoop.new()
   file:load_contents_async(nil, function(_, result)
				    ok, contents, length, etag =
				       file:load_contents_finish(result)
				    main:quit()
				 end)
   main:run()
   assert(ok and type(contents) == 'string' and type(length) == 'number' and
    type(etag) == 'string')
end

function tests.gio_loadfile_coro()
   local ok, contents, length, etag
   local main = GLib.MainLoop.new()
   coroutine.wrap(
      function()
	 local running = coroutine.running()
	 local file = Gio.file_new_for_path('test.lua')
	 file:load_contents_async(
	    nil, function(f, result)
		    coroutine.resume(running, file:load_contents_finish(result))
		 end)
	 ok, contents, length, etag = coroutine.yield()
	 main:quit()
      end)()
   main:run()
   assert(ok and type(contents) == 'string' and type(length) == 'number' and
    type(etag) == 'string')
end

-- Runs specified test from tests table.
local function runtest(name)
   local func = tests[name]
   if type(func) ~= 'function' then
      print(string.format('ERRR: %s is not known test', name))
   else
      local ok, msg = pcall(tests[name])
      if ok then
	 print(string.format('PASS: %s', name))
      else
	 print(string.format('FAIL: %s: %s', name, tostring(msg)))
      end
   end
end

-- Run all tests from commandline, or all tests sequentially, if not
-- commandline is given.
local args = {...}
for _, name in ipairs(#args > 0 and args or tests) do runtest(name) end
