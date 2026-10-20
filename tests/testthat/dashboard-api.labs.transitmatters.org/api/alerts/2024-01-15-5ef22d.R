structure(list(method = "GET", url = "https://dashboard-api.labs.transitmatters.org/api/alerts/2024-01-15?route=Red", 
    status_code = 200L, headers = structure(list(date = "Tue, 20 Oct 2026 02:24:13 GMT", 
        `content-type` = "application/json", `content-length` = "236", 
        `x-amzn-requestid` = "defc8555-fcad-4278-90f5-c8f8a9da2c46", 
        `access-control-allow-origin` = "https://dashboard.transitmatters.org", 
        `access-control-allow-headers` = "Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key", 
        `x-amz-apigw-id` = "FhWQIHNkIAMEePg=", `cache-control` = "public, max-age=7776000", 
        `x-amzn-trace-id` = "Root=1-6ad6d0cd-3e2955355223f33619baa655;Parent=2635ce8474040e73;Sampled=0;Lineage=1:1e0fd665:0", 
        `access-control-max-age` = "3600"), class = "httr2_headers"), 
    body = charToRaw("[{\"valid_from\": \"2024-01-15T05:58:00-05:00\", \"valid_to\": \"2024-01-15T08:16:40-05:00\", \"text\": \"Red Line Update: Delays of about 20 minutes after an unauthorized person was removed from the tracks at Central Sq. Service is proceeding.\"}]"), 
    timing = c(redirect = 0, namelookup = 1.3e-05, connect = 0, 
    pretransfer = 7.7e-05, starttransfer = 0.160807, total = 0.160825
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
