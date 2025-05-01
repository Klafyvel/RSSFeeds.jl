"""
Handles XML extensions to make them available as properties. For example, if
your RSS flux uses a `foo` extension and have a `<foo:bar></foo:bar>` tag, then
you can access it in your object as `obj.foo.bar`.

See also [`RSSExension`](@ref).
"""
abstract type AbstractRSS end
function Base.getproperty(obj::T, sym::Symbol) where {T <: AbstractRSS}
    if sym ∉ fieldnames(T) && String(sym) ∈ keys(obj.extensions)
        return RSSExension(obj.extensions[String(sym)])
    else
        return getfield(obj, sym)
    end
end
function Base.propertynames(obj::T, _::Bool = false) where {T <: AbstractRSS}
    return [fieldnames(T)..., Symbol.(keys(obj.extensions))...]
end

"""
A simple wrapper around `Dict{String, String}()` to allow subclasses of 
[`AbstractRSS`](@ref) access extensions as `obj.ext.tag`.
"""
struct RSSExension
    items::Dict{String, XML.Node}
end
function Base.getproperty(obj::RSSExension, sym::Symbol)
    items = getfield(obj, :items)
    if String(sym) ∈ keys(items)
        return items[String(sym)]
    else
        return getfield(obj, sym)
    end
end
function Base.propertynames(obj::RSSExension, _::Bool = false)
    return [fieldnames(RSSExension)..., Symbol.(keys(obj.items))...]
end

"""
An optional sub-element of channel, which contains three required and three
optional sub-elements.

# Fields

$(TYPEDFIELDS)
"""
struct RSSImage
    "URL of a GIF, JPEG or PNG image that represents the channel."
    url::String
    "describes the image, it's used in the ALT attribute of the HTML <img> tag when the channel is rendered in HTML."
    title::String
    "The URL of the site, when the channel is rendered, the image is a link to the site."
    link::String
    "Width of the image in pixels."
    width::Union{Int, Nothing}
    "Height of the image in pixels."
    height::Union{Int, Nothing}
    "Contains text that is included in the TITLE attribute of the link formed around the image in the HTML rendering."
    description::Union{String, Nothing}
end

"""
A channel may optionally contain a textInput sub-element, which contains four
required sub-elements.

# Fields

$(TYPEDFIELDS)
"""
struct RSSTextInput
    "Label of the Submit button in the text input area."
    title::String
    "Explains the text input area."
    description::String
    "The name of the text object in the text input area."
    name::String
    "The URL of the CGI script that processes text input requests."
    link::String
end

"""
Source field of an item.

# Fields

$(TYPEDFIELDS)
"""
struct RSSSource
    "URL of the XMLization of the source."
    url::String
    "Name of source RSS channel."
    source::String
end

"""
A media object that is attached to an item

# Fields

$(TYPEDFIELDS)
"""
struct RSSEnclosure
    "URL of the object."
    url::String
    "Length in bytes."
    length::Int
    "MIME-type."
    type::String
end

"""
The category to attach an element.

# Fields

$(TYPEDFIELDS)
"""
struct RSSCategory
    "A string that identifies a categorization taxonomy."
    domain::Union{String, Nothing}
    "A forward-slash-separated string that identifies a hierarchic location in the indicated taxonomy."
    category::String
end

"""
GUID stands for globally unique identifier. It's a string that uniquely identifies 
the item. When present, an aggregator may choose to use this string to determine
if an item is new.

# Fields

$(TYPEDFIELDS)
"""
struct RSSGUID
    "Value of the guid."
    guid::String
    """`true` when the reader may assume that it is a permalink to the item, that 
    is, a url that can be opened in a Web browser, that points to the full item 
    described by the <item> element."""
    isPermaLink::Bool
end

"""
An item may represent a "story" -- much like a story in a newspaper or magazine;
if so its description is a synopsis of the story, and the link points to the full
story. An item may also be complete in itself, if so, the description contains 
the text (entity-encoded HTML is allowed; see examples), and the link and title 
may be omitted. All elements of an item are optional, however at least one of 
title or description must be present.

# Fields

$(TYPEDFIELDS)
"""
Base.@kwdef struct RSSItem <: AbstractRSS
    "The title of the item."
    title::Union{String, Nothing} = nothing
    "The URL of the item."
    link::Union{String, Nothing} = nothing
    "The item synopsis."
    description::Union{String, Nothing} = nothing
    "Email address of the author of the item."
    author::Union{String, Nothing} = nothing
    "Includes the item in one or more categories. See [`RSSCategory`](@ref)."
    category::Vector{RSSCategory} = []
    "URL of a page for comments relating to the item."
    comments::Union{String, Nothing} = nothing
    "Describes a media object that is attached to the item. See [`RSSEnclosure`](@ref)."
    enclosure::Union{RSSEnclosure, Nothing} = nothing
    "A string that uniquely identifies the item. See [`RSSGUID`](@ref)."
    guid::Union{RSSGUID, Nothing} = nothing
    "Indicates when the item was published."
    pubDate::Union{Dates.Date, Nothing} = nothing
    "The RSS channel that the item came from. See [`RSSSource`](@ref)."
    source::Union{RSSSource, Nothing} = nothing
    "Stores extension tags."
    extensions::Dict{String, Dict{String, XML.Node}} = Dict()
    function RSSItem(title, link, description, author, category, comments, enclosure, guid, pubDate, source, extensions)
        if isnothing(title) && isnothing(link) && isnothing(description)
            throw(RSSFormatError("RSSItem must define one of `title`, `link`, or `description`."))
        end
        return new(title, link, description, author, category, comments, enclosure, guid, pubDate, source, extensions)
    end
