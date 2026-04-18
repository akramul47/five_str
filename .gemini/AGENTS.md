# 5STR Business Discovery Platform — Flutter Rebuild

## Project Overview

This project is a **Flutter rebuild** of the **5STR Business Discovery Platform** — a comprehensive mobile app for discovering local businesses, attractions, services, and offerings in Bangladesh. The original app was built with React Native (Expo) + Laravel backend. We are rebuilding the **frontend only** in Flutter, connecting to the **same existing Laravel backend API**.

## App Identity

- **App Name**: 5STR (Five Star)
- **Package/Bundle ID**: `com.fivestr.app`
- **Target Platforms**: Android & iOS (mobile-first)
- **Target Region**: Bangladesh (Dhaka, Chittagong, etc.)
- **Currency**: BDT (Bangladeshi Taka)
- **Default Location**: Chittagong (22.3569, 91.7832)

## Technology Stack

- **Framework**: Flutter (latest stable)
- **State Management**: Riverpod (recommended) or Provider
- **Navigation**: GoRouter (declarative, type-safe routing)
- **HTTP Client**: Dio with interceptors for auth token management
- **Local Storage**: SharedPreferences for tokens/settings, Hive for caching
- **Location**: geolocator + geocoding packages
- **Image Loading**: cached_network_image
- **Icons**: Use Ionicons equivalents via `flutter_vector_icons` or `icons_plus`
- **Architecture**: Clean Architecture (data → domain → presentation)

## Backend API

The app connects to an existing Laravel 11 backend. **Do NOT modify the backend.**

### Base Configuration

```
BASE_URL: Configurable via environment variable or .env
API Prefix: /api/v1
Authentication: Laravel Sanctum (Bearer token)
```

### API Response Standard Format

All API responses follow this pattern:
```json
{
  "success": true|false,
  "message": "Optional message",
  "data": { ... }
}
```

Error responses:
```json
{
  "success": false,
  "message": "Error description",
  "errors": { "field": ["error message"] }
}
```

### Authentication Flow

1. **Register**: `POST /api/v1/register` — Returns user + token
2. **Login**: `POST /api/v1/login` — Returns user + token  
3. **Google OAuth**: `POST /auth/google/token` — Exchange Google token
4. **Get User**: `GET /api/v1/auth/user` — Requires Bearer token
5. **Update Profile**: `PUT /api/v1/auth/profile` — Requires Bearer token
6. **Logout**: `POST /api/v1/auth/logout` — Requires Bearer token
7. **Email Verify**: `POST /api/v1/email/verify`
8. **Email Resend**: `POST /api/v1/email/resend`

### Complete API Endpoints Reference

