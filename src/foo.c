#include "lua.h"

static int ret_true(lua_State *L){
  lua_pushboolean(L, 1);
  return 1;
}

int luaopen_foo_core(lua_State *L){
  lua_newtable(L);
  lua_pushcfunction(L, ret_true);
  lua_setfield(L, -2, "test_true");
  return 1;
}
