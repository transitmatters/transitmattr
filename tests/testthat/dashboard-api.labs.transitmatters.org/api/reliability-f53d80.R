structure(list(method = "GET", url = "https://dashboard-api.labs.transitmatters.org/api/reliability?route_id=CR-Worcester&start_date=2025-01-01&end_date=2025-03-31&agg=monthly", 
    status_code = 200L, headers = structure(list(date = "Tue, 20 Oct 2026 02:24:18 GMT", 
        `content-type` = "application/json", `content-length` = "719", 
        `x-amzn-requestid` = "8426d7f7-ff9f-40ee-98e9-843fc101a16f", 
        `access-control-allow-origin` = "https://dashboard.transitmatters.org", 
        `access-control-allow-headers` = "Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key", 
        `x-amz-apigw-id` = "FhWQ5GjIIAMErdg=", `cache-control` = "public, max-age=7776000", 
        `x-amzn-trace-id` = "Root=1-6ad6d0d2-7038629e63e12c207dc26246;Parent=35967d6c6b2445a6;Sampled=0;Lineage=1:1e0fd665:0", 
        `access-control-max-age` = "3600"), class = "httr2_headers"), 
    body = charToRaw("[{\"date\": \"2025-01-01\", \"days\": 14, \"cancelled\": 0, \"offPeak\": {\"cancelled\": 0, \"otpDenominator\": 427, \"otpNumerator\": 406}, \"otpDenominator\": 580, \"otpNumerator\": 537, \"peak\": {\"cancelled\": 0, \"otpDenominator\": 153, \"otpNumerator\": 131}}, {\"date\": \"2025-02-01\", \"days\": 10, \"cancelled\": 0, \"offPeak\": {\"cancelled\": 0, \"otpDenominator\": 344, \"otpNumerator\": 327}, \"otpDenominator\": 480, \"otpNumerator\": 453, \"peak\": {\"cancelled\": 0, \"otpDenominator\": 136, \"otpNumerator\": 126}}, {\"date\": \"2025-03-01\", \"days\": 31, \"cancelled\": 0, \"offPeak\": {\"cancelled\": 0, \"otpDenominator\": 999, \"otpNumerator\": 948}, \"otpDenominator\": 1356, \"otpNumerator\": 1250, \"peak\": {\"cancelled\": 0, \"otpDenominator\": 357, \"otpNumerator\": 302}}]"), 
    timing = c(redirect = 0, namelookup = 2e-05, connect = 0, 
    pretransfer = 0.00013, starttransfer = 0.06093, total = 0.060954
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
