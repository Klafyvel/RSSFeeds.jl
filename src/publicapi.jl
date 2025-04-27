Base.parse(::Type{RSS}, str::AbstractString) = parserss(RSS, str)
Base.parse(::Type{RSS}, str::Vector{UInt8}) = parserss(RSS, String(str))

@compat public RSS, RSSExension, RSSImage, RSSTextInput, RSSSource, RSSEnclosure, RSSCategory, RSSGUID, RSSChannel
