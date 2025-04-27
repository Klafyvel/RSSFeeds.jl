Base.length(rss::RSS) = length(rss.channel.items)
function Base.iterate(rss::RSS)
    if length(rss) == 0
        return nothing
    else
        return (rss.channel.items[1], 2)
    end
end
function Base.iterate(rss::RSS, state)
    if state > lastindex(rss.channel.items)
        return nothing
    else
        return (rss.channel.items[state], nextind(rss.channel.items, state))
    end
end
Base.eltype(::Type{RSS}) = RSSItem
Base.isdone(rss::RSS) = length(rss.channel.items) == 0
Base.isdone(rss::RSS, state) = state > lastindex(rss.channel.items)
