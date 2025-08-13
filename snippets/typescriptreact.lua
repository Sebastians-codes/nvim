local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

-- Configure snippet options
local snippet_opts = {
  condition = function()
    return not ls.in_snippet()
  end,
  show_condition = function()
    return not ls.in_snippet()
  end
}

return {
  -- React Arrow Function Component without props
  s("rfc", fmt([[
    const {} = () => {{
      return (
        <div>
          {}
        </div>
      );
    }};

    export default {};
  ]], { i(1, "Component"), i(2, "Hello World"), rep(1) }), snippet_opts),

  -- React Arrow Function Component with props
  s("rfcp", fmt([[
    interface {}Props {{
      {}
    }}

    const {} = ({{ {} }}: {}Props) => {{
      return (
        <div>
          {}
        </div>
      );
    }};

    export default {};
  ]], { i(1, "Component"), i(2, "// props here"), rep(1), i(3), rep(1), i(4, "Hello World"), rep(1) }), snippet_opts),

  -- Interface
  s("int", fmt([[
    interface {} {{
      {}
    }}
  ]], { i(1, "Props"), i(2, "name: string;") }), snippet_opts),

  -- Type alias
  s("type", fmt([[
    type {} = {};
  ]], { i(1, "Props"), i(2, "{ name: string; }") }), snippet_opts),

  -- JSX Element
  s("jsx", fmt([[
    <{}{}>
      {}
    </{}>
  ]], { i(1, "div"), i(2), i(3), rep(1) }), snippet_opts),

  -- Self-closing JSX Element
  s("jsxs", fmt([[
    <{} {} />
  ]], { i(1, "input"), i(2, 'type="text"') }), snippet_opts),

  -- Console log
  s("cl", fmt([[
    console.log({});
  ]], { i(1, '"Hello"') }), snippet_opts),

  -- Export default
  s("ed", fmt([[
    export default {};
  ]], { i(1, "Component") }), snippet_opts),

  -- Conditional rendering
  s("cond", fmt([[
    {{ {} && {} }}
  ]], { i(1, "condition"), i(2, "<div>Content</div>") }), snippet_opts),

  -- Ternary operator
  s("tern", fmt([[
    {{ {} ? {} : {} }}
  ]], { i(1, "condition"), i(2, "trueValue"), i(3, "falseValue") }), snippet_opts),

  -- Map function
  s("map", fmt([[
    {{{}.map(({}: {}) => (
      {}
    ))}}
  ]], { i(1, "items"), i(2, "item"), i(3, "ItemType"), i(4, "<div key={item.id}>{item.name}</div>") }), snippet_opts),

  -- Event handler
  s("eh", fmt([[
    const handle{} = ({}: {}) => {{
      {}
    }};
  ]], { i(1, "Click"), i(2, "event"), i(3, "React.MouseEvent"), i(4) }), snippet_opts),

  -- Props destructuring
  s("props", fmt([[
    const {{ {} }}: {} = props;
  ]], { i(1, "prop1, prop2"), i(2, "Props") }), snippet_opts),
}