structure(list(method = "GET", url = "https://dashboard-api.labs.transitmatters.org/api/alerts/2024-01-15?route=Red", 
    status_code = 200L, headers = structure(list(date = "Wed, 24 Jun 2026 15:23:00 GMT", 
        `content-type` = "application/json", `content-length` = "674", 
        `x-amzn-requestid` = "8bfec990-458f-46f2-8aca-78b5dde9b503", 
        `access-control-allow-origin` = "https://dashboard.transitmatters.org", 
        `access-control-allow-headers` = "Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key", 
        `x-amz-apigw-id` = "feNtVHi7IAMEhRw=", `cache-control` = "public, max-age=7776000", 
        `x-amzn-trace-id` = "Root=1-6a3bf654-792d720e4ced518c357b10db;Parent=3f3753ec0a14ecdd;Sampled=0;Lineage=1:1e0fd665:0", 
        `access-control-max-age` = "3600"), class = "httr2_headers"), 
    body = charToRaw("[{\"valid_from\": \"2024-01-15T05:58:51\", \"valid_to\": \"2024-01-15T06:00:41\", \"text\": \"Red Line: Southbound delays of about 15 minutes due to an unauthorized person on the tracks at Central Sq. Trains may stand by at stations.\"}, {\"valid_from\": \"2024-01-15T06:06:40\", \"valid_to\": \"2024-01-15T06:14:40\", \"text\": \"Red Line: Southbound delays of about 15 minutes due to an unauthorized person on the tracks at Central Sq. Trains may stand by at stations.\"}, {\"valid_from\": \"2024-01-15T06:17:41\", \"valid_to\": \"2024-01-15T06:28:41\", \"text\": \"Red Line Update: Delays of about 20 minutes after an unauthorized person was removed from the tracks at Central Sq. Service is proceeding.\"}]"), 
    timing = c(redirect = 0, namelookup = 1.5e-05, connect = 0, 
    pretransfer = 8.4e-05, starttransfer = 0.081784, total = 0.081804
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
