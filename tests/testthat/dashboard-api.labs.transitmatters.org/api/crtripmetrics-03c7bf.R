structure(list(method = "GET", url = "https://dashboard-api.labs.transitmatters.org/api/crtripmetrics?start_date=2025-01-01&end_date=2025-03-31&route=CR-Worcester&agg=monthly", 
    status_code = 200L, headers = structure(list(date = "Tue, 20 Oct 2026 02:24:17 GMT", 
        `content-type` = "application/json", `content-length` = "929", 
        `x-amzn-requestid` = "9c15dde9-e47b-4cae-baa4-93c2702ab952", 
        `access-control-allow-origin` = "https://dashboard.transitmatters.org", 
        `access-control-allow-headers` = "Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key", 
        `x-amz-apigw-id` = "FhWQ2HpgoAMEcSA=", `cache-control` = "public, max-age=7776000", 
        `x-amzn-trace-id` = "Root=1-6ad6d0d1-2d715d272fbb13ca7fa69ae2;Parent=4041e27c40e0f58c;Sampled=0;Lineage=1:1e0fd665:0", 
        `access-control-max-age` = "3600"), class = "httr2_headers"), 
    body = charToRaw("[\n    {\n        \"avg_cab_car_age\": 3.7,\n        \"date\": \"2025-01-01\",\n        \"fleet_mix_bombardier\": 0.0,\n        \"fleet_mix_kawasaki\": 0.0,\n        \"fleet_mix_locomotive\": 0.0,\n        \"fleet_mix_mbb\": 0.0,\n        \"fleet_mix_rotem\": 100.0,\n        \"fleet_trips\": 1348,\n        \"route\": \"CR-Worcester\"\n    },\n    {\n        \"avg_cab_car_age\": 4.3,\n        \"date\": \"2025-02-01\",\n        \"fleet_mix_bombardier\": 0.0,\n        \"fleet_mix_kawasaki\": 0.0,\n        \"fleet_mix_locomotive\": 0.0,\n        \"fleet_mix_mbb\": 0.0,\n        \"fleet_mix_rotem\": 100.0,\n        \"fleet_trips\": 1202,\n        \"route\": \"CR-Worcester\"\n    },\n    {\n        \"avg_cab_car_age\": 4.6,\n        \"date\": \"2025-03-01\",\n        \"fleet_mix_bombardier\": 0.0,\n        \"fleet_mix_kawasaki\": 0.0,\n        \"fleet_mix_locomotive\": 0.0,\n        \"fleet_mix_mbb\": 0.0,\n        \"fleet_mix_rotem\": 100.0,\n        \"fleet_trips\": 1090,\n        \"route\": \"CR-Worcester\"\n    }\n]"), 
    timing = c(redirect = 0, namelookup = 1.8e-05, connect = 0, 
    pretransfer = 0.00011, starttransfer = 0.061961, total = 0.06198
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