#### Public Endpoints (No Auth Required)

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/home` | GET | Home screen data (banners, services, popular, featured, trending) |
| `/api/v1/home/top-services` | GET | All top service categories |
| `/api/v1/home/popular-nearby` | GET | Popular businesses nearby |
| `/api/v1/home/dynamic-sections/{section}` | GET | Dynamic section businesses |
| `/api/v1/home/featured-businesses` | GET | Featured businesses |
| `/api/v1/home/special-offers` | GET | Special offers |
| `/api/v1/home/national-brands` | GET | National brand sections |
| `/api/v1/home/featured-attractions` | GET | Featured attractions |
| `/api/v1/home/popular-attractions` | GET | Popular attractions |
| `/api/v1/trending` | GET | Trending data |
| `/api/v1/today-trending` | GET | Today's trending |
| `/api/v1/top-rated` | GET | Top rated businesses |
| `/api/v1/open-now` | GET | Currently open businesses |
| `/api/v1/search` | GET | Universal search (businesses, offerings, attractions) |
| `/api/v1/search/suggestions` | GET | Search autocomplete |
| `/api/v1/search/popular` | GET | Popular search terms |
| `/api/v1/categories` | GET | All categories |
| `/api/v1/categories/{id}` | GET | Category details |
| `/api/v1/categories/{id}/businesses` | GET | Businesses in category |
| `/api/v1/businesses` | GET | Business listing |
| `/api/v1/businesses/{id}` | GET | Business details |
| `/api/v1/businesses/{id}/reviews` | GET | Business reviews |
| `/api/v1/businesses/{id}/offers` | GET | Business offers |
| `/api/v1/businesses/national` | GET | National businesses |
| `/api/v1/businesses/{business}/offerings` | GET | Business offerings |
| `/api/v1/businesses/{business}/offerings/{offering}` | GET | Offering details |
| `/api/v1/offers` | GET | All offers |
| `/api/v1/offers/{id}` | GET | Offer details |
| `/api/v1/attractions` | GET | Attractions list |
| `/api/v1/attractions/{id}` | GET | Attraction details |
| `/api/v1/attractions/{id}/reviews` | GET | Attraction reviews |
| `/api/v1/attractions/{id}/gallery` | GET | Attraction gallery |
| `/api/v1/attractions/featured` | GET | Featured attractions |
| `/api/v1/attractions/popular` | GET | Popular attractions |

#### Protected Endpoints (Auth Required — Bearer Token)

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/auth/user` | GET | Get authenticated user profile |
| `/api/v1/auth/profile` | PUT | Update user profile |
| `/api/v1/auth/logout` | POST | Logout |
| `/api/v1/user/favorites` | GET | Get user favorites |
| `/api/v1/user/favorites` | POST | Add to favorites |
| `/api/v1/user/favorites/{id}` | DELETE | Remove from favorites |
| `/api/v1/user/reviews` | GET | Get user's reviews |
| `/api/v1/user/points` | GET | Get user points |
| `/api/v1/reviews` | POST | Submit review |
| `/api/v1/reviews/{id}` | GET/PUT/DELETE | Review CRUD |
| `/api/v1/reviews/{id}/vote` | POST | Vote review helpful |
| `/api/v1/notifications` | GET | List notifications |
| `/api/v1/notifications/stats` | GET | Notification stats |
| `/api/v1/notifications/{id}/read` | PATCH | Mark as read |
| `/api/v1/notifications/mark-all-read` | PATCH | Mark all read |
| `/api/v1/collections` | GET/POST | List/Create collections |
| `/api/v1/collections/{id}` | GET/PUT/DELETE | Collection CRUD |
| `/api/v1/collections/{id}/businesses` | POST | Add business to collection |
| `/api/v1/collections/{id}/businesses/{bid}` | DELETE | Remove business |
| `/api/v1/collections/{id}/follow` | POST/DELETE | Follow/Unfollow |
| `/api/v1/recommendations` | GET | Get recommendations |
| `/api/v1/recommendations/advanced-ai` | GET | AI recommendations |
| `/api/v1/interactions/track` | POST | Track user interaction |
| `/api/v1/interactions/batch` | POST | Batch track interactions |
| `/api/v1/submissions/business` | POST | Submit business |
| `/api/v1/submissions/attraction` | POST | Submit attraction |
| `/api/v1/submissions/offering` | POST | Submit offering |
| `/api/v1/submissions/my-submissions` | GET | User's submissions |
| `/api/v1/attraction-interactions/toggle` | POST | Toggle attraction interaction |
| `/api/v1/attraction-interactions/status/{id}` | GET | Check interaction status |
| `/api/v1/attraction-reviews/{id}/reviews` | POST | Submit attraction review |

### Location Parameters

Most listing/search endpoints accept these query parameters:
- `latitude` — User's latitude
- `longitude` — User's longitude
- `radius` — Search radius in km (default: 10-20)

### Pagination Parameters

- `page` — Page number (default: 1)
- `limit` or `per_page` — Results per page (default: 20)

## App Architecture & Screens

### Navigation Structure

**Bottom Tab Navigation** (5 tabs):
1. **Home** — Main discovery feed
2. **Discover** — Category browsing & exploration
3. **Favourites** — Saved businesses & attractions
4. **Collections** — User-curated collections
5. **Profile** — User profile & settings

### Screen Inventory

