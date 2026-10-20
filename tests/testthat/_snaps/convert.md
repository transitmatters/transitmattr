# the response models' fields haven't changed

    Code
      for (model in response_models) {
        cat(model, ": ", paste(model_fields(model), collapse = ", "), "\n", sep = "")
      }
    Output
      AggregateByDate: count, mean, min, max, std, sum, 25%, 50%, 75%, service_date, peak, holiday, weekend
      AggregateByTime: count, mean, min, max, std, sum, 25%, 50%, 75%, dep_time_from_epoch, is_peak_day
      Alert: valid_from, valid_to, text
      AlertActivePeriod: start, end, current, upcoming
      BusSpeedLeaderboardEntry: route, count, total_time, miles_covered, n_traversals
      BusTripMetricsEntry: date, route, count, total_time, miles_covered, n_traversals
      ByDayKindServiceLevels: date, service_levels
      CrScorecardDirection: trips, firstTrip, lastTrip, maxGapMidday, maxGapEvening, hoursAtTarget, clockFaceShare, byHour
      CrScorecardEntry: date, routeId, days, outbound, inbound, peakTrips, reversePeakTrips
      CrTripMetricsEntry: date, route, fleet_trips
      DashboardLine: id, shortName, longName, routeIds, startDate, lineKind, ridershipHistory, serviceHistory, serviceRegimes
      DashboardServiceDay: cancelled, tripsPerHour, totalTrips
      DashboardServiceRegime: weekday, saturday, sunday
      DashboardServiceRegimes: current, oneYearAgo, baseline
      DashboardSummary: totalRidershipHistory, totalServiceHistory, totalRidershipPercentage, totalServicePercentage, totalPassengers, totalTrips, totalRoutesCancelled, totalReducedService, totalIncreasedService, startDate, endDate
      DwellEvent: route_id, direction, arr_dt, dep_dt, dwell_time_sec, vehicle_consist, vehicle_label
      FacilitiesResponse: data, jsonapi, links
      Facility: id, type, attributes, relationships, links
      FacilityAttributes: type, long_name, short_name, latitude, longitude, properties
      FacilityProperty: name, value
      FacilityRelationships: stop
      FacilityStopRelationship: data
      GetScheduledServiceResponse: start_date, end_date, start_date_service_levels, end_date_service_levels, counts
      HeadwayAggregateByDate: count, mean, min, max, std, sum, 25%, 50%, 75%, service_date, peak, holiday, weekend, bunched, on_time
      HeadwayEvent: route_id, direction, current_dep_dt, headway_time_sec, benchmark_headway_time_sec, vehicle_consist, vehicle_label
      HealthcheckResponse: status, failed_checks_sum, failed_checks
      JsonApiResourceIdentifier: id, type
      JsonApiVersion: version
      LineDelayEntry: date, line, total_delay_time, brake_problem, car_traffic, disabled_vehicle, door_problem, fire, flooding, mechanical_problem, medical_emergency, other, police_activity, power_problem, signal_problem, switch_problem, track_issue, track_work
      LiveAlert: id, type, header, active_period, stops, routes, description
      ReliabilityCounts: otpNumerator, otpDenominator, cancelled
      ReliabilityEntry: date, days, completed, onTime, requests, noShows, missed, otpNumerator, otpDenominator, cancelled, peak, offPeak
      RidershipEntry: date, count
      RoutesResponse: rapid_transit, bus, commuter_rail, ferry
      ScheduledServiceCount: date, count
      ServiceHoursEntry: date, scheduled, delivered
      ServiceLevelsByDayKind: weekday, saturday, sunday
      ServiceRidershipDashboardResponse: summaryData, modeData, lineData
      SpeedRestrictionZone: id, date, lineId, description, direction, reason, fromStopId, toStopId, reported, speedMph, trackFeet
      SpeedRestrictionsResponse: available, date, zones
      StationStop: stop_name, branches, station, order, stops, accessible, pedal_park, enclosed_bike_parking, terminus, disabled, short
      StopsResponse: type, direction, stations, service_start, service_end
      TimePredictionBucket: weekly, mode, route_id, bin, arrival_departure, num_predictions, num_accurate_predictions
      TimePredictionWeek: routeId, week, prediction
      TravelTimeAggregate2Response: by_date, by_time
      TravelTimeEvent: route_id, direction, dep_dt, arr_dt, travel_time_sec, benchmark_travel_time_sec, tm_benchmark_travel_time_sec, vehicle_consist, vehicle_label
      TripMetricsEntry: date, line, count, total_time, miles_covered, avg_car_age, pct_new_trips
      WeatherHourlyEntry: timestamp, temperature_f, weather_code, condition, precipitation_in, humidity_pct, wind_mph

