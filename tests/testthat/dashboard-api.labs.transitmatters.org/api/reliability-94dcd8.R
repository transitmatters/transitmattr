structure(list(method = "GET", url = "https://dashboard-api.labs.transitmatters.org/api/reliability?route_id=RIDE&start_date=2025-01-01&end_date=2025-03-31&agg=monthly", 
    status_code = 200L, headers = structure(list(date = "Tue, 20 Oct 2026 02:24:18 GMT", 
        `content-type` = "application/json", `content-length` = "220", 
        `x-amzn-requestid` = "c79fe978-26ad-42bd-96d6-597c2d86baa2", 
        `access-control-allow-origin` = "https://dashboard.transitmatters.org", 
        `access-control-allow-headers` = "Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key", 
        `x-amz-apigw-id` = "FhWQ6HyOIAMEs4w=", `cache-control` = "public, max-age=7776000", 
        `x-amzn-trace-id` = "Root=1-6ad6d0d2-0435041013c24a877a71a51f;Parent=3e9098c8b843a9f1;Sampled=0;Lineage=1:1e0fd665:0", 
        `access-control-max-age` = "3600"), class = "httr2_headers"), 
    body = charToRaw("[{\"date\": \"2025-01-01\", \"days\": 31, \"completed\": 97050, \"onTime\": 92353}, {\"date\": \"2025-02-01\", \"days\": 28, \"completed\": 88387, \"onTime\": 83551}, {\"date\": \"2025-03-01\", \"days\": 31, \"completed\": 103984, \"onTime\": 98532}]"), 
    timing = c(redirect = 0, namelookup = 2e-05, connect = 0, 
    pretransfer = 0.000112, starttransfer = 0.056108, total = 0.056126
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
