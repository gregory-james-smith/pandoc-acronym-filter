-- Get options metadata
function get_options(doc)
    local meta = doc.meta
    local options = {}
    if meta["pandoc-acronym-filter"] and meta["pandoc-acronym-filter"]["options"] then
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
    local title = meta["pandoc-acronym-filter"] and meta["pandoc-acronym-filter"]["title"]
    if title then
        return pandoc.utils.stringify(title)
    else
        return nil
    end
end

-- Utility function to append a list to the bottom of another table
function append_list_to_table_bottom(t, append)
    for _,v in ipairs(append) do
        table.insert(t, v)
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
            -- TODO: This code fails
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

-- Returns set of Latex code which defines the acronyms
function get_acronym_declarations(keys, definitions)
    local acronyms = {}
    -- Add acronym descriptions in alphabetical order
    table.insert(acronyms, pandoc.RawBlock("latex", "\\begin{acronym}"))
    for _, k in ipairs(keys) do
        local v = definitions[k]
        local acronym = "\\acro{" .. k .. "}{" .. v .. "}"
        local block = pandoc.RawBlock("latex", acronym)
        table.insert(acronyms, block)
    end
    table.insert(acronyms, pandoc.RawBlock("latex", "\\end{acronym}"))
    return acronyms
end

-- Scan through the document and pick out the acronyms and a filter of the blocks without the acronym definitions
function filter_document_for_acronyms(doc)
    -- List of acronyms sorted alphabetically
    local keys = {}
    -- Map of acronym definitions
    local definitions = {}
    -- Document blocks with the acronym definitions filtered out
    local filtered_blocks = {}

    for i, block in pairs(doc.blocks) do
        local is_para = block.tag == "Para"
        local content = is_para and pandoc.utils.stringify(block.content) or ""
        local acronym, description = string.match(content, '%*%[(.*)%]: (.*)')

        if is_para and acronym then
            -- Do not add to filtered blocks
            definitions[acronym] = description
            table.insert(keys, acronym)
        else
            table.insert(filtered_blocks, block)
        end
    end

    table.sort(keys)
    return keys, definitions, filtered_blocks
end

-- Scans through the list of blocks and returns a new list of blocks with the acronymn text replaced with coded acronyms
function replace_text_with_acronyms(definitions, blocks)
    output = {}
    for i, block in pairs(blocks) do
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
    return output
end

function Pandoc(doc)

    local keys, definitions, filtered_blocks = filter_document_for_acronyms(doc)
    local output = replace_text_with_acronyms(definitions, filtered_blocks)

    add_packages(doc)
    
    -- Add list of acronyms
    if FORMAT == 'latex' then
        local acronym_declarations = get_acronym_declarations(keys, definitions)
        local title = get_title(doc)
        -- No list
        if has_nolist(doc) then
            append_list_to_table_bottom(output, acronym_declarations)
        -- Title: Add declarations underneath heading
        elseif title then
            for index, block in ipairs(output) do
                if block.tag == "Header" and pandoc.utils.stringify(block.content) == title then
                    for i,v in ipairs(acronym_declarations) do
                        table.insert(output, index + i, v)
                    end
                    break
                end
            end
        -- No title: Add declarations at bottom
        else
            table.insert(output, pandoc.Header(1, "Acronyms"))
            append_list_to_table_bottom(output, acronym_declarations)
        end
    end

    return pandoc.Pandoc(output, doc.meta)
end