#### Main Tab Screens
- `HomeScreen` — Banners carousel, top services grid, popular nearby, featured businesses, trending, special offers, national brands, featured attractions
- `DiscoverScreen` — Category grid, search, featured categories
- `FavouritesScreen` — Favorited businesses & attractions with tabs 
- `CollectionsScreen` — User's collections, popular collections, search collections
- `ProfileScreen` — User info, level/points, settings, reviews, submissions

#### Auth Screens
- `LoginScreen` — Email/password login, Google sign-in
- `RegisterScreen` — Registration with name, email, phone, password, city, location
- `OnboardingScreen` — App introduction slides
- `WelcomeScreen` — Welcome/landing page

#### Detail Screens
- `BusinessDetailScreen` — Full business profile (info, gallery, map, offerings, reviews, offers)
- `AttractionDetailScreen` — Attraction details (gallery, map, reviews, facilities, interactions)
- `OfferingDetailScreen` — Product/service details with reviews
- `OfferDetailScreen` — Special offer details
- `CategoryScreen` — Businesses filtered by category
- `CollectionDetailScreen` — Collection with its businesses
- `UserProfileScreen` — Public user profile view

#### List/Browse Screens
- `SearchScreen` — Universal search with filters, autocomplete, results tabs
- `TopServicesScreen` — All service categories
- `PopularNearbyScreen` — Popular businesses list
- `FeaturedBusinessesScreen` — Featured businesses list
- `SpecialOffersScreen` — All special offers
- `TopNationalBrandsScreen` — National brands by section
- `TrendingScreen` — Trending businesses & offerings
- `TopRatedScreen` — Top rated businesses
- `OpenNowScreen` — Currently open businesses
- `AttractionsScreen` — All attractions with search
- `FeaturedAttractionsScreen` — Featured attractions list
- `PopularAttractionsScreen` — Popular attractions list
- `RecommendationsScreen` — AI-powered recommendations
- `AIRecommendationsScreen` — Advanced AI recommendations
- `LocationSelectionScreen` — Manual location picker (Bangladesh districts)

#### Action Screens
- `WriteReviewScreen` — Submit/edit business review
- `ReviewDetailsScreen` — Review details with voting
- `NotificationsScreen` — Notification center
- `MySubmissionsScreen` — User's submitted content
- `SubmissionDetailsScreen` — Submission status details

### Modal Components
- `EditProfileModal` — Edit user profile with image upload
- `SubmitBusinessModal` — Submit new business
- `SubmitAttractionModal` — Submit new attraction
- `SubmitOfferingModal` — Submit new offering
- `CreateCollectionModal` — Create new collection
- `EditCollectionModal` — Edit collection
- `AddToCollectionModal` — Add business to collection
- `RecordVisitModal` — Record attraction visit
- `EmailVerificationModal` — Email verification flow
- `ManageBusinessModal` — Business management

### Shared Components
- `TrackableBusinessCard` — Business card with view tracking
- `AttractionCard` / `TrackableAttractionCard` — Attraction cards
- `ReviewCard` — Review display with voting
- `CollectionCard` — Collection preview card
- `SmartImage` — Image with fallbacks and loading states
- `SkeletonLoader` — Loading skeletons for all content types
- `LocationHeader` — Current location display with selector
- `NotificationBadge` — Notification count badge
- `CustomAlert` — Styled alert dialog
- `Toast` — Toast notifications
- `BusinessImageGallery` — Swipeable image gallery
- `ProfileAvatar` — User avatar with initials fallback
- `AppLogo` — App branding component

## Theming & Design System

### Color Palette

**Light Mode:**
```
text: #11181C
background: #f4fafcff
tint/accent: #0a7ea4
card: #ffffff
border: #e5e5e5
headerGradientStart: #6366f1
headerGradientEnd: #8b5cf6
buttonPrimary: #6366f1
tabBackground: #ffffff
tabBorder: #e2e8f0
```

**Dark Mode:**
```
text: #ECEDEE
background: #151718
tint/accent: #3b82f6
card: #1f2937
border: #374151
headerGradientStart: #1f2937
headerGradientEnd: #374151
buttonPrimary: #3b82f6
tabBackground: #1e293b
tabBorder: #334155
```

