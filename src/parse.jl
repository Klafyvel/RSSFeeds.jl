"""
$(TYPEDSIGNATURES)

Internal function to parse an RSS feed.
"""
function parserss end

function parserss(T, s::AbstractString)
    node = parse(s, XML.Node)
    if length(node) == 0
        throw(RSSFormatError("Parsing empty RSS feed."))
    elseif length(node) == 1
        return parserss(T, last(XML.children(node)))
    else
        return parserss(T, node)
    end
end

function parseextension(c)
    tag = XML.tag(c)
    if isnothing(tag)
        throw(RSSFormatError("Cannot parse extension from empty tag."))
    elseif occursin(":", tag)
        prefix,tag = split(tag, ":")
        return prefix, tag, c
    else
        throw(RSSFormatError("Unhandled tag $c."))
    end
end

function parserss(::Type{RSS}, node::XML.AbstractXMLNode)
    if XML.nodetype(node) == XML.Document
        if length(node) < 2
            throw(RSSFormatError("XML document should have at least two top-most elements."))
        end
        return parserss(RSS, XML.children(node)[end])
    end
    if XML.nodetype(node)!=XML.Element
        throw(RSSFormatError("Unexpected XML node type: $(XML.nodetype(node))"))
    end
    if XML.tag(node) != "rss"
        throw(RSSFormatError("Unexpected top-most tag: $(XML.tag(node))"))
    end
    versionumber = nothing
    extensions = Dict{String, Dict{String, XML.Node}}()
    if isnothing(XML.attributes(node))
        throw(RSSFormatError("<rss> node must have attributes."))
    end
    for k in keys(XML.attributes(node))
        if k == "version"
            versionumber = VersionNumber(XML.attributes(node)["version"])
        elseif occursin(":", k)
            type,prefix = split(k, ":")
            if type == "xmlns"
                extensions[prefix] = Dict{String, XML.Node}()
            else
                throw(RSSFormatError("Unhandled attribute $k"))
            end
        else
            throw(RSSFormatError("Unhandled attribute $k"))
        end
    end
    if isnothing(versionumber) && versionumber != v"2.0"
        throw(RSSFormatError("RSS.jl does not handle RSS version $versionumber"))
    end
    channel = nothing
    for c in XML.children(node)
        if isnothing(channel) && XML.tag(c) == "channel"
            channel = parserss(RSSChannel, XML.children(node)[end], keys(extensions))
        elseif XML.tag(c) == "channel"
            throw(RSSFormatError("Multiple <channel> tag."))
        else
            prefix, tag, s = parseextension(c)
            extensions[prefix][tag] = s
        end
    end
    if isnothing(channel)
        throw(RSSFormatError("No <channel> tag."))
    end
    return RSS(versionumber, channel, extensions)
end

function parserss(::Type{RSSChannel}, node::XML.AbstractXMLNode, extensions)
    if XML.tag(node) != "channel"
        throw(RSSFormatError("Unexpected tag: $(XML.tag(node)). Expected `channel`."))
    end
    items = RSSItem[]
    string_variables = Dict{Symbol, Union{String, Nothing}}(
        :title => nothing,
        :link => nothing,
        :description => nothing,
        :language => nothing,
        :copyright => nothing,
        :managingEditor => nothing,
        :webMaster => nothing,
        :generator => nothing,
        :docs => nothing,
        :rating => nothing,
    )
    pubDate = nothing
    lastBuildDate = nothing
    category = RSSCategory[]
    cloud = nothing
    ttl = nothing
    image = nothing
    textInput = nothing
    skipHours = Int[]
    skipDays = Int[]
    extensions = Dict([
        e => Dict{String, XML.Node}()
        for e in extensions
    ])
    for c in XML.children(node)
        tag = XML.tag(c)
        if isnothing(tag)
            continue
        end
        if Symbol(tag) in keys(string_variables)
            string_variables[Symbol(tag)] = parserss(String, c)
        elseif tag == "pubDate"
            pubDate = parserss(Dates.DateTime, c)
        elseif tag == "lastBuildDate"
            lastBuildDate = parserss(Dates.DateTime, c)
        elseif tag == "category"
            push!(category, parserss(RSSCategory, c))
        elseif tag == "ttl"
            ttl = parserss(Int, c)
        elseif tag == "image"
            image = parserss(RSSImage, c)
        elseif tag == "textInput"
            textInput = parserss(RSSTextInput, c)
        elseif tag == "skipHours"
            hours = XML.children(c)
            if isnothing(hours)
                continue
            end
            append!(skipHours, map(hours) do d 
                parserss(Int, d)
            end)
        elseif tag == "skipDays"
            days = XML.children(c)
            if isnothing(days)
                continue
            end
            append!(skipDays, map(days) do d 
                day = lowercase(parserss(String, d))
                if day == "monday"
                    Dates.Monday
                elseif day == "tuesday"
                    Dates.Tuesday
                elseif day == "wednesday"
                    Dates.Wednesday
                elseif day == "thursday"
                    Dates.Thursday
                elseif day == "friday"
                    Dates.Friday
                elseif day == "saturday"
                    Dates.Saturday
                elseif day == "sunday"
                    Dates.Sunday
                else
                    throw(RSSFormatError("Unhandled skip day: $d"))
                end

            end)
        elseif tag == "item"
            push!(items, parserss(RSSItem, c, extensions))
        elseif occursin(":", tag)
            prefix, t, s = parseextension(c)
            extensions[prefix][t] = s
        else
            throw(RSSFormatError("Unexpected channel child: $(c)"))
        end
    end
    if isnothing(string_variables[:title])
        throw(RSSFormatError("Channel does not define a title."))
    end
    if isnothing(string_variables[:link])
        throw(RSSFormatError("Channel does not define a link."))
    end
    if isnothing(string_variables[:description])
        throw(RSSFormatError("Channel does not define a description."))
    end
    return RSSChannel(;
        string_variables..., items, pubDate, lastBuildDate, category, 
        cloud, ttl, image, textInput, skipHours, skipDays, extensions
    )
