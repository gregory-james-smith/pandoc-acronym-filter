-- Get options metadata
function get_options(doc)
    local meta = doc.meta
    local options = {}
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
    return options
end

-- Get title metadata
function get_title(doc)
    local meta = doc.meta
    local title = meta["pandoc-acronym-filter"]["title"]
    if title then
        return pandoc.utils.stringify(title)
    else
        return nil
    end
end

-- Add Latex packages to document (acronym)
function add_packages(doc)
    if FORMAT == 'latex' then
        local meta = doc.meta
        local options = get_options(doc)
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
end

-- Returns true if nolist option
function has_nolist(doc)
    local options = get_options(doc)
    for _, v in ipairs(options) do
        if v == "nolist" then
            return true
        end
    end
    return false
end

function Pandoc(doc)
    
    add_packages(doc)

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
        if has_nolist(doc) then
            for _,v in ipairs(list_acronyms) do
                table.insert(output, v)
            end
        else
            local title = get_title(doc)
            if title then
                -- Try to find title
                for index, block in ipairs(output) do
                    if block.tag == "Header" and pandoc.utils.stringify(block.content) == title then
                        for i,v in ipairs(list_acronyms) do
                            table.insert(output, index + i, v)
                        end
                        break
                    end
                end
            else
                -- No title given so add Acronym section at end of document
                table.insert(output, pandoc.Header(1, "Acronyms"))
                for _,v in ipairs(list_acronyms) do
                    table.insert(output, v)
                end
            end
        end

    end
    return pandoc.Pandoc(output, doc.meta)
end