end
Base.show(io::IO, item::RSSItem) = print(io, "RSSItem(\"$(something(item.title, item.link, item.description))\")")

"""
The channel content of an RSS feed.

# Fields

$(TYPEDFIELDS)
"""
Base.@kwdef struct RSSChannel <: AbstractRSS
    """The name of the channel. It's how people refer to your service. If you 
    have an HTML website that contains the same information as your RSS file, 
    the title of your channel should be the same as the title of your website."""
    title::String
    "The URL to the HTML website corresponding to the channel."
    link::String
    "Phrase or sentence describing the channel."
    description::String
    items::Vector{RSSItem} = []
    """The language the channel is written in. This allows aggregators to group 
    all Italian language sites, for example, on a single page. A list of allowable
    values for this element, as provided by Netscape, is here. You may also use 
    values defined by the W3C."""
    language::Union{String, Nothing} = nothing
    "Copyright notice for content in the channel."
    copyright::Union{String, Nothing} = nothing
    "Email address for person responsible for editorial content. Example: `geo@herald.com (George Matesky)`."
    managingEditor::Union{String, Nothing} = nothing
    "Email address for person responsible for technical issues relating to channel."
    webMaster::Union{String, Nothing} = nothing
    "The publication date for the content in the channel."
    pubDate::Union{Dates.DateTime, Nothing} = nothing
    "The last time the content of the channel changed."
    lastBuildDate::Union{Dates.DateTime, Nothing} = nothing
    "Specify one or more categories that the channel belongs to. See [`RSSCategory`](@ref)."
    category::Vector{RSSCategory} = []
    "A string indicating the program used to generate the channel."
    generator::Union{String, Nothing} = nothing
    """A URL that points to the documentation for the format used in the RSS file. 
    It's probably a pointer to [this](https://www.rssboard.org/rss-specification) page."""
    docs::Union{String, Nothing} = nothing
    "This library does not implement this part of the specification for now."
    cloud::Nothing = nothing
    """`ttl` stands for time to live. It's a number of minutes that indicates how 
    long a channel can be cached before refreshing from the source."""
    ttl::Union{Int, Nothing} = nothing
    "Specifies a GIF, JPEG or PNG image that can be displayed with the channel. See [`RSSImage`](@ref)."
    image::Union{RSSImage, Nothing} = nothing
    "The PICS rating for the channel."
    rating::Union{String, Nothing} = nothing
    "Specifies a text input box that can be displayed with the channel. See [`RSSTextInput`](@ref)."
    textInput::Union{RSSTextInput, Nothing} = nothing
    """A hint for aggregators telling them which hours they can skip. This  element 
    contains up to 24 hour sub-elements whose value is a number between 0 and 23, 
    representing a time in GMT, when aggregators, if they support the feature, 
    may not read the channel on hours listed in the `skipHours` element. The hour 
    beginning at midnight is hour zero."""
    skipHours::Vector{Int} = []
    """A hint for aggregators telling them which days they can skip. This element 
    contains up to seven day sub-elements whose value is `Dates.Monday`, 
    `Dates.Tuesday`, `Dates.Wednesday`, `Dates.Thursday`, `Dates.Friday`, 
    `Dates.Saturday` or `Dates.Sunday`. Aggregators may not read the channel 
    during days listed in the `skipDays` element."""
    skipDays::Vector{Int} = []
    "Stores extension tags."
    extensions::Dict{String, Dict{String, XML.Node}} = Dict()
end
Base.show(io::IO, channel::RSSChannel) = print(io, "RSSChannel(\"$(channel.title)\", \"$(channel.link)\")")

"""
Represents an RSS feed.

# Fields

$(TYPEDFIELDS)
"""
struct RSS <: AbstractRSS
    "RSS version number. Should be 2.0"
    version::VersionNumber
    "Channel for this RSS feed. See [`RSSChannel`](@ref)."
    channel::RSSChannel
    "Stores extension tags."
    extensions::Dict{String, Dict{String, XML.Node}}
    "Internal caching of extension tags used in RSS item children. It would be better to do this from the schema of the namespace, but this is good enough for now."
    item_extensions::Dict{String, OrderedSet{String}}
end
Base.show(io::IO, rss::RSS) = print(io, "RSS($(rss.version), \"$(rss.channel.title)\")")
