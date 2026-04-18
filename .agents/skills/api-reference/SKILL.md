---
name: api-reference
description: Complete API endpoint reference, request/response schemas, and data model mappings for the 5STR Laravel backend
---

# API Reference Skill

## Overview

Complete reference for all API endpoints of the 5STR Laravel backend. The Flutter app consumes this API. **Do NOT modify the backend** — only build the Flutter client to match these contracts.

## Authentication

All protected endpoints require:
```
Authorization: Bearer {sanctum_token}
```

Token is returned from `/api/v1/login` and `/api/v1/register` responses as `data.token`.

---

## Home Screen API

### GET `/api/v1/home`

Returns all data needed for the home screen in a single call.

**Query Params**: `latitude`, `longitude`, `radius` (km, default: 10)

**Response `data` fields**:
| Field | Type | Description |
|---|---|---|
| `banners` | `Banner[]` | Promotional banners carousel |
| `top_services` | `TopService[]` | Service category grid (max 8) |
| `trending_businesses` | `Business[]` | Trending businesses |
| `popular_nearby` | `Business[]` | Popular nearby (max 6) |
| `dynamic_sections` | `DynamicSection[]` | Backend-driven sections |
| `special_offers` | `SpecialOffer[]` | Active special offers |
| `featured_businesses` | `Business[]` | Featured/promoted businesses |
| `featured_attractions` | `FeaturedAttraction[]` | Featured attractions |
| `popular_attractions` | `FeaturedAttraction[]` | Popular attractions |
| `trending` | `Trending` | Today's trending data |
| `user_location` | `UserLocation` | Detected/provided location |
| `top_national_brands` | `NationalBrandSection[]` | National brand sections |

---

## Data Schemas

### Banner
```json
{
  "id": 1,
  "title": "Welcome to 5STR",
  "subtitle": "Discover local businesses",
  "image_url": "https://...",
  "link_type": "business|category|url|none",
  "link_id": 5,
  "link_url": "https://...",
  "position": "home_top",
  "is_active": true,
  "sort_order": 1,
  "click_count": 42,
  "view_count": 500
}
```

### TopService (Category)
```json
{
  "id": 1,
  "name": "Restaurants",
  "slug": "restaurants",
  "parent_id": null,
  "level": 1,
  "icon_image": "https://...",
  "banner_image": null,
  "description": "Food and dining",
  "color_code": "#FF5722",
  "sort_order": 1,
  "is_featured": true,
  "is_popular": true,
  "is_active": true,
  "total_businesses": 45
}
```

### Business
```json
{
  "id": 2,
  "business_name": "Star Kabab & Restaurant",
  "slug": "star-kabab-restaurant",
  "description": "Traditional Bengali cuisine",
  "landmark": "Near City Gate",
  "area": "Dhanmondi",
  "city": "Dhaka",
  "overall_rating": "3.50",
  "price_range": 2,
  "total_reviews": 11,
  "is_verified": true,
  "is_featured": false,
  "distance_km": "2.5",
  "category_name": "Restaurants",
  "subcategory_name": "Bengali",
  "images": {
    "logo": "https://...",
    "cover": "https://..."
  },
  "category": {
    "id": 1,
    "name": "Restaurants",
    "slug": "restaurants"
  },
  "type": "business"
}
```

### Business Detail (full)
Additional fields beyond Business:
```json
{
  "business_email": "contact@business.com",
  "business_phone": "+8801234567890",
  "website": "https://...",
  "address": "123 Main Street",
  "postal_code": "1205",
  "latitude": "23.7465",
  "longitude": "90.3754",
  "opening_hours": {
    "monday": "09:00-22:00",
    "tuesday": "09:00-22:00"
  },
  "business_features": ["delivery", "pickup", "dine_in"],
  "owner": { "id": 3, "name": "Owner Name" },
  "images": [
    { "id": 1, "image_url": "https://...", "is_logo": true }
  ],
  "offerings_count": 8,
  "offers_count": 2,
  "is_national": false,
  "service_coverage": "local",
  "business_model": "restaurant"
}
```

### Offering
```json
{
  "id": 1,
  "name": "Chicken Biryani",
  "description": "Aromatic basmati rice",
  "offering_type": "product",
  "price": "350.00",
  "currency": "BDT",
  "average_rating": "4.50",
  "total_reviews": 25,
  "is_popular": true,
  "is_featured": false,
  "is_available": true,
  "image_url": "https://...",
  "business": {
    "id": 2,
    "business_name": "Star Kabab",
    "slug": "star-kabab",
    "city": "Dhaka",
    "area": "Dhanmondi",
    "distance_km": 2.5
  },
  "variants": [
    { "id": 1, "variant_name": "Regular", "price": "350.00" },
    { "id": 2, "variant_name": "Large", "price": "450.00" }
  ]
}
```

