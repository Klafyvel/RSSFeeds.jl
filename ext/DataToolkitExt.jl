module DataToolkitExt

using RSSFeeds
using Tables
using DataToolkitCore

DataToolkitCore.load(loader::DataLoader{:rss}, from::IO, as::Type) = DataToolkitCore.load(loader, read(from, String), as)
DataToolkitCore.load(loader::DataLoader{:rss}, from::FilePath, as::Type) = DataToolkitCore.load(loader, read(string(from), String), as)

function DataToolkitCore.load(loader::DataLoader{:rss}, from::String, as::Type)
    return invokelatest(Base.parse, RSSFeeds.RSS, from) |>
        if as == Any || QualifiedType(as) == QualifiedType(:RSSFeeds, :RSS)
        identity
    elseif as == Matrix
        Tables.matrix
    else
        as
    end
end

DataToolkitCore.supportedtypes(::Type{DataToolkitCore.DataLoader{:rss}}) = [
    QualifiedType(:DataFrames, :DataFrame),
    QualifiedType(:RSSFeeds, :RSS),
    QualifiedType(:Base, :Matrix),
]

end