### Design Principles
- Support **both light and dark themes** with system preference detection
- Use **gradient headers** (indigo→purple in light, gray tones in dark)
- Cards with subtle shadows and rounded corners (12-16px radius)
- Haptic feedback on tab interactions
- Smooth animations and transitions
- Skeleton loading states for all data-dependent UI
- Tab bar with active indicator dot below selected icon
- Pull-to-refresh on scrollable lists

## Data Models (Dart)

All data models should be created as immutable classes with `fromJson`/`toJson` factories. Key models to implement:

- `User` — id, name, email, phone, city, profile_image, trust_level, total_points, roles, user_level
- `Business` — id, business_name, slug, description, area, city, overall_rating, price_range, category, images, is_verified, distance_km, is_national
- `Category` — id, name, slug, icon_image, color_code, total_businesses, is_featured, subcategories
- `Offering` — id, name, description, offering_type, price, currency, image_url, is_popular, average_rating, business
- `Review` — id, overall_rating, service_rating, quality_rating, value_rating, title, review_text, pros, cons, images, user, helpful_count, status
- `Attraction` — id, name, slug, description, type, category, city, area, entry_fee, overall_rating, cover_image_url, facilities, estimated_duration_minutes, difficulty_level, gallery
- `AttractionReview` — id, rating, title, comment, visit_date, experience_tags, visit_info, helpful_votes, user
- `Banner` — id, title, subtitle, image_url, link_type, link_id
- `SpecialOffer` — id, title, description, offer_type, discount_percentage, valid_to, business
- `Notification` — id, title, body, icon, color, is_read, time_ago
- `UserCollection` — id, name, description, is_public, slug, businesses_count, followers_count, businesses
- `NationalBrand` — id, business_name, overall_rating, total_reviews, is_national, service_coverage, business_model
- `UserLevel` — level, level_name, level_description, total_score, progress_to_next_level

## Key Business Logic

### Location System
- Request GPS permission on first launch
- Validate location is within **Bangladesh boundaries** (lat: 20.67–26.63, lng: 88.03–92.67)
- Support manual location selection (Bangladesh districts/divisions)
- Default to Chittagong (22.3569, 91.7832) if location unavailable
- Pass latitude/longitude to most API calls for location-aware results

### User Level System (from backend)
- **New Explorer** (0-39 pts) → **Rising Contributor** (40-79) → **Active Explorer** (80-119) → **Seasoned Reviewer** (120-149) → **Expert Explorer** (150+)
- Points from reviews, favorites, verified visits
- Display progress bar and level badge on profile

### Review System
- Reviews require admin approval (pending → approved/rejected)
- Multi-category ratings: overall, service, quality, value (1-5 stars)
- Support pros/cons lists, visit date, amount spent, party size
- Image upload support (max 5 images, max 5MB each)
- Helpful/not helpful voting system

### Favorites System
- Polymorphic favorites (business or offering)
- `favoritable_type`: "business" | "offering"
- Toggle favorite via heart icon on cards

### Collections System
- User-created curated lists of businesses
- Public/private visibility
- Add businesses with personal notes
- Follow/unfollow other users' collections

### Search System
- Universal search across businesses, offerings, and attractions
- Real-time autocomplete suggestions (min 2 chars)
- Filters: category, rating, distance, verified, sort order
- Search history and popular searches

### Interaction Tracking
- Track views, clicks, searches for personalization
- Batch tracking support for efficiency
- Attraction interactions: like, dislike, bookmark, visit, share, wishlist

### Community Submissions
- Submit new businesses, attractions, offerings
- Points-based reward system for contributions
- Track submission status (pending/approved/rejected)

