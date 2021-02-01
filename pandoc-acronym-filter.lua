
function Blocks(blocks)
    -- Get all the acronym definitions
    definitions = {}
    for i, block in pairs(blocks) do
        if (block.tag == "Para") then
            local content = pandoc.utils.stringify(block.content)
            local acronym, description = string.match(content, '%*%[(.*)%]: (.*)')
            if (acronym) then
                definitions[acronym] = description
            end
        end
    end
    -- Replace all the acronyms
    output = {}
    for i, block in pairs(blocks) do
        if (block.tag == "Para") then
            output[i] = pandoc.walk_block(block, {
                Str = function(el)
                    -- TODO: Remove acronym definition
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
