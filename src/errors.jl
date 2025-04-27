abstract type RSSError <: Exception end

struct RSSFormatError <: RSSError
    msg::String
end
Base.showerror(io::IO, e::RSSFormatError) = print(io, e.msg)
