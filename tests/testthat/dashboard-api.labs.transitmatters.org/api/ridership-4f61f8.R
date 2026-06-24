structure(list(method = "GET", url = "https://dashboard-api.labs.transitmatters.org/api/ridership?start_date=2024-01-01&end_date=2024-01-31&line_id=line-Red", 
    status_code = 200L, headers = structure(list(date = "Wed, 24 Jun 2026 15:23:06 GMT", 
        `content-type` = "application/json", `content-length` = "200", 
        `x-amzn-requestid` = "aaa112f0-094c-437c-81f0-5ee8e236942a", 
        `access-control-allow-origin` = "https://dashboard.transitmatters.org", 
        `access-control-allow-headers` = "Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key", 
        `x-amz-apigw-id` = "feNuNHV0IAMEn6Q=", `cache-control` = "public, max-age=7776000", 
        `x-amzn-trace-id` = "Root=1-6a3bf65a-402a6ce90b1a8bdf04320616;Parent=1dc35d2b4f862d84;Sampled=0;Lineage=1:1e0fd665:0", 
        `access-control-max-age` = "3600"), class = "httr2_headers"), 
    body = charToRaw("[{\"date\": \"2024-01-01\", \"count\": 72986}, {\"date\": \"2024-01-08\", \"count\": 78348}, {\"date\": \"2024-01-15\", \"count\": 79336}, {\"date\": \"2024-01-22\", \"count\": 84922}, {\"date\": \"2024-01-29\", \"count\": 88096}]"), 
    timing = c(redirect = 0, namelookup = 1.5e-05, connect = 0, 
    pretransfer = 0.000102, starttransfer = 0.058352, total = 0.05837
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
