# RSSFeeds

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://klafyvel.github.io/RSSFeeds.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://klafyvel.github.io/RSSFeeds.jl/dev/)
[![Build Status](https://github.com/klafyvel/RSSFeeds.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/klafyvel/RSSFeeds.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/klafyvel/RSSFeeds.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/klafyvel/RSSFeeds.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A pure Julia library to handle RSS feeds. The library is currently under development, and the scope is not yet fully decided. For now only RSS 2.0 are handled, but Atom feeds may also be considered. Writing is not yet supported.

## Usage

The public API of RSSFeeds.jl only consist in overloading `Base.parse` for now.

```julia
using RSSFeeds
# Download a quality RSS feed:
rss_raw = download("https://bouletcorp.com/feed/rss.xml") |> read
# Parse it!
rss = parse(RSSFeeds.RSS, rss_raw)
```

You can iterate over the feed's items with a simple loop:
```julia
for item in rss
    println(item.title)
end
```

Extensions are left to you for parsing, but their access is facilitated. For example if your channel has a `<atom:link>` tag, you can access it as `rss.channel.atom.link`, which is an `XML.Node` element. See `XML.jl` documentation for reference.
