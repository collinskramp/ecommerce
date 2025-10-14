const { MongoClient } = require('mongodb');

const uri = 'mongodb://127.0.0.1:27017/ec';

const products = [
  {
    name: "iPhone 14 Pro Max",
    category: "Electronics",
    brand: "Apple",
    price: 1199,
    discount: 10,
    rating: 4.8,
    stock: 25,
    description: "The latest iPhone with Pro camera system, A16 Bionic chip, and Dynamic Island.",
    shopName: "Tech World",
    images: [
      "https://via.placeholder.com/300x300/1f2937/ffffff?text=iPhone+14+Pro",
      "https://via.placeholder.com/300x300/374151/ffffff?text=iPhone+Back"
    ],
    slug: "iphone-14-pro-max"
  },
  {
    name: "Samsung Galaxy S23 Ultra",
    category: "Electronics", 
    brand: "Samsung",
    price: 1099,
    discount: 15,
    rating: 4.7,
    stock: 30,
    description: "Flagship Android phone with S Pen, 200MP camera, and 5000mAh battery.",
    shopName: "Mobile Hub",
    images: [
      "https://via.placeholder.com/300x300/059669/ffffff?text=Galaxy+S23",
      "https://via.placeholder.com/300x300/047857/ffffff?text=Galaxy+Back"
    ],
    slug: "samsung-galaxy-s23-ultra"
  },
  {
    name: "MacBook Air M2",
    category: "Electronics",
    brand: "Apple", 
    price: 1199,
    discount: 8,
    rating: 4.9,
    stock: 15,
    description: "Redesigned MacBook Air with M2 chip, 13.6-inch Liquid Retina display.",
    shopName: "Computer Store",
    images: [
      "https://via.placeholder.com/300x300/6366f1/ffffff?text=MacBook+Air",
      "https://via.placeholder.com/300x300/4f46e5/ffffff?text=MacBook+Side"
    ],
    slug: "macbook-air-m2"
  },
  {
    name: "Nike Air Max 270",
    category: "Fashion",
    brand: "Nike",
    price: 150,
    discount: 20,
    rating: 4.5,
    stock: 50,
    description: "Lifestyle shoe with large Air unit and breathable mesh upper.",
    shopName: "Sneaker Zone", 
    images: [
      "https://via.placeholder.com/300x300/dc2626/ffffff?text=Nike+Air+Max",
      "https://via.placeholder.com/300x300/b91c1c/ffffff?text=Nike+Side"
    ],
    slug: "nike-air-max-270"
  },
  {
    name: "Sony WH-1000XM5",
    category: "Electronics",
    brand: "Sony",
    price: 399,
    discount: 12,
    rating: 4.6,
    stock: 20,
    description: "Industry-leading noise canceling headphones with 30-hour battery life.",
    shopName: "Audio Pro",
    images: [
      "https://via.placeholder.com/300x300/0ea5e9/ffffff?text=Sony+Headphones",
      "https://via.placeholder.com/300x300/0284c7/ffffff?text=Sony+Side"
    ],
    slug: "sony-wh-1000xm5"
  }
];

async function populateProducts() {
  let client;
  
  try {
    client = new MongoClient(uri);
    await client.connect();
    console.log('Connected to MongoDB');
    
    const db = client.db('ec');
    const productsCollection = db.collection('products');
    
    // Clear existing products
    await productsCollection.deleteMany({});
    console.log('Cleared existing products');
    
    // Insert new products
    const result = await productsCollection.insertMany(products);
    console.log(`${result.insertedCount} products inserted`);
    
    // Verify products were inserted
    const count = await productsCollection.countDocuments();
    console.log(`Total products in database: ${count}`);
    
  } catch (error) {
    console.error('Error populating products:', error);
  } finally {
    if (client) {
      await client.close();
      console.log('Database connection closed');
    }
  }
}

populateProducts();
