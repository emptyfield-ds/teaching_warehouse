-- Resume Lua Filter
--
-- This filter transforms pandoc divs written in the .qmd file into raw Typst
-- code that calls the `render-section()` function defined in typst-template.typ.
--
-- The .qmd author writes sections like this:
--
--   ::: {.section title="Education"}
--   ```yaml
--   entries:
--     - primary: Ph.D., Ipsum Dolor
--       secondary: Universitas Consectetur
--       dates: 2013 -- 2017
--       location: Adipiscing, EL
--   ```
--   :::
--
-- The filter parses the YAML, then emits a Typst function call:
--
--   #render-section("Education", (
--     (primary: "Ph.D., Ipsum Dolor", secondary: "...", ...),
--   ))

-- Escape characters that have special meaning in Typst *content* blocks
-- (text inside [...])
local function escape_typst(s)
  if s == nil then return "" end
  s = s:gsub("\\", "\\\\")
  s = s:gsub("#", "\\#")
  s = s:gsub("@", "\\@")
  s = s:gsub("%$", "\\$")
  s = s:gsub("<", "\\<")
  s = s:gsub(">", "\\>")
  return s
end

-- Escape characters for Typst *quoted strings* (text inside "...")
local function typst_string(s)
  if s == nil then return "" end
  s = s:gsub("\\", "\\\\")
  s = s:gsub('"', '\\"')
  return s
end

-- Convert a pandoc metadata value to a plain string.
-- Pandoc sometimes auto-converts URLs into Link elements, so we check for
-- that and extract the URL target directly.
local function stringify(val)
  if val == nil then return nil end
  if type(val) == "table" then
    for _, el in ipairs(val) do
      if type(el) == "table" and el.t == "Link" then
        return el.target
      end
    end
  end
  return pandoc.utils.stringify(val)
end

-- Parse a string of YAML by wrapping it as a markdown document's front matter
-- and using pandoc's built-in parser. Returns a metadata table.
local function parse_yaml(text)
  local doc = pandoc.read("---\n" .. text .. "\n---\n", "markdown")
  return doc.meta
end

-- Div() is called by pandoc for every ::: div ::: in the document.
-- We only act on divs with class "section"; everything else passes through.
function Div(div)
  if not div.classes:includes("section") then
    return nil
  end

  local title = div.attributes["title"] or "Untitled"

  -- Find the ```yaml code block inside the div
  local yaml_text = nil
  for _, block in ipairs(div.content) do
    if block.t == "CodeBlock" and block.classes:includes("yaml") then
      yaml_text = block.text
      break
    end
  end

  if yaml_text == nil then
    return nil
  end

  local meta = parse_yaml(yaml_text)
  local entries_list = meta.entries
  if entries_list == nil then
    return nil
  end

  -- Build the raw Typst code as an array of lines, then join them.
  -- Each entry becomes a Typst dictionary: (primary: "...", dates: [...], ...)
  local lines = {}
  table.insert(lines, '#render-section("' .. typst_string(title) .. '", (')

  for _, entry in ipairs(entries_list) do
    local primary = stringify(entry.primary) or ""
    local secondary = stringify(entry.secondary) or ""
    local dates = stringify(entry.dates) or ""
    local location = stringify(entry.location) or ""

    table.insert(lines, "  (")
    table.insert(lines, '    primary: "' .. typst_string(primary) .. '",')
    table.insert(lines, '    secondary: "' .. typst_string(secondary) .. '",')
    -- dates use content blocks [...] so that "--" renders as an en-dash
    table.insert(lines, "    dates: [" .. escape_typst(dates) .. "],")
    table.insert(lines, '    location: "' .. typst_string(location) .. '",')

    if entry.bullets then
      table.insert(lines, "    bullets: (")
      for _, bullet in ipairs(entry.bullets) do
        local b = stringify(bullet) or ""
        table.insert(lines, '      "' .. typst_string(b) .. '",')
      end
      table.insert(lines, "    ),")
    end

    table.insert(lines, "  ),")
  end

  table.insert(lines, "))")

  -- Replace the entire div with the generated Typst code
  return pandoc.RawBlock("typst", table.concat(lines, "\n"))
end
