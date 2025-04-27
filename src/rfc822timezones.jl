"""
This is an implementation of timezones as specified in [RFC822](https://www.w3.org/Protocols/rfc822/#z28).

The syntax is given below:

```
date-time   =  [ day "," ] date time        ; dd mm yy
                                            ;  hh:mm:ss zzz

day         =  "Mon"  / "Tue" /  "Wed"  / "Thu"
            /  "Fri"  / "Sat" /  "Sun"

date        =  1*2DIGIT month 2DIGIT        ; day month year
                                            ;  e.g. 20 Jun 82

month       =  "Jan"  /  "Feb" /  "Mar"  /  "Apr"
            /  "May"  /  "Jun" /  "Jul"  /  "Aug"
            /  "Sep"  /  "Oct" /  "Nov"  /  "Dec"

time        =  hour zone                    ; ANSI and Military

hour        =  2DIGIT ":" 2DIGIT [":" 2DIGIT]
                                            ; 00:00:00 - 23:59:59

zone        =  "UT"  / "GMT"                ; Universal Time
                                            ; North American : UT
            /  "EST" / "EDT"                ;  Eastern:  - 5/ - 4
            /  "CST" / "CDT"                ;  Central:  - 6/ - 5
            /  "MST" / "MDT"                ;  Mountain: - 7/ - 6
            /  "PST" / "PDT"                ;  Pacific:  - 8/ - 7
            /  1ALPHA                       ; Military: Z = UT;
                                            ;  A:-1; (J not used)
                                            ;  M:-12; N:+1; Y:+12
            / ( ("+" / "-") 4DIGIT )        ; Local differential
                                            ;  hours+min. (HHMM)
```

As per the RSS 2.0 specification, the year may be expressed with two characters
or four characters (four preferred).

"""
module RFC822TimeZones
import Dates

import ..RSSFormatError

const MONTH_TOKENS = Dict(
    [
        "jan" => 1,
        "feb" => 2,
        "mar" => 3,
        "apr" => 4,
        "may" => 5,
        "jun" => 6,
        "jul" => 7,
        "aug" => 8,
        "sep" => 9,
        "oct" => 10,
        "nov" => 11,
        "dec" => 12,
    ]
)
const ZONE_TOKENS = Dict(
    [
        "ut" => 0,
        "gmt" => 0,
        "est" => -5,
        "edt" => -4,
        "cst" => -6,
        "cdt" => -5,
        "mst" => -7,
        "mdt" => -6,
        "pst" => -8,
        "pdt" => -7,
        "z" => 0,
        "a" => -1,
        "m" => -12,
        "n" => +1,
        "y" => +12,
    ]
)

function parse(s::AbstractString)
    work_str = lowercase(s)

    # Step 1: get rid of day of the week.
    comma_split = split(work_str, ",")
    l = length(comma_split)
    if l == 1
        work_str = first(comma_split)
    elseif l == 2
        work_str = last(comma_split)
    else
        throw(RSSFormatError("Unable to parse date containing more than one comma: $s"))
    end

    # Step 2: split date, time, and zone
    space_split = rsplit(work_str, limit = 3)
    date_str = first(space_split)
    if length(space_split) != 3
        throw(RSSFormatError("Unable to parse date: $s. No time specified."))
    end
    date_str, hour_str, zone_str = space_split

    # Step 3: handle date
    date_space_split = split(date_str)
    if length(date_space_split) != 3
        throw(RSSFormatError("Date specification should contain three items: 1*2DIGIT month 2*4DIGIT in $s. Got: $date_str."))
    end
    day_str, month_str, year_str = date_space_split
    day = tryparse(Int, day_str)
    if isnothing(day)
        throw(RSSFormatError("Invalid day $day_str in date $s."))
    end
    if !(month_str in keys(MONTH_TOKENS))
        throw(RSSFormatError("Invalid month $month_str in date $s."))
    end
    month = MONTH_TOKENS[month_str]
    if !(length(year_str) in (2, 4))
        throw(RSSFormatError("Invalid year length $year_str in date $s. Expected 2 or 4 digits."))
    end
    year = tryparse(Int, year_str)
    if isnothing(year)
        throw(RSSFormatError("Invalid year $year_str in date $s."))
    end
    if length(year_str) == 2
        year += 1900
    end

    # Step 4: handle hour
    hour_comma_split = split(hour_str, ":")
    if !(length(hour_comma_split) in (2, 3))
        throw(RSSFormatError("Hour specification should contain two or three items: hh:mm[:ss] in $s. Got: $hour_str."))
    end
    hour_str = hour_comma_split[1]
    minute_str = hour_comma_split[2]
    second_str = if length(hour_comma_split) == 2
        "00"
    else
        hour_comma_split[3]
    end
    hour = tryparse(Int, hour_str)
    if isnothing(hour)
        throw(RSSFormatError("Hour number invalid in $s. Got: $hour_str."))
    end
    minute = tryparse(Int, minute_str)
    if isnothing(minute)
        throw(RSSFormatError("Minute number invalid in $s. Got: $minute_str."))
    end
    second = tryparse(Int, second_str)
    if isnothing(second)
        throw(RSSFormatError("Second number invalid in $s. Got: $second_str."))
    end

    # Step 5: handle time zone
    time_delta = Dates.Hour(0)
    if zone_str in keys(ZONE_TOKENS)
        time_delta = Dates.Hour(ZONE_TOKENS[zone_str])
    else
        starts_with_plus = startswith(zone_str, "+")
        starts_with_minus = startswith(zone_str, "-")
        if !starts_with_minus && !starts_with_plus
            throw(RSSFormatError("Invalid time zone specification in $s. Should start with + or -."))
        end
        zone_str = zone_str[2:end]
        if length(zone_str) != 4
            throw(RSSFormatError("Invalid time zone specification in $s. Expected four digits, got $zone_str."))
        end
        delta_hour_str, delta_minute_str = first(zone_str, 2), last(zone_str, 2)
        delta_hour = tryparse(Int, delta_hour_str)
        if isnothing(delta_hour)
            throw(RSSFormatError("Invalid delta hour in $s. Got $delta_hour_str"))
        end
        delta_minute = tryparse(Int, delta_minute_str)
        if isnothing(delta_minute)
            throw(RSSFormatError("Invalid delta minute in $s. Got $delta_minute_str"))
        end
        time_delta = Dates.Hour(delta_hour) + Dates.Minute(delta_minute)
        if starts_with_minus
            time_delta = -time_delta
        end
    end

    # Step 6 build the final object!
    return Dates.DateTime(year, month, day, hour, minute, second) - time_delta
end

end
