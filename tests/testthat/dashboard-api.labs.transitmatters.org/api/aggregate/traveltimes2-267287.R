structure(list(method = "GET", url = "https://dashboard-api.labs.transitmatters.org/api/aggregate/traveltimes2?from_stop=place-pktrm&to_stop=place-davis&start_date=2024-01-01&end_date=2024-01-31", 
    status_code = 200L, headers = structure(list(date = "Wed, 24 Jun 2026 15:23:14 GMT", 
        `content-type` = "application/json", `content-length` = "40", 
        `x-amzn-requestid` = "05ab5ba0-0eda-4dd0-80f4-290e99c3df38", 
        `access-control-allow-origin` = "https://dashboard.transitmatters.org", 
        `access-control-allow-headers` = "Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key", 
        `x-amz-apigw-id` = "feNvXHRLoAMEY6w=", `cache-control` = "public, max-age=7776000", 
        `x-amzn-trace-id` = "Root=1-6a3bf661-4ea02b3d4839cb1367502816;Parent=658f2638017772a3;Sampled=0;Lineage=1:1e0fd665:0", 
        `access-control-max-age` = "3600"), class = "httr2_headers"), 
    body = charToRaw("{\n    \"by_date\": [],\n    \"by_time\": []\n}"), 
    timing = c(redirect = 0, namelookup = 1.6e-05, connect = 0, 
    pretransfer = 6.6e-05, starttransfer = 0.093943, total = 0.093963
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
