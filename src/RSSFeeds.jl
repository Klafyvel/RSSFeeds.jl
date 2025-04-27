"""
$(README)

Refer to [`RSS`](@ref) to get started using a parsed feed.
"""
module RSSFeeds

import XML
import Dates
using Compat
using DocStringExtensions

include("errors.jl")
include("rfc822timezones.jl")
include("nodes.jl")
include("parse.jl")
include("iterationinterface.jl")
include("publicapi.jl")

end
