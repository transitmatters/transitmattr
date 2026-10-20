structure(list(method = "GET", url = "https://dashboard-api.labs.transitmatters.org/api/ridership?start_date=2024-01-01&end_date=2024-01-31&line_id=line-Red", 
    status_code = 200L, headers = structure(list(date = "Tue, 20 Oct 2026 02:24:13 GMT", 
        `content-type` = "application/json", `content-length` = "200", 
        `x-amzn-requestid` = "5371b276-142f-45f3-9969-f46e281a9e4e", 
        `access-control-allow-origin` = "https://dashboard.transitmatters.org", 
        `access-control-allow-headers` = "Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key", 
        `x-amz-apigw-id` = "FhWQJEWDIAMEQjg=", `cache-control` = "public, max-age=7776000", 
        `x-amzn-trace-id` = "Root=1-6ad6d0cd-37a4f70042309ead55786185;Parent=10b31bba565342cf;Sampled=0;Lineage=1:1e0fd665:0", 
        `access-control-max-age` = "3600"), class = "httr2_headers"), 
    body = charToRaw("[{\"date\": \"2024-01-01\", \"count\": 72986}, {\"date\": \"2024-01-08\", \"count\": 78348}, {\"date\": \"2024-01-15\", \"count\": 79336}, {\"date\": \"2024-01-22\", \"count\": 84922}, {\"date\": \"2024-01-29\", \"count\": 88096}]"), 
    timing = c(redirect = 0, namelookup = 1.5e-05, connect = 0, 
    pretransfer = 8.5e-05, starttransfer = 0.075257, total = 0.075274
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
