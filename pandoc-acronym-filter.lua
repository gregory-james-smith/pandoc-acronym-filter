
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
                    -- TODO: Also need to check for plurals
                    for k, v in pairs(definitions) do
                        if (el.text == k) then
                            return pandoc.RawInline("html", "<abbr title=\"" .. v .. "\">" .. k .. "</abbr>")
                        end
                    end
                    return el
                end
            })
        else
            output[i] = block
        end
    end
    -- TODO: Add acronym list somewhere. At end? Configure heading?
    return output
end
