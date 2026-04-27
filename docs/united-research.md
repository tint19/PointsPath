# United.com Award Search API Research

**Date:** April 27, 2026  
**Route Tested:** SEA → TYO (Tokyo)  
**Search Type:** Award travel (miles)

---

## API Endpoint

**URL:**
POST https://www.united.com/api/flight/FetchFlights

**Authentication:**
- Requires bearer token in header: `x-authorization-api`
- Token example: `bearer DAAAAJ+N3mzit2TrnlWvWRAAAADV...`
- This token likely expires and needs to be obtained from United's website

---

## Request Format

### Headers
```json
{
  "accept": "application/json",
  "content-type": "application/json",
  "x-authorization-api": "bearer <TOKEN>"
}
```

### Body Parameters
```json
{
  "SearchTypeSelection": 1,
  "AwardTravel": true,  // CRITICAL: Must be true for award search
  "NGRP": true,  // Enables dynamic pricing
  "Trips": [
    {
      "Origin": "SEA",
      "Destination": "TYO",
      "DepartDate": "2026-08-12",
      "Index": 1,
      "TripIndex": 1,
      "OriginAllAirports": true,
      "SearchFiltersIn": {
        "FareFamily": "ECONOMY"
      }
    }
  ],
  "CabinPreferenceMain": "economy",  // "economy", "premium", "business", "first"
  "PaxInfoList": [
    {"PaxType": 1}  // 1 = Adult passenger
  ]
}
```

---

## Response Structure

### Key Data Points

**Flight Information:**
```json
{
  "DepartDateTime": "2026-08-12 08:38",
  "FlightNumber": "2831",
  "Origin": "SEA",
  "Destination": "SFO",
  "MarketingCarrier": "UA",
  "TravelMinutes": 139,
  "Connections": [...]  // Array of connecting flights
}
```

**Pricing (MOST IMPORTANT):**
```json
{
  "Prices": [
    {
      "Currency": "MILES",
      "Amount": 54200.0,  // Miles required
      "PricingType": "Award"
    },
    {
      "Currency": "USD",
      "Amount": 5.60,  // Taxes/fees
      "PricingType": "Tax"
    }
  ],
  "AwardType": "Saver",  // "Saver" or "Standard"
  "CabinType": "Coach"  // "Coach", "PREMIUMPLUS", "Business", "First"
}
```

**Products Array:**
Multiple cabin classes returned in single response:
- Economy (Coach)
- Premium Economy (PREMIUMPLUS)
- Business
- First

Each product has its own pricing.

---

## Sample Response Data

### Example: SEA → TYO (via SFO)

**Economy Saver Award:**
- Miles: 54,200
- Fees: $5.60
- Award Type: Saver

**Premium Economy:**
- Miles: 93,800
- Fees: $5.60
- Award Type: Standard

**Business:**
- Miles: 188,200
- Fees: $5.60
- Award Type: Standard

---

## Key Observations

### ✅ What Works Well:
1. **Single API call returns all cabin classes** - don't need separate requests
2. **JSON structure is consistent** - easy to parse
3. **Miles + fees separated** - perfect for calculating CPP
4. **Connection details included** - can show full itinerary
5. **Availability indicated** by presence of pricing

### ⚠️ Challenges Identified:

1. **Authentication Required:**
   - Bearer token needed
   - Token appears to be dynamic/session-based
   - Will need to extract token from United's website on each scraper run

2. **No Direct "Availability" Boolean:**
   - Availability inferred by presence of pricing
   - If flight not available, it won't appear in results

3. **Warning Messages:**
   - Response includes: `"Message": "I'm sorry, we could not find answers to your query."`
   - Need to handle "no results" gracefully

4. **Rate Limiting:**
   - Unknown limits
   - Should implement delays between requests
   - Consider caching results

---

## Scraping Strategy

### Recommended Approach:

**Step 1:** Use Playwright to:
1. Navigate to united.com
2. Perform a manual search to trigger session/token generation
3. Extract bearer token from request headers

**Step 2:** Make direct API calls using extracted token

**Step 3:** Parse JSON response

**Step 4:** Store in database:
- Flight details
- Pricing (miles + fees)
- Cabin classes
- Award type (saver vs standard)

### Alternative Approach:

If token extraction fails, use Playwright to:
1. Fill search form
2. Submit search
3. Parse HTML results
4. More fragile but doesn't require token

---

## Data Mapping to Database
Response Field → Database Column
Prices[0].Amount (MILES) → search_cache.miles_required
Prices[1].Amount (USD) → search_cache.cash_fees
DepartDateTime → flight_details.departure_time
Origin → search_cache.origin_code
Destination → search_cache.destination_code
CabinType → search_cache.cabin_class
AwardType → (determines saver vs standard)

---

## Next Steps

1. ✅ Document API structure (DONE)
2. ⏳ Build Playwright scraper to extract bearer token
3. ⏳ Test API calls with different routes
4. ⏳ Build JSON parser
5. ⏳ Integrate with database schema

---

## Notes

- Token appears to be tied to session
- May need to simulate user login for better results
- NGRP parameter enables dynamic award pricing
- Response includes calendar data (not explored yet)