### Review
```json
{
  "id": 15,
  "overall_rating": 4,
  "service_rating": 4,
  "quality_rating": 5,
  "value_rating": 3,
  "title": "Great food!",
  "review_text": "Amazing dining experience...",
  "pros": ["Delicious food", "Quick service"],
  "cons": ["Limited parking"],
  "visit_date": "2025-08-20",
  "amount_spent": "1250.00",
  "party_size": 4,
  "is_recommended": true,
  "is_verified_visit": true,
  "helpful_count": 5,
  "not_helpful_count": 1,
  "status": "approved",
  "images": [{ "id": 1, "image_url": "/storage/..." }],
  "user": {
    "id": 10,
    "name": "John Doe",
    "profile_image": "https://...",
    "trust_level": 3
  },
  "reviewable": {
    "type": "business",
    "id": 2,
    "business_name": "Star Kabab"
  },
  "created_at": "2025-08-23T10:30:00.000000Z"
}
```

### Attraction (List Item)
```json
{
  "id": 1,
  "name": "Cox's Bazar Beach",
  "slug": "coxs-bazar-beach",
  "description": "World's longest sea beach",
  "type": "natural",
  "category": "Beach",
  "subcategory": "Sea Beach",
  "city": "Cox's Bazar",
  "area": "Kolatoli",
  "district": "Cox's Bazar",
  "is_free": true,
  "entry_fee": "0.00",
  "currency": "BDT",
  "overall_rating": "4.50",
  "total_reviews": 245,
  "total_views": 5000,
  "discovery_score": "85.5",
  "estimated_duration_minutes": 180,
  "difficulty_level": "easy",
  "cover_image_url": "https://...",
  "google_maps_url": "https://maps.google.com/...",
  "distance": 450.2,
  "facilities": ["parking", "restroom", "food_stalls"],
  "best_time_to_visit": { "months": ["November", "December", "January"] },
  "is_featured": true,
  "is_verified": true
}
```

### Attraction Detail
All list item fields plus:
```json
{
  "latitude": "21.4272",
  "longitude": "92.0058",
  "address": "Marine Drive Road",
  "country": "Bangladesh",
  "opening_hours": "{\"monday\":{\"open\":\"06:00\",\"close\":\"20:00\"}}",
  "contact_info": "{\"phone\":\"+88...\",\"email\":\"...\"}",
  "accessibility_info": "{\"wheelchair_accessible\":true}",
  "total_likes": 500,
  "total_dislikes": 10,
  "total_shares": 200,
  "gallery": [ /* AttractionImage[] */ ],
  "reviews": [ /* AttractionReview[] */ ],
  "free_maps": {
    "openstreetmap_url": "https://...",
    "leaflet_data": { "center": {"lat": 21.42, "lng": 92.00}, "zoom": 15 }
  }
}
```

### Special Offer
```json
{
  "id": 1,
  "title": "20% Off on Biryani",
  "description": "Valid on weekdays",
  "offer_type": "percentage",
  "discount_percentage": "20.00",
  "valid_to": "2025-12-31",
  "business": {
    "id": 2,
    "business_name": "Star Kabab",
    "slug": "star-kabab",
    "overall_rating": "3.50",
    "logo_image": "https://..."
  }
}
```

### Notification
```json
{
  "id": "uuid-string",
  "title": "Review Approved",
  "body": "Your review for Star Kabab has been approved!",
  "icon": "check-circle",
  "color": "#10b981",
  "is_read": false,
  "read_at": null,
  "time_ago": "2 hours ago"
}
```

### User Collection
```json
{
  "id": 1,
  "name": "Best Restaurants in Dhaka",
  "description": "My favorite dining spots",
  "is_public": true,
  "cover_image": "https://...",
  "slug": "best-restaurants-dhaka",
  "businesses_count": 12,
  "followers_count": 5,
  "user": { "id": 1, "name": "John", "profile_image": "..." },
  "businesses": [ /* CollectionBusiness[] */ ],
  "is_followed_by_user": false,
  "can_edit": true
}
```

### User Profile
```json
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "city": "Dhaka",
  "profile_image": "/storage/profiles/avatar.jpg",
  "current_latitude": "23.7465",
  "current_longitude": "90.3754",
  "trust_level": 3,
  "total_points": 485,
  "total_favorites": 12,
  "total_reviews": 8,
  "user_level": {
    "level": 3,
    "level_name": "Active Explorer",
    "level_description": "Engaged user discovering local businesses",
    "total_score": 95.5,
    "progress_to_next_level": 65.2,
    "points_contribution": 48.5,
    "activity_contribution": 28.0,
    "trust_contribution": 18.0,
    "next_level_threshold": 120
  },
  "is_active": true,
  "roles": ["user"]
}
```

