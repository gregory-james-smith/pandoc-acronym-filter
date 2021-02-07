
function Pandoc(doc)
    -- Add acronym package
    local meta = doc.meta
    local options = {}
    if FORMAT == 'latex' then
        if meta["pandoc-acronym-filter"]["options"] then
            for _,i in ipairs(meta["pandoc-acronym-filter"]["options"]) do
                for _,j in ipairs(i) do
                    for _,k in pairs(j) do
                        table.insert(options, k)
                    end
                end
            end
        else
            -- Default values
            table.insert(options, "printonlyused")
            table.insert(options, "nohyperlinks")
        end
        local package = pandoc.RawBlock("latex", "\\usepackage[".. table.concat(options, "," ) .. "]{acronym}")
        local metablocks = {}
        table.insert(metablocks, package)
        if meta["header-includes"] then
            table.insert(meta["header-includes"], metablocks)
        else
            local metalist = {}
            table.insert(metalist, pandoc.MetaBlocks(metablocks))
            meta["header-includes"] = pandoc.MetaList(metalist)
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
    if FORMAT == 'latex' then
        -- Check for nolist option and remove heading if present
        local nolist = false
        for _, v in ipairs(options) do
            if v == "nolist" then
                nolist = true
            end
        end

        -- Add acronym descriptions in alphabetical order
        local list_acronyms = {}
        table.sort(keys)
        table.insert(list_acronyms, pandoc.RawBlock("latex", "\\begin{acronym}"))
        for _, k in ipairs(keys) do
            local v = definitions[k]
            local acronym = "\\acro{" .. k .. "}{" .. v .. "}"
            local block = pandoc.RawBlock("latex", acronym)
            table.insert(list_acronyms, block)
        end
        table.insert(list_acronyms, pandoc.RawBlock("latex", "\\end{acronym}"))

        -- No list
        if nolist then
            for _,v in ipairs(list_acronyms) do
                table.insert(output, v)
            end
        else
            table.insert(output, pandoc.Header(1, "Acronyms"))
            for _,v in ipairs(list_acronyms) do
                table.insert(output, v)
            end
        end

    end
    return pandoc.Pandoc(output, meta)
end











-- nolist
-- - defs at end

-- title & list
-- - Try to find title
-- - If not found add heading and defs at end
-- - If found add defs underneath heading

-- no title & list
-- - Acronym default heading
-- - Add heading at end
-- - Add defs at end






