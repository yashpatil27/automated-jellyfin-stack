# Metadata Configuration

## How It Works

Your Jellyfin media stack uses an intelligent metadata fallback system:

### With TMDB API Key:
- **Primary**: TMDB (The Movie Database) - High quality metadata and artwork
- **Fallback**: OMDB (Open Movie Database) - If TMDB fails or is unavailable

### Without TMDB API Key:
- **Primary**: OMDB (Open Movie Database) - Free, no registration required
- **Fallback**: Built-in Jellyfin scrapers

## What You Get:

### TMDB (Recommended):
- ✅ High-resolution posters and artwork
- ✅ Comprehensive cast and crew information
- ✅ Detailed plot summaries
- ✅ Release dates, ratings, genres
- ✅ Multiple language support

### OMDB (Automatic Fallback):
- ✅ Basic metadata (title, year, plot)
- ✅ IMDb ratings
- ✅ Runtime and genre information
- ⚠️ Lower quality artwork
- ⚠️ Less detailed information

## Adding TMDB Later:

If you skipped the TMDB API key during setup, you can add it later:

1. Get a free API key at: https://www.themoviedb.org/settings/api
2. In Jellyseerr (http://localhost:5055):
   - Go to Settings → Services
   - Add your TMDB API key
   - The system will automatically prefer TMDB over OMDB

## No Configuration Required:

The system automatically:
- Uses OMDB when no TMDB key is provided
- Switches to TMDB when a key is added
- Falls back to OMDB if TMDB is unavailable
- Uses built-in scrapers as final fallback

Your media will have metadata either way! 🎬
