pcall(require, "luacov")


print("------------------------------------")
print("Lua version: " .. (jit and jit.version or _VERSION))
print("------------------------------------")
print("")

local HAS_RUNNER = not not lunit
local lunit = require "lunit"
local TEST_CASE = lunit.TEST_CASE

local LUA_VER = _VERSION
local unpack, pow, bit32 = unpack, math.pow, bit32

local _ENV = TEST_CASE"some_test_case"

function test_1()
  local foo = require "foo"
  assert_function(foo.test_true)
  assert_true(foo.test_true())
end

function test_2()
  assert_false(false)
end

function test_3()
  local foo = require "foo"
  assert_function(foo.test_false)
  assert_false(foo.test_false())
end

if LUA_VER == 'Lua 5.2' then
function test_lua_52()
  assert_nil(unpack)
end
end

if LUA_VER == 'Lua 5.3' then
function test_lua_53()
  assert_nil(pow)
  assert_nil(bit32)
end
end

if not HAS_RUNNER then lunit.run() end
