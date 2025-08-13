local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
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
  -- Svelte Component
  s("svc", fmt([[
    <script>
      {}
    </script>

    <div>
      {}
    </div>

    <style>
      {}
    </style>
  ]], { i(1), i(2, "Hello World"), i(3) }), snippet_opts),

  -- Script block
  s("script", fmt([[
    <script>
      {}
    </script>
  ]], { i(1) }), snippet_opts),

  -- Style block
  s("style", fmt([[
    <style>
      {}
    </style>
  ]], { i(1) }), snippet_opts),

  -- Reactive statement
  s("reactive", fmt([[
    $: {} = {};
  ]], { i(1, "computed"), i(2, "value") }), snippet_opts),

  -- Let directive
  s("let", fmt([[
    let {} = {};
  ]], { i(1, "name"), i(2, "value") }), snippet_opts),

  -- Export (props)
  s("export", fmt([[
    export let {} = {};
  ]], { i(1, "prop"), i(2, "defaultValue") }), snippet_opts),

  -- If block
  s("if", fmt([[
    {{#if {}}}
      {}
    {{/if}}
  ]], { i(1, "condition"), i(2) }), snippet_opts),

  -- If else block
  s("ifelse", fmt([[
    {{#if {}}}
      {}
    {{:else}}
      {}
    {{/if}}
  ]], { i(1, "condition"), i(2), i(3) }), snippet_opts),

  -- Each block
  s("each", fmt([[
    {{#each {} as {}}}
      {}
    {{/each}}
  ]], { i(1, "items"), i(2, "item"), i(3, "<div>{item}</div>") }), snippet_opts),

  -- Each block with index
  s("eachi", fmt([[
    {{#each {} as {}, {}}}
      {}
    {{/each}}
  ]], { i(1, "items"), i(2, "item"), i(3, "index"), i(4, "<div>{index}: {item}</div>") }), snippet_opts),

  -- Await block
  s("await", fmt([[
    {{#await {}}}
      <p>Loading...</p>
    {{:then {}}}
      {}
    {{:catch {}}}
      <p>Error: {{{}}}</p>
    {{/await}}
  ]], { i(1, "promise"), i(2, "result"), i(3, "<div>{result}</div>"), i(4, "error"), i(4) }), snippet_opts),

  -- Key block
  s("key", fmt([[
    {{#key {}}}
      {}
    {{/key}}
  ]], { i(1, "expression"), i(2) }), snippet_opts),

  -- Event handler
  s("on", fmt([[
    on:{}={{{}}}
  ]], { i(1, "click"), i(2, "handleClick") }), snippet_opts),

  -- Bind directive
  s("bind", fmt([[
    bind:{}={{{}}}
  ]], { i(1, "value"), i(2, "variable") }), snippet_opts),

  -- Class directive
  s("class", fmt([[
    class:{}={{{}}}
  ]], { i(1, "active"), i(2, "isActive") }), snippet_opts),

  -- Use directive
  s("use", fmt([[
    use:{}
  ]], { i(1, "action") }), snippet_opts),

  -- Transition
  s("transition", fmt([[
    transition:{}
  ]], { i(1, "fade") }), snippet_opts),

  -- In transition
  s("in", fmt([[
    in:{}
  ]], { i(1, "fade") }), snippet_opts),

  -- Out transition
  s("out", fmt([[
    out:{}
  ]], { i(1, "fade") }), snippet_opts),

  -- Console log
  s("cl", fmt([[
    console.log({});
  ]], { i(1, '"Hello"') }), snippet_opts),

  -- Function
  s("fn", fmt([[
    const {} = ({}) => {{
      {}
    }};
  ]], { i(1, "functionName"), i(2), i(3) }), snippet_opts),

  -- Svelte component import
  s("import", fmt([[
    import {} from '{}.svelte';
  ]], { i(1, "Component"), i(2, "./Component") }), snippet_opts),
}