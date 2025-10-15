#!/usr/bin/env node

/**
 * Complete Database Population Script
 * Populates all collections: sellers, categories, products (including jerseys), and sample data
 * Usage: node populate-all.js
 */

const mongoose = require('mongoose');
require('dotenv').config({ path: './backend/.env' });

const DB_URL = process.env.DB_URL || 'mongodb://127.0.0.1:27017/ec';

console.log('🚀 Starting complete database population...\n');

// ============================================
// SELLERS DATA
// ============================================
const sellers = [
  {
    _id: new mongoose.Types.ObjectId('68ed4c5b3d996fb76714d25e'),
    name: 'Collins Tech Store',
    email: 'collins@techstore.com',
    role: 'seller',
    status: 'active',
    payment: 'active',
    shopInfo: {
      shopName: 'Collins Tech Store',
      district: 'Nairobi',
      sub_district: 'Westlands'
    }
  },
  {
    _id: new mongoose.Types.ObjectId('68ed4daf849158b7f64b1c07'),
    name: 'Fashion Hub',
    email: 'fashion@hub.com',
    role: 'seller',
    status: 'active',
    payment: 'active',
    shopInfo: {
      shopName: 'Fashion Hub',
      district: 'Nairobi',
      sub_district: 'CBD'
    }
  },
  {
    _id: new mongoose.Types.ObjectId('68ef75aca320e540a28b6544'),
    name: 'Jersey Kingdom',
    email: 'info@jerseykingdom.com',
    role: 'seller',
    status: 'active',
    payment: 'active',
    shopInfo: {
      shopName: 'Jersey Kingdom',
      district: 'Mombasa',
      sub_district: 'Nyali'
    }
  },
  {
    _id: new mongoose.Types.ObjectId('68ef75aca320e540a28b6684'),
    name: 'Sports Arena',
    email: 'contact@sportsarena.com',
    role: 'seller',
    status: 'active',
    payment: 'active',
    shopInfo: {
      shopName: 'Sports Arena',
      district: 'Kisumu',
      sub_district: 'Milimani'
    }
  }
];

// ============================================
// CATEGORIES DATA
// ============================================
const categories = [
  { name: 'Electronics', image: 'electronics.jpg', slug: 'electronics' },
  { name: 'Clothing & Fashion', image: 'fashion.jpg', slug: 'clothing-fashion' },
  { name: 'Sports & Outdoors', image: 'sports.jpg', slug: 'sports-outdoors' },
  { name: 'Books & Media', image: 'books.jpg', slug: 'books-media' },
  { name: 'Health & Beauty', image: 'health.jpg', slug: 'health-beauty' },
  { name: 'Premier League', image: 'premier-league.jpg', slug: 'premier-league' },
  { name: 'La Liga', image: 'la-liga.jpg', slug: 'la-liga' },
  { name: 'Serie A', image: 'serie-a.jpg', slug: 'serie-a' },
  { name: 'Vintage Jerseys', image: 'vintage.jpg', slug: 'vintage-jerseys' },
  { name: 'Shoes', image: 'shoes.jpg', slug: 'shoes' }
];

