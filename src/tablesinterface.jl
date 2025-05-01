Tables.istable(::Type{RSS}) = true
function Tables.schema(rss::RSS)
    extensions = [Symbol(namespace * "_" * tag) for (namespace, tags) in rss.item_extensions for tag in tags]
    native_elements = collect(filter(x->x != :extensions, fieldnames(RSSItem)))
    native_elements_types = map(x -> fieldtype(RSSItem, x), native_elements)
    Tables.Schema(
        [native_elements..., extensions...],
        [native_elements_types..., fill(Union{XML.Node, Nothing}, length(extensions))...]
    )
end
DataAPI.nrow(rss::RSS) = length(rss)
DataAPI.ncol(rss::RSS) = fieldcount(RSSItem) - 1 + sum([length(ns) for ns in values(rss.item_extensions)])

Tables.columnaccess(::Type{RSS}) = true
Tables.columns(rss::RSS) = rss
function Tables.getcolumn(rss::RSS, nm::Symbol) 
    if !(nm in fieldnames(RSSItem))
        namespace, name = split(String(nm), "_")
        return collect(map(item -> get(item.extensions[namespace], name, nothing), rss.channel.items))
    else
        return collect(map(item -> getfield(item, nm), rss.channel.items))
    end
end
function Tables.getcolumn(rss::RSS, i::Int)
    names = Tables.columnnames(rss)
    return Tables.getcolumn(rss, names[i])
end
function Tables.columnnames(rss::RSS)
    extensions = [Symbol(namespace * "_" * tag) for (namespace, tags) in rss.item_extensions for tag in tags]
    native_elements = collect(filter(x->x != :extensions, fieldnames(RSSItem)))
    return [native_elements..., extensions...]
end
