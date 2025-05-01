"""
$(README)

Refer to [`RSS`](@ref) to get started using a parsed feed.
"""
module RSSFeeds

import XML
import Dates
import Tables
import DataAPI
using OrderedCollections
using Compat
using DocStringExtensions

include("errors.jl")
include("rfc822timezones.jl")
include("nodes.jl")
include("parse.jl")
include("iterationinterface.jl")
include("tablesinterface.jl")
include("publicapi.jl")

end