// ============================================
// REGULAR PRODUCTS DATA
// ============================================
const regularProducts = [
  {
    sellerId: sellers[0]._id,
    name: 'iPhone 15 Pro Max',
    slug: 'iphone-15-pro-max',
    category: 'Electronics',
    brand: 'Apple',
    price: 1199,
    stock: 50,
    discount: 10,
    description: 'Latest iPhone with Pro camera system, A17 Pro chip, and titanium design.',
    shopName: sellers[0].shopInfo.shopName,
    images: ['https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=500'],
    rating: 4.8
  },
  {
    sellerId: sellers[0]._id,
    name: 'Samsung 65" 4K Smart TV',
    slug: 'samsung-65-4k-smart-tv',
    category: 'Electronics',
    brand: 'Samsung',
    price: 899,
    stock: 25,
    discount: 15,
    description: 'Ultra HD 4K Smart TV with HDR and streaming apps.',
    shopName: sellers[0].shopInfo.shopName,
    images: ['https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=500'],
    rating: 4.5
  },
  {
    sellerId: sellers[1]._id,
    name: 'MacBook Air M3',
    slug: 'macbook-air-m3',
    category: 'Electronics',
    brand: 'Apple',
    price: 1299,
    stock: 30,
    discount: 5,
    description: 'Supercharged by M3 chip. Up to 18 hours of battery life.',
    shopName: sellers[1].shopInfo.shopName,
    images: ['https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500'],
    rating: 4.9
  },
  {
    sellerId: sellers[1]._id,
    name: 'Premium Cotton T-Shirt',
    slug: 'premium-cotton-t-shirt',
    category: 'Clothing & Fashion',
    brand: 'StyleWear',
    price: 29.99,
    stock: 100,
    discount: 20,
    description: 'Comfortable premium cotton t-shirt in multiple colors.',
    shopName: sellers[1].shopInfo.shopName,
    images: ['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500'],
    rating: 4.3
  },
  {
    sellerId: sellers[1]._id,
    name: 'Denim Jeans - Slim Fit',
    slug: 'denim-jeans-slim-fit',
    category: 'Clothing & Fashion',
    brand: 'DenimCo',
    price: 79.99,
    stock: 75,
    discount: 25,
    description: 'High-quality denim jeans with slim fit design.',
    shopName: sellers[1].shopInfo.shopName,
    images: ['https://images.unsplash.com/photo-1542272604-787c3835535d?w=500'],
    rating: 4.6
  },
  {
    sellerId: sellers[1]._id,
    name: 'Professional Basketball',
    slug: 'professional-basketball',
    category: 'Sports & Outdoors',
    brand: 'SportsPro',
    price: 24.99,
    stock: 40,
    discount: 8,
    description: 'Official size basketball with excellent grip.',
    shopName: sellers[1].shopInfo.shopName,
    images: ['https://images.unsplash.com/photo-1546519638-68e109498ffc?w=500'],
    rating: 4.7
  },
  {
    sellerId: sellers[0]._id,
    name: 'JavaScript: The Complete Guide',
    slug: 'javascript-complete-guide',
    category: 'Books & Media',
    brand: 'TechBooks',
    price: 39.99,
    stock: 60,
    discount: 30,
    description: 'Comprehensive guide to modern JavaScript programming.',
    shopName: sellers[0].shopInfo.shopName,
    images: ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500'],
    rating: 4.9
  },
  {
    sellerId: sellers[1]._id,
    name: 'Organic Face Cream Set',
    slug: 'organic-face-cream-set',
    category: 'Health & Beauty',
    brand: 'NaturalCare',
    price: 49.99,
    stock: 35,
    discount: 18,
    description: 'Premium organic face cream set with natural ingredients.',
    shopName: sellers[1].shopInfo.shopName,
    images: ['https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500'],
    rating: 4.5
  },
  {
    sellerId: sellers[3]._id,
    name: 'Nike Air Max Sneakers',
    slug: 'nike-air-max-sneakers-4',
    category: 'Shoes',
    brand: 'Nike',
    price: 12000,
    stock: 30,
    discount: 20,
    description: 'Comfortable running shoes with Air Max cushioning',
    shopName: sellers[3].shopInfo.shopName,
    images: [
      'https://placehold.co/400x400/6366f1/ffffff?text=Nike+Air+Max+Sneaker',
      'https://placehold.co/400x400/4f46e5/ffffff?text=Nike+Air+Max+Sneaker+2'
    ],
    rating: 4.8
  }
];

// ============================================
// JERSEY IMAGES
// ============================================
const jerseyImages = {
  'Manchester City': {
    home: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=400&h=400&fit=crop'
  },
  'Arsenal': {
    home: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=400&h=400&fit=crop'
  },
  'Liverpool': {
    home: 'https://images.unsplash.com/photo-1614632537239-d3e5d9e6f4df?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1589487391730-58f20eb2c308?w=400&h=400&fit=crop'
  },
  'Manchester United': {
    home: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400&h=400&fit=crop'
  },
  'Real Madrid': {
    home: 'https://images.unsplash.com/photo-1522778526097-ce0a22ceb253?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&h=400&fit=crop'
  },
  'Barcelona': {
    home: 'https://images.unsplash.com/photo-1511886929837-354d827aae26?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=400&h=400&fit=crop'
  }
};

// ============================================
// FOOTBALL TEAMS DATA
// ============================================
const premierLeagueTeams = [
  { name: 'Manchester City', league: 'Premier League' },
  { name: 'Arsenal', league: 'Premier League' },
  { name: 'Liverpool', league: 'Premier League' },
  { name: 'Manchester United', league: 'Premier League' }
];

const laLigaTeams = [
  { name: 'Real Madrid', league: 'La Liga' },
  { name: 'Barcelona', league: 'La Liga' },
  { name: 'Atletico Madrid', league: 'La Liga' }
];

const sizes = ['S', 'M', 'L', 'XL', 'XXL'];