## File & Folder Structure (Recommended)

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   │   ├── api_config.dart          # API base URL, endpoints
│   │   ├── app_config.dart          # App constants
│   │   └── theme_config.dart        # Theme data
│   ├── constants/
│   │   ├── colors.dart              # Color palette
│   │   ├── strings.dart             # String constants
│   │   └── dimensions.dart          # Spacing, sizing
│   ├── errors/
│   │   └── exceptions.dart          # Custom exceptions
│   ├── network/
│   │   ├── dio_client.dart          # Dio setup with interceptors
│   │   └── api_response.dart        # Generic response wrapper
│   ├── router/
│   │   └── app_router.dart          # GoRouter configuration
│   ├── theme/
│   │   ├── app_theme.dart           # ThemeData (light/dark)
│   │   └── text_styles.dart         # Typography
│   └── utils/
│       ├── distance_utils.dart
│       ├── image_utils.dart
│       └── date_utils.dart
├── data/
│   ├── models/                      # Data models with fromJson/toJson
│   │   ├── user_model.dart
│   │   ├── business_model.dart
│   │   ├── category_model.dart
│   │   ├── offering_model.dart
│   │   ├── review_model.dart
│   │   ├── attraction_model.dart
│   │   ├── banner_model.dart
│   │   ├── notification_model.dart
│   │   ├── collection_model.dart
│   │   └── ...
│   ├── repositories/                # Repository implementations
│   │   ├── auth_repository.dart
│   │   ├── home_repository.dart
│   │   ├── business_repository.dart
│   │   ├── search_repository.dart
│   │   ├── review_repository.dart
│   │   ├── attraction_repository.dart
│   │   ├── collection_repository.dart
│   │   ├── notification_repository.dart
│   │   └── ...
│   └── services/
│       ├── api_service.dart          # Central API service
│       ├── auth_service.dart         # Token management
│       ├── location_service.dart     # GPS + manual location
│       ├── cache_service.dart        # Local caching
│       └── tracking_service.dart     # User interaction tracking
├── presentation/
│   ├── providers/                   # Riverpod providers
│   │   ├── auth_provider.dart
│   │   ├── home_provider.dart
│   │   ├── theme_provider.dart
│   │   ├── location_provider.dart
│   │   └── ...
│   ├── screens/
│   │   ├── home/
│   │   ├── discover/
│   │   ├── favourites/
│   │   ├── collections/
│   │   ├── profile/
│   │   ├── auth/
│   │   ├── business/
│   │   ├── attraction/
│   │   ├── offering/
│   │   ├── search/
│   │   ├── review/
│   │   ├── notification/
│   │   └── ...
│   └── widgets/
│       ├── common/
│       │   ├── smart_image.dart
│       │   ├── skeleton_loader.dart
│       │   ├── custom_alert.dart
│       │   ├── toast.dart
│       │   ├── location_header.dart
│       │   ├── app_logo.dart
│       │   └── ...
│       ├── cards/
│       │   ├── business_card.dart
│       │   ├── attraction_card.dart
│       │   ├── review_card.dart
│       │   ├── collection_card.dart
│       │   ├── offer_card.dart
│       │   └── ...
│       └── modals/
│           ├── edit_profile_modal.dart
│           ├── submit_business_modal.dart
│           ├── submit_attraction_modal.dart
│           └── ...
└── gen/                             # Auto-generated code (if any)
```

## Development Conventions

### Code Style
- Use `dart format` for formatting
- Follow effective Dart guidelines
- Use `const` constructors wherever possible
- Prefer immutable data classes with `copyWith`
- Use `freezed` or manual immutable classes for models
- Always handle loading, error, and empty states in UI

### API Integration
- All API calls go through a central Dio client with auth interceptor
- Handle 401 responses by redirecting to login
- Show user-friendly error messages from API error responses
- Implement retry logic for network failures
- Cache home screen data locally for offline-first experience

### State Management (Riverpod)
- Use `StateNotifierProvider` for complex state
- Use `FutureProvider` for one-shot API calls
- Use `StreamProvider` for real-time data
- Keep providers in dedicated files per feature

### Error Handling
- Wrap all API calls in try-catch
- Map HTTP errors to user-friendly messages
- Use a global error handler for uncaught exceptions
- Show toast/snackbar for non-critical errors
- Show dialog for critical errors

### Performance
- Use `ListView.builder` for long lists
- Implement pagination with infinite scroll
- Cache images with `cached_network_image`
- Debounce search input (300-500ms)
- Lazy load screen data
- Use skeleton loaders during data fetch
