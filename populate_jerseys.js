const mongoose = require('mongoose');

const uri = 'mongodb://admin:password@127.0.0.1:27017/ec?authSource=admin';

// Real football jersey images from various sources
const jerseyImages = {
  // Premier League Teams
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
  'Newcastle United': {
    home: 'https://images.unsplash.com/photo-1606925797300-0b35e9d1794e?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&h=400&fit=crop'
  },
  'Tottenham': {
    home: 'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?w=400&h=400&fit=crop'
  },
  // La Liga Teams
  'Real Madrid': {
    home: 'https://images.unsplash.com/photo-1522778526097-ce0a22ceb253?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&h=400&fit=crop'
  },
  'Barcelona': {
    home: 'https://images.unsplash.com/photo-1511886929837-354d827aae26?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=400&h=400&fit=crop'
  },
  'Atletico Madrid': {
    home: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1614632537290-e8c99e8ba3c0?w=400&h=400&fit=crop'
  },
  'Real Sociedad': {
    home: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?w=400&h=400&fit=crop'
  },
  'Villarreal': {
    home: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400&h=400&fit=crop'
  },
  'Real Betis': {
    home: 'https://images.unsplash.com/photo-1614632537239-d3e5d9e6f4df?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1589487391730-58f20eb2c308?w=400&h=400&fit=crop'
  },
  // Serie A Teams
  'AC Milan': {
    home: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=400&h=400&fit=crop'
  },
  'Inter Milan': {
    home: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1606925797300-0b35e9d1794e?w=400&h=400&fit=crop'
  },
  'Juventus': {
    home: 'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&h=400&fit=crop'
  },
  'Napoli': {
    home: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?w=400&h=400&fit=crop'
  },
  'AS Roma': {
    home: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1614632537290-e8c99e8ba3c0?w=400&h=400&fit=crop'
  },
  'Lazio': {
    home: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=400&h=400&fit=crop'
  },
  // Vintage
  'Vintage': {
    home: 'https://images.unsplash.com/photo-1511886929837-354d827aae26?w=400&h=400&fit=crop',
    away: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&h=400&fit=crop'
  }
};

// Football Teams Data
const premierLeagueTeams = [
  { name: 'Manchester City', color: 'Sky Blue', logo: '🔵' },
  { name: 'Arsenal', color: 'Red & White', logo: '🔴' },
  { name: 'Liverpool', color: 'Red', logo: '🔴' },
  { name: 'Manchester United', color: 'Red', logo: '🔴' },
  { name: 'Newcastle United', color: 'Black & White', logo: '⚫' },
  { name: 'Tottenham', color: 'White', logo: '⚪' }
];

const laLigaTeams = [
  { name: 'Real Madrid', color: 'White', logo: '⚪' },
  { name: 'Barcelona', color: 'Blue & Red', logo: '🔵' },
  { name: 'Atletico Madrid', color: 'Red & White', logo: '🔴' },
  { name: 'Real Sociedad', color: 'Blue & White', logo: '🔵' },
  { name: 'Villarreal', color: 'Yellow', logo: '🟡' },
  { name: 'Real Betis', color: 'Green & White', logo: '🟢' }
];

const serieATeams = [
  { name: 'AC Milan', color: 'Red & Black', logo: '🔴' },
  { name: 'Inter Milan', color: 'Blue & Black', logo: '🔵' },
  { name: 'Juventus', color: 'Black & White', logo: '⚫' },
  { name: 'Napoli', color: 'Blue', logo: '🔵' },
  { name: 'AS Roma', color: 'Red & Yellow', logo: '🔴' },
  { name: 'Lazio', color: 'Sky Blue', logo: '🔵' }
];

const sizes = ['S', 'M', 'L', 'XL', 'XXL'];

// Helper function to get jersey images
const getJerseyImages = (teamName, type = 'home') => {
  if (jerseyImages[teamName] && jerseyImages[teamName][type]) {
    return [
      jerseyImages[teamName][type],
      jerseyImages[teamName][type === 'home' ? 'away' : 'home']
    ];
  }
  // Fallback to generic sports images
  return [
    'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&h=400&fit=crop'
  ];
};

// Sellers
const sellers = [
  { _id: new mongoose.Types.ObjectId(), name: 'SportsMania Kenya' },
  { _id: new mongoose.Types.ObjectId(), name: 'Elite Football Gear' }
];

async function updateProductImages() {
  try {
    await mongoose.connect(uri);
    console.log('Connected to MongoDB');

    const db = mongoose.connection.db;
    const productsCollection = db.collection('products');

    // Update Premier League products
    for (const team of premierLeagueTeams) {
      const homeImages = getJerseyImages(team.name, 'home');
      const awayImages = getJerseyImages(team.name, 'away');
      const vintageImages = getJerseyImages('Vintage', 'home');

      // Update Home jerseys
      await productsCollection.updateMany(
        { 
          name: { $regex: new RegExp(`${team.name}.*Home`, 'i') },
          category: 'Premier League'
        },
        { $set: { images: homeImages } }
      );

      // Update Away jerseys
      await productsCollection.updateMany(
        { 
          name: { $regex: new RegExp(`${team.name}.*Away`, 'i') },
          category: 'Premier League'
        },
        { $set: { images: awayImages } }
      );

      // Update Vintage jerseys
      await productsCollection.updateMany(
        { 
          name: { $regex: new RegExp(`${team.name}.*Vintage`, 'i') }
        },
        { $set: { images: vintageImages } }
      );

      console.log(`✓ Updated ${team.name} jerseys`);
    }

    // Update La Liga products
    for (const team of laLigaTeams) {
      const homeImages = getJerseyImages(team.name, 'home');
      const awayImages = getJerseyImages(team.name, 'away');

      await productsCollection.updateMany(
        { 
          name: { $regex: new RegExp(`${team.name}.*Home`, 'i') },
          category: 'La Liga'
        },
        { $set: { images: homeImages } }
      );

      await productsCollection.updateMany(
        { 
          name: { $regex: new RegExp(`${team.name}.*Away`, 'i') },
          category: 'La Liga'
        },
        { $set: { images: awayImages } }
      );

      console.log(`✓ Updated ${team.name} jerseys`);
    }

    // Update Serie A products
    for (const team of serieATeams) {
      const homeImages = getJerseyImages(team.name, 'home');
      const awayImages = getJerseyImages(team.name, 'away');

      await productsCollection.updateMany(
        { 
          name: { $regex: new RegExp(`${team.name}.*Home`, 'i') },
          category: 'Serie A'
        },
        { $set: { images: homeImages } }
      );

      await productsCollection.updateMany(
        { 
          name: { $regex: new RegExp(`${team.name}.*Away`, 'i') },
          category: 'Serie A'
        },
        { $set: { images: awayImages } }
      );

      console.log(`✓ Updated ${team.name} jerseys`);
    }

    // Count updated products
    const totalProducts = await productsCollection.countDocuments({ 
      name: { $regex: /jersey|Jersey/i }
    });

    console.log('\n✅ Image update complete!');
    console.log(`📊 Total jersey products: ${totalProducts}`);
    
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');

  } catch (error) {
    console.error('Error updating images:', error);
    process.exit(1);
  }
}

// Run the update
updateProductImages();
