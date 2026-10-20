structure(list(method = "GET", url = "https://dashboard-api.labs.transitmatters.org/api/busspeedleaderboard?start_date=2026-09-01&end_date=2026-09-30&limit=5", 
    status_code = 200L, headers = structure(list(date = "Tue, 20 Oct 2026 02:24:44 GMT", 
        `content-type` = "application/json", `content-length` = "789", 
        `x-amzn-requestid` = "a92fc88d-31e7-4ffd-a67a-f62b03c29ea6", 
        `access-control-allow-origin` = "https://dashboard.transitmatters.org", 
        `access-control-allow-headers` = "Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key", 
        `x-amz-apigw-id` = "FhWU_GFwIAMEgUw=", `cache-control` = "public, max-age=3600", 
        `x-amzn-trace-id` = "Root=1-6ad6d0ec-5f3930fa449162b17c008a03;Parent=017732f530843121;Sampled=0;Lineage=1:1e0fd665:0", 
        `access-control-max-age` = "3600"), class = "httr2_headers"), 
    body = charToRaw("[\n    {\n        \"count\": 302,\n        \"miles_covered\": 569.9440000000001,\n        \"n_traversals\": 2926,\n        \"route\": \"55\",\n        \"total_time\": 328927\n    },\n    {\n        \"count\": 802,\n        \"miles_covered\": 3960.391,\n        \"n_traversals\": 24292,\n        \"route\": \"19\",\n        \"total_time\": 2160798.6\n    },\n    {\n        \"count\": 442,\n        \"miles_covered\": 1194.189,\n        \"n_traversals\": 4891,\n        \"route\": \"4\",\n        \"total_time\": 635123\n    },\n    {\n        \"count\": 925,\n        \"miles_covered\": 2117.01,\n        \"n_traversals\": 7652,\n        \"route\": \"504\",\n        \"total_time\": 1124076.4\n    },\n    {\n        \"count\": 3811,\n        \"miles_covered\": 16655.840000000004,\n        \"n_traversals\": 82967,\n        \"route\": \"1\",\n        \"total_time\": 8655255\n    }\n]"), 
    timing = c(redirect = 0, namelookup = 1.5e-05, connect = 0, 
    pretransfer = 0.000107, starttransfer = 0.115909, total = 0.115921
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
