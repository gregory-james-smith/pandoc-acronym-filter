
-- TODO: Add acronym package
function Blocks(blocks)
    -- Get all the acronym definitions
    definitions = {}
    filtered_blocks = {}
    for i, block in pairs(blocks) do
        if (block.tag == "Para") then
            local content = pandoc.utils.stringify(block.content)
            local acronym, description = string.match(content, '%*%[(.*)%]: (.*)')
            if (acronym) then
                definitions[acronym] = description
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
                                local acronym = "\\ac{" .. k .. "}"
                                local text = string.gsub(el.text, k, acronym, 1)
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
    -- TODO: Sort acronyms alphabetically https://stackoverflow.com/questions/26160327/sorting-a-lua-table-by-key
    -- TODO: Fix so that only done at end of doc not at end of list of blocks
    -- TODO: Add acronym to "acronym" header/config header or at end of doc
    if FORMAT == 'latex' then
        table.insert(output, pandoc.RawBlock("latex", "\\begin{acronym}"))
        for k, v in pairs(definitions) do
            local acronym = "\\acro{" .. k .. "}{" .. v .. "}"
            local block = pandoc.RawBlock("latex", acronym)
            table.insert(output, block)
        end
        table.insert(output, pandoc.RawBlock("latex", "\\end{acronym}"))
    end
    return output
end