### National Brand Section
```json
{
  "section_title": "Top Ice Cream Brands",
  "section_type": "ice_cream",
  "section_description": "Popular ice cream brands across Bangladesh",
  "businesses": [
    {
      "id": 101,
      "business_name": "Polar Ice Cream",
      "slug": "polar-ice-cream",
      "overall_rating": "4.50",
      "total_reviews": 245,
      "is_national": true,
      "service_coverage": "nationwide",
      "business_model": "manufacturing",
      "logo_image": "https://..."
    }
  ]
}
```

---

## Request Bodies

### Register
```json
POST /api/v1/register
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+8801234567890",
  "password": "password123",
  "password_confirmation": "password123",
  "city": "Dhaka",
  "current_latitude": 23.7465,
  "current_longitude": 90.3754
}
```

### Login
```json
POST /api/v1/login
{
  "email": "john@example.com",
  "password": "password123"
}
```

### Submit Review
```json
POST /api/v1/reviews
Content-Type: multipart/form-data
{
  "reviewable_type": "business",
  "reviewable_id": 2,
  "overall_rating": 4,
  "service_rating": 4,
  "quality_rating": 5,
  "value_rating": 3,
  "title": "Great food!",
  "review_text": "Amazing experience...",
  "pros": ["Delicious food"],
  "cons": ["Limited parking"],
  "visit_date": "2025-08-20",
  "amount_spent": 1250.00,
  "party_size": 4,
  "is_recommended": true,
  "images": [file1, file2]
}
```

### Add Favorite
```json
POST /api/v1/user/favorites
{
  "favoritable_type": "business",
  "favoritable_id": 2
}
```

### Create Collection
```json
POST /api/v1/collections
{
  "name": "My Favorites",
  "description": "Best places in Dhaka",
  "is_public": true
}
```

### Track Interaction
```json
POST /api/v1/interactions/track
{
  "interaction_type": "view|click|search|favorite|share",
  "business_id": 2,
  "metadata": { "source": "home_popular" }
}
```

### Submit Business
```json
POST /api/v1/submissions/business
{
  "name": "New Restaurant",
  "description": "Great food place",
  "category": "Restaurants",
  "address": "123 Street",
  "city": "Dhaka",
  "latitude": 23.7465,
  "longitude": 90.3754,
  "phone": "+8801234567890",
  "opening_hours": [
    { "day": "monday", "open_time": "09:00", "close_time": "22:00", "is_closed": false }
  ],
  "images": ["base64_encoded_image_data"],
  "additional_info": "Near City Gate mall"
}
```

### Toggle Attraction Interaction
```json
POST /api/v1/attraction-interactions/toggle
{
  "attraction_id": 1,
  "interaction_type": "like|dislike|bookmark|wishlist"
}
```

---

## Pagination Pattern

All paginated endpoints return:
```json
{
  "current_page": 1,
  "data": [...],
  "last_page": 5,
  "per_page": 20,
  "total": 95,
  "next_page_url": "...?page=2",
  "prev_page_url": null,
  "has_more": true
}
```

Request params: `page=1&limit=20` (or `per_page=20`)

---

## Search API

### GET `/api/v1/search`

**Query Params**:
| Param | Type | Default | Description |
|---|---|---|---|
| `q` | string | — | Search term |
| `type` | string | "all" | "all", "businesses", "offerings", "attractions" |
| `latitude` | float | — | User latitude |
| `longitude` | float | — | User longitude |
| `radius` | int | 20 | Search radius (km) |
| `category_id` | int | — | Filter by category |
| `page` | int | 1 | Page number |
| `limit` | int | 20 | Results per page |
| `sort` | string | "relevance" | "relevance", "rating", "distance", "name", "popular", "newest" |
| `min_rating` | float | — | Minimum rating filter |
| `is_verified` | bool | — | Only verified businesses |

**Response**: Returns `results.businesses`, `results.offerings`, `results.attractions` each with their own pagination.

### GET `/api/v1/search/suggestions`
**Params**: `q` (min 2 chars), `limit` (default 10)
**Returns**: Array of `{ suggestion, type, id }`

---

## Error Codes

| HTTP Code | Meaning | Example |
|---|---|---|
| 200 | Success | Normal response |
| 201 | Created | After creating review, collection, etc. |
| 401 | Unauthorized | Invalid/expired token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Invalid resource ID |
| 422 | Validation Error | Missing/invalid fields |
| 429 | Rate Limited | Too many requests |
| 500 | Server Error | Backend issue |