// Helper function
function getJerseyImages(teamName, type = 'home') {
  if (jerseyImages[teamName] && jerseyImages[teamName][type]) {
    return [
      jerseyImages[teamName][type],
      jerseyImages[teamName][type === 'home' ? 'away' : 'home']
    ];
  }
  return [
    'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&h=400&fit=crop'
  ];
}

// Generate jerseys
function generateJerseys() {
  const jerseys = [];
  let counter = 1;

  const allTeams = [...premierLeagueTeams, ...laLigaTeams];

  allTeams.forEach((team) => {
    sizes.forEach((size) => {
      // Home Jersey
      jerseys.push({
        name: `${team.name} 2023/24 Home Jersey - ${size}`,
        category: team.league,
        brand: team.name,
        price: Math.floor(Math.random() * 5000) + 4000,
        discount: Math.floor(Math.random() * 20),
        rating: (Math.random() * 1.5 + 3.5).toFixed(1),
        stock: Math.floor(Math.random() * 40) + 10,
        description: `Official ${team.name} home jersey for 2023/24 season. Premium quality, breathable fabric. Size: ${size}. ${team.name} colors.`,
        shopName: sellers[2].shopInfo.shopName,
        images: getJerseyImages(team.name, 'home'),
        slug: `${team.name.toLowerCase().replace(/ /g, '-')}-home-${size.toLowerCase()}-${counter}`,
        sellerId: sellers[2]._id,
        season: '2023/24',
        size: size,
        league: team.league
      });
      counter++;

      // Away Jersey
      jerseys.push({
        name: `${team.name} 2023/24 Away Jersey - ${size}`,
        category: team.league,
        brand: team.name,
        price: Math.floor(Math.random() * 5000) + 5000,
        discount: Math.floor(Math.random() * 15),
        rating: (Math.random() * 1.5 + 3.5).toFixed(1),
        stock: Math.floor(Math.random() * 35) + 10,
        description: `Official ${team.name} away jersey for 2023/24 season. Premium quality. Size: ${size}.`,
        shopName: sellers[2].shopInfo.shopName,
        images: getJerseyImages(team.name, 'away'),
        slug: `${team.name.toLowerCase().replace(/ /g, '-')}-away-${size.toLowerCase()}-${counter}`,
        sellerId: sellers[2]._id,
        season: '2023/24',
        size: size,
        league: team.league
      });
      counter++;
    });
  });

  return jerseys;
}

// ============================================
// MAIN POPULATION FUNCTION
// ============================================
async function populateDatabase() {
  try {
    console.log(`📡 Connecting to MongoDB: ${DB_URL}\n`);
    await mongoose.connect(DB_URL);
    console.log('✅ Connected to MongoDB\n');

    const db = mongoose.connection.db;

    // 1. Populate Sellers
    console.log('👥 Populating sellers...');
    const sellersCollection = db.collection('sellers');
    await sellersCollection.deleteMany({});
    await sellersCollection.insertMany(sellers);
    console.log(`✅ ${sellers.length} sellers added\n`);

    // 2. Populate Categories
    console.log('📂 Populating categories...');
    const categoriesCollection = db.collection('categorys');
    await categoriesCollection.deleteMany({});
    await categoriesCollection.insertMany(categories);
    console.log(`✅ ${categories.length} categories added\n`);

    // 3. Populate Regular Products
    console.log('📦 Populating regular products...');
    const productsCollection = db.collection('products');
    await productsCollection.deleteMany({});
    await productsCollection.insertMany(regularProducts);
    console.log(`✅ ${regularProducts.length} regular products added\n`);

    // 4. Generate and Populate Jerseys
    console.log('⚽ Generating and populating jerseys...');
    const jerseys = generateJerseys();
    await productsCollection.insertMany(jerseys);
    console.log(`✅ ${jerseys.length} jerseys added\n`);

    // 5. Summary
    const totalProducts = await productsCollection.countDocuments();
    const totalSellers = await sellersCollection.countDocuments();
    const totalCategories = await categoriesCollection.countDocuments();

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🎉 Database Population Complete!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📊 Total Sellers:    ${totalSellers}`);
    console.log(`📂 Total Categories: ${totalCategories}`);
    console.log(`📦 Total Products:   ${totalProducts}`);
    console.log(`   - Regular:        ${regularProducts.length}`);
    console.log(`   - Jerseys:        ${jerseys.length}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    await mongoose.disconnect();
    console.log('👋 Disconnected from MongoDB');
    console.log('✨ All done! Your database is ready.\n');

  } catch (error) {
    console.error('❌ Error populating database:', error);
    process.exit(1);
  }
}

// Run the script
populateDatabase();