end

function parserss(::Type{String}, node::XML.AbstractXMLNode; throwempty=true)
    if !XML.is_simple(node)
        if throwempty
            throw(RSSFormatError("Node $(XML.tag(node)) is expected to contain a text child element. Got $(XML.write(node))."))
        else
            return ""
        end
    end
    val = XML.simple_value(node)
    if isnothing(val)
        return ""
    else
        return val
    end
end

function parserss(::Type{Int}, node::XML.AbstractXMLNode)
    return parse(Int, parserss(String, node))
end

function parserss(::Type{Dates.DateTime}, node::XML.AbstractXMLNode)
    return RFC822TimeZones.parse(parserss(String, node))
end

function parserss(::Type{RSSCategory}, node::XML.AbstractXMLNode)
    attributes = XML.attributes(node)
    domain = isnothing(attributes) ? nothing : get(attributes, "domain", nothing)
    return RSSCategory(domain, parserss(String, node))
end

function parserss(::Type{RSSImage}, node::XML.AbstractXMLNode)
    url = nothing
    title = nothing
    link = nothing
    width = nothing
    height = nothing
    description = nothing
    for c in XML.children(node)
        tag = XML.tag(c)
        if tag == "url"
            url = parserss(String, c)
        elseif tag == "title"
            title = parserss(String, c)
        elseif tag == "link"
            link = parserss(String, c)
        elseif tag == "width"
            width = parserss(Int, c)
        elseif tag == "height"
            height = parserss(Int, c)
        elseif tag == "description"
            description = parserss(String, c)
        else
            throw(RSSFormatError("Unexpected image child: $(c)"))
        end
    end
    if isnothing(url)
        throw(RSSFormatError("Image does not have an URL."))
    elseif isnothing(title)
        throw(RSSFormatError("Image does not have a title."))
    elseif isnothing(link)
        throw(RSSFormatError("Image does not have a link."))
    end
    return RSSImage(url, title, link, width, height, description)
end

function parserss(::Type{RSSTextInput}, node::XML.AbstractXMLNode)
    title = nothing
    description = nothing
    name = nothing
    link = nothing
    for c in XML.children(node)
        tag = XML.tag(c)
        if tag == "name"
            name = parserss(String, c)
        elseif tag == "title"
            title = parserss(String, c)
        elseif tag == "link"
            link = parserss(String, c)
        elseif tag == "description"
            description = parserss(String, c)
        else
            throw(RSSFormatError("Unexpected image child: $(c)"))
        end
    end
    return RSSTextInput(title, description, name, link)
end

function parserss(::Type{RSSItem}, node::XML.AbstractXMLNode, extensions)
    title= nothing
    link= nothing
    description= nothing
    author= nothing
    category= RSSCategory[]
    comments= nothing
    enclosure= nothing
    guid= nothing
    pubDate= nothing
    source = nothing
    extensions = Dict([
        e => Dict{String, XML.Node}()
        for e in extensions
    ])
    tags = XML.children(node)
    if !isnothing(tags)
        for c in tags
            tag = XML.tag(c)
            if isnothing(tag)
                continue
            end
            if tag == "title"
                title = parserss(String, c)
            elseif tag == "link"
                link = parserss(String, c)
            elseif tag == "description"
                description = parserss(String, c)
            elseif tag == "author"
                author = parserss(String, c)
            elseif tag == "category"
                push!(category, parserss(RSSCategory, c))
            elseif tag == "comments"
                comments = parserss(String, c)
            elseif tag == "enclosure"
                enclosure = parserss(RSSEnclosure, c)
            elseif tag == "guid"
                guid = parserss(RSSGUID, c)
            elseif tag == "pubDate"
                pubDate = parserss(Dates.DateTime, c)
            elseif tag == "source"
                source = parserss(RSSSource, c)
            elseif occursin(":", tag)
                prefix, tag, s = parseextension(c)
                extensions[prefix][tag] = s
            else
                throw(RSSFormatError("Unexpected channel child: $(c)"))
            end
        end
    end
    return RSSItem(
        title, link, description, author, category, comments, enclosure, guid, 
        pubDate, source, extensions
    )
end

function parserss(::Type{RSSEnclosure}, node::XML.AbstractXMLNode)
    url = nothing
    length = nothing
    type = nothing
    if isnothing(XML.attributes(node))
        throw(RSSFormatError("<enclosure> node must have three attributes: `url`, `length`, `type`."))
    end
    for (attr,val) in XML.attributes(node)
        if attr == "url"
            url = val
        elseif attr == "length"
            length = tryparse(Int, val)
        elseif attr == "type"
            type = val
        end
    end
    return RSSEnclosure(url, length, type)
end

function parserss(::Type{RSSGUID}, node::XML.AbstractXMLNode)
    attributes = XML.attributes(node)
    ispermalink = if isnothing(attributes)
        true 
    else
        get(attributes, "isPermaLink", "true") == "true"
    end
    return RSSGUID(parserss(String, node), ispermalink)
end

function parserss(::Type{RSSSource}, node::XML.AbstractXMLNode)
    attributes = XML.attributes(node)
    if isnothing(attributes) || "url" ∉ keys(attributes)
        throw(RSSFormatError("<source> node must have an `url` attribute."))
    end
    url = attributes["url"]
    return RSSSource(url, parserss(String, node))
end
