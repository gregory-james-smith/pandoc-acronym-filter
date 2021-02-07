
        -- "header-includes": {
        --     "t": "MetaList",
        --     "c": [
        --         {
        --             "t": "MetaBlocks",
        --             "c": [
        --                 {
        --                     "t": "RawBlock",
        --                     "c": [
        --                         "latex",
        --                         "\\usepackage[printonlyused,nohyperlinks]{acronym}"
        --                     ]
        --                 }
        --             ]
        --         }
        --     ]
        -- },



--         header-includes:
-- - |
--   ```{=latex}
--   \usepackage[printonlyused,nohyperlinks]{acronym}
--   ```




function Pandoc(doc)
    -- Add acronym package
    -- TODO: Add package options
    local meta = doc.meta
    if FORMAT == 'latex' then
        local package = pandoc.RawBlock("latex", "\\usepackage[printonlyused,nohyperlinks]{acronym}")
        if meta["header-includes"] then

        else
            local b = {}
            table.insert(b, package)
            local c = pandoc.MetaBlocks(b)
            local d = {}
            table.insert(d, c)
            meta["header-includes"] = pandoc.MetaList(d)
        end
    end

    local blocks = doc.blocks
    -- Get all the acronym definitions
    local definitions = {}
    -- Filter out acronym definitions
    local filtered_blocks = {}
    -- Sorted list of acronyms
    local keys = {}
    for i, block in pairs(blocks) do
        if (block.tag == "Para") then
            local content = pandoc.utils.stringify(block.content)
            local acronym, description = string.match(content, '%*%[(.*)%]: (.*)')
            if (acronym) then
                definitions[acronym] = description
                -- Record all the keys and sort later
                table.insert(keys, acronym)
                -- Remove acronym definitions
            else
                table.insert(filtered_blocks, block)
            end
        else
            table.insert(filtered_blocks, block)
        end
    end
    -- Replace all the acronyms
    output = {}
    for i, block in pairs(filtered_blocks) do
        if (block.tag == "Para") then
            output[i] = pandoc.walk_block(block, {
                Str = function(el)
                    -- Replace acronym with abbreviation code
                    for k, v in pairs(definitions) do
                        -- Match key followed by punctuation
                        -- k or k. or k, or k; of k: or k...
                        -- Match plural key (followed by s)
                        local match = string.match(el.text, '^' .. k .. '[s]?%p*$')
                        if match then
                            if FORMAT == 'html' then
                                local acronym = "<abbr title=\"" .. v .. "\">" .. k .. "</abbr>"
                                local text = string.gsub(el.text, k, acronym, 1)
                                return pandoc.RawInline("html", text)
                            elseif FORMAT == 'latex' then
                                local plural = string.match(el.text, '^' .. k .. '[s]%p*$')
                                local new = plural and "\\acp{" .. k .. "}" or "\\ac{" .. k .. "}"
                                local old = plural and k .. 's' or k
                                local text = string.gsub(el.text, old, new, 1)
                                return pandoc.RawInline("latex", text)
                            end
                            return el.text
                        end
                    end
                    return el
                end
            })
        else
            output[i] = block
        end
    end
    -- Add list of acronyms
    -- TODO: Add acronym to "acronym" header/config header or at end of doc
    if FORMAT == 'latex' then
        -- Get a sorted list of acronyms
        table.sort(keys)
        -- Add acronym descriptions in alphabetical order
        table.insert(output, pandoc.Header(1, "Acronyms"))
        table.insert(output, pandoc.RawBlock("latex", "\\begin{acronym}"))
        for _, k in ipairs(keys) do
            local v = definitions[k]
            local acronym = "\\acro{" .. k .. "}{" .. v .. "}"
            local block = pandoc.RawBlock("latex", acronym)
            table.insert(output, block)
        end
        table.insert(output, pandoc.RawBlock("latex", "\\end{acronym}"))
    end
    return pandoc.Pandoc(output, meta)
end
