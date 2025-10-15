# Database Population Script

This script populates your ecommerce database with football jerseys and other products using Kenyan Shillings (KES).

## What's Included

### Football Jerseys (156 products)
- **Premier League** (96 jerseys)
  - Top 6 teams: Manchester City, Arsenal, Liverpool, Manchester United, Newcastle United, Tottenham
  - Home and Away jerseys for current season
  - All sizes: S, M, L, XL, XXL
  - Vintage sections (90s & 00s)
  
- **La Liga** (30 jerseys)
  - Top 6 teams: Real Madrid, Barcelona, Atletico Madrid, Real Sociedad, Villarreal, Real Betis
  - All sizes available
  
- **Serie A** (30 jerseys)
  - Top 6 teams: AC Milan, Inter Milan, Juventus, Napoli, AS Roma, Lazio
  - All sizes available

### Other Products (10 products)
- Electronics (Samsung TV, iPhone, PlayStation 5)
- Fashion (Levi's Jeans)
- Shoes (Nike Air Max)
- Sports Equipment (Adidas Shorts)
- Home & Living (Coffee Maker, Bed Sheets)
- Books (The Alchemist, Becoming)

### Categories (12)
- Football Jerseys
- Vintage Jerseys
- Premier League
- La Liga
- Serie A
- Electronics
- Fashion
- Shoes
- Sports Equipment
- Accessories
- Home & Living
- Books

### Sellers (8)
- Jersey Kingdom (Football Jerseys)
- Vintage Sports (Vintage Jerseys)
- Tech Hub Kenya (Electronics)
- Fashion Forward (Fashion)
- Sports Arena (Sports Equipment)
- Style Nairobi (Fashion & Accessories)
- Home Essentials (Home & Living)
- Book Haven (Books)

### Banners (4)
- Premier League Jerseys Sale
- Vintage Collection
- La Liga Official Jerseys
- Electronics Mega Sale

## Pricing

All products are priced in **Kenyan Shillings (KES)**:
- Football Jerseys: KES 4,000 - 7,500
- Vintage Jerseys: KES 6,000 - 11,000
- Electronics: KES 65,000 - 145,000
- Fashion & Shoes: KES 3,500 - 12,000
- Books: KES 1,200 - 1,800

## Usage

```bash
# Run the populate script
node populate.js
```

## Features

- ✅ Generates unique ObjectIds for each product
- ✅ Random discounts (0-20%)
- ✅ Random ratings (4.0-5.0)
- ✅ Random stock levels (10-100)
- ✅ Multiple product images
- ✅ SEO-friendly slugs
- ✅ Categorized by league, team, and season
- ✅ Size variations for all jerseys
- ✅ Vintage collections (90s & 00s)

## Data Structure

Each product includes:
- Name with team, season, and size
- Category (League/Type)
- Brand (Team name)
- Price in KES
- Discount percentage
- Rating (4.0-5.0)
- Stock quantity
- Detailed description
- Shop name (seller)
- Multiple images
- SEO-friendly slug
- Seller ID
- Season/Vintage info
- Size
- League

## Notes

- The script adds data without clearing existing records
- Duplicate entries are automatically skipped
- Uses the same MongoDB connection as your backend
- All prices are in Kenyan Shillings (KES)
- Vintage jerseys have limited sizes (S, M, L)
- Current season jerseys have all sizes (S, M, L, XL, XXL)

## Database Statistics After Population

```
Total Products: ~166
  - Premier League: 96 jerseys
  - La Liga: 30 jerseys
  - Serie A: 30 jerseys
  - Vintage: 36 jerseys
  - Other Products: 10 items
Total Categories: 12
Total Banners: 4
```

## Accessing the Data

After running the script, you can access your ecommerce platform:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5001
- **Dashboard**: http://localhost:3001

The products will be available immediately on the frontend with full search, filter, and cart functionality!
