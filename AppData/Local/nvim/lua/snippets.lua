local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node

ls.add_snippets("all", {
  s("date", {
    f(function() return { os.date("%Y-%m-%d") } end),
  }),
  s("time", {
    f(function() return { os.date("%H:%M") } end),
  }),
  s("datetime", {
    f(function() return { os.date("%Y-%m-%d %H:%M") } end),
  }),
})
