using Test
using RSSFeeds, Dates

@testset "RFC822 datetimes." begin
    @test RSSFeeds.RFC822TimeZones.parse("Tue, 18 Mar 2025 00:00:00 GMT") == Dates.DateTime(2025, 03, 18, 0, 0)
    @test RSSFeeds.RFC822TimeZones.parse("Tue, 18 Mar 2025 00:00:00 +0100") == Dates.DateTime(2025, 03, 17, 23, 0)
    @test RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 00:00:00 GMT") == Dates.DateTime(2025, 03, 18, 0, 0)
    @test RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 00:00 GMT") == Dates.DateTime(2025, 03, 18, 0, 0)
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 GMT") # no time set
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 2025 00:00 GMT") # invalid day
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("1a Mar 2025 00:00 GMT") # invalid day
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mat 2025 00:00 GMT") # invalid month
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mar 20a5 00:00 GMT") # invalid year
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 00 GMT") # invalid time
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 0a:00 GMT") # invalid hour
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 00:a0 GMT") # invalid minute
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 00:00:a0 GMT") # invalid second
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 00:00 GRT") # invalid timezone
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 00:00 +11") # invalid timezone
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 00:00 +a100") # invalid timezone
    @test_throws RSSFeeds.RSSFormatError RSSFeeds.RFC822TimeZones.parse("18 Mar 2025 00:00 +010a") # invalid timezone
end
