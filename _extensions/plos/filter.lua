

-- these classes, when placed on a span will be replaced
 -- with an identical LaTeX command for PDF output
 local texMappings = {
  "nameref"
}

return {
  {
    Meta = function(meta)
      if not meta['by-author'] then
        return meta
      end

      local has_equal = false
      local has_deceased = false
      local has_group = false

      -- For current addresses: deduplicate and assign symbols
      local address_list = {} -- ordered list of unique addresses (text only)
      local address_map = {}  -- address text -> index in address_list

      -- First pass: collect unique addresses and detect other attributes
      for _, author in ipairs(meta['by-author']) do
        if author.attributes then
          if author.attributes['equal-contributor'] then
            has_equal = true
          end
          if author.attributes.deceased then
            has_deceased = true
          end
        end
        if author.metadata and author.metadata.group then
          has_group = true
        end

        -- Collect unique current addresses (check metadata since it's custom attribute)
        local curr_addr = nil
        if author.metadata and author.metadata['current-address'] then
          curr_addr = pandoc.utils.stringify(author.metadata['current-address'])
        elseif author.attributes and author.attributes['current-address'] then
          curr_addr = pandoc.utils.stringify(author.attributes['current-address'])
        elseif author['current-address'] then
          -- Check root level as fallback
          curr_addr = pandoc.utils.stringify(author['current-address'])
        end

        if curr_addr and curr_addr ~= "" then
          if not address_map[curr_addr] then
            table.insert(address_list, curr_addr)
            address_map[curr_addr] = #address_list
          end
        end
      end

      -- Assign symbols based on total count
      local address_count = #address_list
      local address_with_symbols = {}

      if address_count == 1 then
        -- Single address: no suffix
        table.insert(address_with_symbols, {text = address_list[1], symbol = ""})
      elseif address_count > 1 then
        -- Multiple addresses: all get letter suffixes (a, b, c, ...)
        for i, addr_text in ipairs(address_list) do
          local symbol_suffix = " " .. string.char(96 + i) -- 'a', 'b', 'c', ...
          table.insert(address_with_symbols, {text = addr_text, symbol = symbol_suffix})
        end
      end

      -- Create reverse lookup: address text -> symbol suffix
      local address_to_symbol = {}
      for _, addr in ipairs(address_with_symbols) do
        address_to_symbol[addr.text] = addr.symbol
      end

      -- Second pass: assign symbols to authors
      for _, author in ipairs(meta['by-author']) do
        local curr_addr = nil
        if author.metadata and author.metadata['current-address'] then
          curr_addr = pandoc.utils.stringify(author.metadata['current-address'])
        elseif author.attributes and author.attributes['current-address'] then
          curr_addr = pandoc.utils.stringify(author.attributes['current-address'])
        elseif author['current-address'] then
          curr_addr = pandoc.utils.stringify(author['current-address'])
        end

        if curr_addr and curr_addr ~= "" then
          -- Store the symbol suffix for this author in attributes
          if not author.attributes then
            author.attributes = {}
          end
          author.attributes['current-address-symbol'] = pandoc.MetaString(address_to_symbol[curr_addr])
        end
      end

      -- Set metadata flags and lists
      if has_equal then meta['has-equal-contributor'] = true end
      if has_deceased then meta['has-deceased'] = true end
      if has_group then meta['has-group'] = true end
      if address_count > 0 then
        meta['has-current-address'] = true
        -- Convert address list to Pandoc Meta format
        local meta_addresses = {}
        for _, addr in ipairs(address_with_symbols) do
          table.insert(meta_addresses, {
            symbol = pandoc.MetaString(addr.symbol),
            text = pandoc.MetaString(addr.text)
          })
        end
        meta['current-addresses'] = pandoc.MetaList(meta_addresses)
      end

      return meta
    end,
    Span = function(el)
      local contentStr = pandoc.utils.stringify(el.content)
        for i, mapping in ipairs(texMappings) do
          if #el.attr.classes == 1 and el.attr.classes:includes(mapping) then
            if quarto.doc.is_format("pdf") then
              return pandoc.RawInline("tex", "\\" .. mapping .. "{" .. contentStr .. "}" )
            else 
              el.content = pandoc.Str( contentStr )
              return el
          end
        end
      end
    end,
    Div = function(div)
      -- Special treatment for supplementary material
      if (div.classes:includes("supp")) then
        if quarto.doc.is_format("pdf") then
          local headerNum = 0
          local header = pandoc.List()
          local labelId
          local paraNum = 0
          local para = pandoc.List()
          -- First Take element
          div.content:walk {
            Header = function(el)
              if (headerNum > 0) then
                error('Only one header can be set in supplementary section divs')
              end
              --[[
              el.level = 4
              headerNum = headerNum + 1
              header:insert(el)
              ]]
              el.content:insert(1, pandoc.RawInline('tex', '\\paragraph*{'))
              el.content:insert(pandoc.RawInline('tex', '}'))
              header:extend(el.content)
              labelId = el.identifier
              -- Remove header
              return {}
            end,
            Para = function(el)
              if (paraNum == 0) then
                -- first paragraph is title sentence
                if (el.content and el.content[1].t ~= "Strong") then
                  el.content = pandoc.Inlines(pandoc.Strong(el.content))
                end
                el.content:insert(1, pandoc.RawInline('tex', '{'))
                el.content:insert(pandoc.RawInline('tex', '}'))
              elseif (paraNum == 1) then
                -- ok
              else
                error('Only two paragraph are allowed in supplementary section div')
              end
              
              para:insert(el)
              paraNum = paraNum + 1
              -- remove Para
              return {}
            end
          }
          -- Build the new paragraph content
          header:extend({pandoc.Str("\n"), pandoc.RawInline("tex", "\\label{"..labelId.."}"), pandoc.Str("\n")})
          para = pandoc.utils.blocks_to_inlines(para, {pandoc.Space()})
          header:extend(para)
          -- Return the new para in place of the Div
          return pandoc.Para(header)
        end
      end
    end,
  }
}