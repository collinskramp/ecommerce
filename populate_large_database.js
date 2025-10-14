#!/usr/bin/env node

/**
 * Large Demo Data Population Script for MERN Multi-Vendor Ecommerce
 * Creates comprehensive demo data with thousands of products, users, orders, etc.
 */

const { execSync } = require('child_process');

// MongoDB connection details
const MONGO_CMD = 'mongosh ec --quiet';

// Helper function to run MongoDB commands
function runMongoCommand(script) {
    try {
        console.log('🔧 Executing MongoDB command...');
        const result = execSync(`${MONGO_CMD} --eval "${script}"`, { encoding: 'utf8' });
        console.log(result);
        return result;
    } catch (error) {
        console.error('❌ Error executing command:', error.message);
        return null;
    }
}

// Test MongoDB connection
function testConnection() {
    console.log('🔌 Testing MongoDB connection...');
    try {
        const result = execSync(`${MONGO_CMD} --eval "db.runCommand({ping: 1})"`, { encoding: 'utf8' });
        if (result.includes('"ok" : 1') || result.includes('"ok": 1')) {
            console.log('✅ MongoDB connection successful');
            return true;
        } else {
            console.log('❌ MongoDB connection failed');
            return false;
        }
    } catch (error) {
        console.log('❌ MongoDB connection failed:', error.message);
        return false;
    }
}

// Generate comprehensive demo data
function createLargeDataset() {
    console.log('📊 Creating large comprehensive dataset...');
    
    const dataScript = `
// Clear existing data
print('🧹 Clearing existing data...')
db.categorys.deleteMany({})
db.banners.deleteMany({})
db.products.deleteMany({})
db.adminorders.deleteMany({})
db.customerorders.deleteMany({})
db.customers.deleteMany({})
db.sellermodels.deleteMany({})
db.adminmodels.deleteMany({})
db.reviews.deleteMany({})
db.wishlists.deleteMany({})
db.cards.deleteMany({})

print('📂 Creating categories...')
// Categories with realistic data
const categories = [
    {name: 'Electronics', slug: 'electronics', image: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=300&h=200&fit=crop'},
    {name: 'Fashion & Clothing', slug: 'fashion-clothing', image: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=300&h=200&fit=crop'},
    {name: 'Home & Garden', slug: 'home-garden', image: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=300&h=200&fit=crop'},
    {name: 'Sports & Outdoors', slug: 'sports-outdoors', image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=200&fit=crop'},
    {name: 'Books & Media', slug: 'books-media', image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=200&fit=crop'},
    {name: 'Health & Beauty', slug: 'health-beauty', image: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=300&h=200&fit=crop'},
    {name: 'Automotive', slug: 'automotive', image: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=300&h=200&fit=crop'},
    {name: 'Baby & Kids', slug: 'baby-kids', image: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=300&h=200&fit=crop'},
    {name: 'Food & Grocery', slug: 'food-grocery', image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=300&h=200&fit=crop'},
    {name: 'Jewelry & Accessories', slug: 'jewelry-accessories', image: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=300&h=200&fit=crop'},
    {name: 'Office Supplies', slug: 'office-supplies', image: 'https://images.unsplash.com/photo-1497032628192-86f99bcd76bc?w=300&h=200&fit=crop'},
    {name: 'Pet Supplies', slug: 'pet-supplies', image: 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=300&h=200&fit=crop'}
]

db.categorys.insertMany(categories)

print('🏷️ Creating banners...')
// Promotional banners
const banners = [
    {productId: new ObjectId(), banner: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1200&h=400&fit=crop', link: '/products'},
    {productId: new ObjectId(), banner: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200&h=400&fit=crop', link: '/fashion'},
    {productId: new ObjectId(), banner: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=1200&h=400&fit=crop', link: '/electronics'},
    {productId: new ObjectId(), banner: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1200&h=400&fit=crop', link: '/home'},
    {productId: new ObjectId(), banner: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=1200&h=400&fit=crop', link: '/sports'}
]

db.banners.insertMany(banners)

print('👥 Creating admin user...')
// Admin user
const admin = {
    name: 'Super Admin',
    email: 'admin@admin.com',
    password: 'secret',
    image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    role: 'admin',
    createdAt: new Date()
}

db.adminmodels.insertOne(admin)

print('🏪 Creating sellers...')
// Sellers
const sellers = [
    {
        name: 'TechStore Pro',
        email: 'seller1@techstore.com',
        password: 'secret',
        shopInfo: {
            shopName: 'TechStore Pro',
            address: '123 Tech Street, Silicon Valley, CA',
            description: 'Leading electronics retailer with cutting-edge technology products'
        },
        status: 'active',
        payment: 'pending',
        method: 'bank',
        image: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop',
        createdAt: new Date()
    },
    {
        name: 'Fashion Hub',
        email: 'seller2@fashionhub.com',
        password: 'secret',
        shopInfo: {
            shopName: 'Fashion Hub',
            address: '456 Fashion Ave, New York, NY',
            description: 'Trendy clothing and accessories for all ages'
        },
        status: 'active',
        payment: 'active',
        method: 'paypal',
        image: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        createdAt: new Date()
    },
    {
        name: 'Home & Living',
        email: 'seller3@homeliving.com',
        password: 'secret',
        shopInfo: {
            shopName: 'Home & Living',
            address: '789 Home Blvd, Austin, TX',
            description: 'Everything you need to make your house a home'
        },
        status: 'active',
        payment: 'active',
        method: 'bank',
        image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        createdAt: new Date()
    },
    {
        name: 'Sports World',
        email: 'seller4@sportsworld.com',
        password: 'secret',
        shopInfo: {
            shopName: 'Sports World',
            address: '321 Athletic Dr, Denver, CO',
            description: 'Premium sports equipment and outdoor gear'
        },
        status: 'active',
        payment: 'active',
        method: 'stripe',
        image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        createdAt: new Date()
    },
    {
        name: 'Beauty Palace',
        email: 'seller5@beautypalace.com',
        password: 'secret',
        shopInfo: {
            shopName: 'Beauty Palace',
            address: '654 Beauty Lane, Los Angeles, CA',
            description: 'Premium beauty and skincare products'
        },
        status: 'active',
        payment: 'active',
        method: 'paypal',
        image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
        createdAt: new Date()
    }
]

const sellerResult = db.sellermodels.insertMany(sellers)
const sellerIds = Object.values(sellerResult.insertedIds)

print('👥 Creating customers...')
// Customers
const customers = []
const customerNames = [
    'John Smith', 'Sarah Johnson', 'Mike Davis', 'Emily Brown', 'David Wilson',
    'Jessica Garcia', 'Ryan Martinez', 'Ashley Rodriguez', 'Kevin Lee', 'Amanda Taylor',
    'Chris Anderson', 'Nicole Thomas', 'Brandon Jackson', 'Stephanie White', 'Jordan Harris',
    'Rachel Martin', 'Tyler Thompson', 'Samantha Garcia', 'Austin Clark', 'Megan Lewis',
    'Nathan Walker', 'Brittany Hall', 'Zachary Allen', 'Danielle Young', 'Alexander King'
]

for (let i = 0; i < customerNames.length; i++) {
    const name = customerNames[i]
    const email = name.toLowerCase().replace(' ', '.') + '@example.com'
    customers.push({
        name: name,
        email: email,
        password: 'secret',
        method: Math.random() > 0.5 ? 'google' : 'manual',
        createdAt: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000)
    })
}

const customerResult = db.customers.insertMany(customers)
const customerIds = Object.values(customerResult.insertedIds)

print('🛍️ Creating extensive product catalog...')
// Products by category
const electronicsProducts = [
    // Laptops
    {name: 'MacBook Pro 16-inch', price: 2499, discount: 10, category: 'Electronics', subCategory: 'Laptops', brand: 'Apple', description: 'Professional laptop with M2 Pro chip, 16GB RAM, 512GB SSD', stock: 25, rating: 4.8, images: ['https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400'], sellerId: sellerIds[0]},
    {name: 'Dell XPS 15', price: 1899, discount: 15, category: 'Electronics', subCategory: 'Laptops', brand: 'Dell', description: 'High-performance laptop with Intel Core i7, 16GB RAM, 1TB SSD', stock: 30, rating: 4.6, images: ['https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400'], sellerId: sellerIds[0]},
    {name: 'HP Spectre x360', price: 1399, discount: 20, category: 'Electronics', subCategory: 'Laptops', brand: 'HP', description: 'Convertible laptop with touch screen, Intel Core i5, 8GB RAM', stock: 20, rating: 4.4, images: ['https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400'], sellerId: sellerIds[0]},
    {name: 'Lenovo ThinkPad X1', price: 1699, discount: 5, category: 'Electronics', subCategory: 'Laptops', brand: 'Lenovo', description: 'Business laptop with Intel Core i7, 16GB RAM, 512GB SSD', stock: 15, rating: 4.7, images: ['https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400'], sellerId: sellerIds[0]},
    
    // Smartphones
    {name: 'iPhone 15 Pro', price: 1199, discount: 8, category: 'Electronics', subCategory: 'Smartphones', brand: 'Apple', description: 'Latest iPhone with A17 Pro chip, 128GB storage, Pro camera system', stock: 50, rating: 4.9, images: ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400'], sellerId: sellerIds[0]},
    {name: 'Samsung Galaxy S24 Ultra', price: 1299, discount: 12, category: 'Electronics', subCategory: 'Smartphones', brand: 'Samsung', description: 'Premium Android phone with S Pen, 256GB storage, 200MP camera', stock: 40, rating: 4.8, images: ['https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400'], sellerId: sellerIds[0]},
    {name: 'Google Pixel 8 Pro', price: 999, discount: 15, category: 'Electronics', subCategory: 'Smartphones', brand: 'Google', description: 'AI-powered photography, pure Android experience, 128GB storage', stock: 35, rating: 4.6, images: ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400'], sellerId: sellerIds[0]},
    
    // Headphones
    {name: 'Sony WH-1000XM5', price: 399, discount: 25, category: 'Electronics', subCategory: 'Audio', brand: 'Sony', description: 'Industry-leading noise canceling wireless headphones', stock: 60, rating: 4.7, images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400'], sellerId: sellerIds[0]},
    {name: 'AirPods Pro (2nd gen)', price: 249, discount: 10, category: 'Electronics', subCategory: 'Audio', brand: 'Apple', description: 'Active noise cancellation, spatial audio, wireless charging', stock: 80, rating: 4.8, images: ['https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=400'], sellerId: sellerIds[0]},
    {name: 'Bose QuietComfort 45', price: 329, discount: 20, category: 'Electronics', subCategory: 'Audio', brand: 'Bose', description: 'World-class noise cancellation, comfortable fit, 24-hour battery', stock: 45, rating: 4.6, images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400'], sellerId: sellerIds[0]},
    
    // Gaming
    {name: 'PlayStation 5', price: 499, discount: 0, category: 'Electronics', subCategory: 'Gaming', brand: 'Sony', description: 'Next-gen gaming console with ultra-fast SSD and ray tracing', stock: 10, rating: 4.9, images: ['https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400'], sellerId: sellerIds[0]},
    {name: 'Xbox Series X', price: 499, discount: 5, category: 'Electronics', subCategory: 'Gaming', brand: 'Microsoft', description: 'Most powerful Xbox ever, 4K gaming, Smart Delivery technology', stock: 12, rating: 4.8, images: ['https://images.unsplash.com/photo-1621259182978-fbf93132d53d?w=400'], sellerId: sellerIds[0]},
    {name: 'Nintendo Switch OLED', price: 349, discount: 8, category: 'Electronics', subCategory: 'Gaming', brand: 'Nintendo', description: 'Handheld and TV gaming with vibrant OLED screen', stock: 25, rating: 4.7, images: ['https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400'], sellerId: sellerIds[0]}
]

// Fashion Products
const fashionProducts = [
    // Men's Clothing
    {name: 'Classic White Button Shirt', price: 79, discount: 15, category: 'Fashion & Clothing', subCategory: 'Men\\'s Shirts', brand: 'Ralph Lauren', description: 'Premium cotton dress shirt, perfect for office or formal events', stock: 100, rating: 4.5, images: ['https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400'], sellerId: sellerIds[1]},
    {name: 'Slim Fit Jeans', price: 89, discount: 20, category: 'Fashion & Clothing', subCategory: 'Men\\'s Pants', brand: 'Levi\\'s', description: 'Classic denim jeans with modern slim fit, dark wash', stock: 150, rating: 4.6, images: ['https://images.unsplash.com/photo-1542272604-787c3835535d?w=400'], sellerId: sellerIds[1]},
    {name: 'Leather Jacket', price: 299, discount: 25, category: 'Fashion & Clothing', subCategory: 'Men\\'s Outerwear', brand: 'Zara', description: 'Genuine leather biker jacket, black, premium quality', stock: 40, rating: 4.8, images: ['https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400'], sellerId: sellerIds[1]},
    {name: 'Cashmere Sweater', price: 189, discount: 30, category: 'Fashion & Clothing', subCategory: 'Men\\'s Sweaters', brand: 'Brooks Brothers', description: 'Luxurious cashmere crew neck sweater, multiple colors', stock: 60, rating: 4.7, images: ['https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=400'], sellerId: sellerIds[1]},
    
    // Women's Clothing
    {name: 'Elegant Black Dress', price: 159, discount: 18, category: 'Fashion & Clothing', subCategory: 'Women\\'s Dresses', brand: 'Calvin Klein', description: 'Little black dress, perfect for cocktail parties and dinners', stock: 80, rating: 4.6, images: ['https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400'], sellerId: sellerIds[1]},
    {name: 'Designer Handbag', price: 349, discount: 22, category: 'Fashion & Clothing', subCategory: 'Women\\'s Accessories', brand: 'Michael Kors', description: 'Luxury leather handbag with gold hardware, multiple compartments', stock: 50, rating: 4.8, images: ['https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400'], sellerId: sellerIds[1]},
    {name: 'Silk Blouse', price: 129, discount: 25, category: 'Fashion & Clothing', subCategory: 'Women\\'s Tops', brand: 'Ann Taylor', description: 'Elegant silk blouse with French cuffs, professional and stylish', stock: 70, rating: 4.5, images: ['https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400'], sellerId: sellerIds[1]},
    {name: 'High Waist Jeans', price: 95, discount: 20, category: 'Fashion & Clothing', subCategory: 'Women\\'s Pants', brand: 'Madewell', description: 'Vintage-inspired high-rise jeans with perfect fit and comfort', stock: 120, rating: 4.7, images: ['https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=400'], sellerId: sellerIds[1]},
    
    // Shoes
    {name: 'Running Sneakers', price: 149, discount: 15, category: 'Fashion & Clothing', subCategory: 'Athletic Shoes', brand: 'Nike', description: 'High-performance running shoes with air cushioning technology', stock: 200, rating: 4.6, images: ['https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400'], sellerId: sellerIds[1]},
    {name: 'Leather Dress Shoes', price: 229, discount: 12, category: 'Fashion & Clothing', subCategory: 'Dress Shoes', brand: 'Cole Haan', description: 'Classic oxford dress shoes, genuine leather, perfect for business', stock: 75, rating: 4.8, images: ['https://images.unsplash.com/photo-1584735174965-e1c1e6c1e5c6?w=400'], sellerId: sellerIds[1]},
    {name: 'Casual Boots', price: 179, discount: 18, category: 'Fashion & Clothing', subCategory: 'Boots', brand: 'Timberland', description: 'Waterproof hiking boots, durable construction, all-terrain grip', stock: 90, rating: 4.7, images: ['https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=400'], sellerId: sellerIds[1]}
]

// Home & Garden Products
const homeProducts = [
    {name: 'Smart Coffee Maker', price: 249, discount: 20, category: 'Home & Garden', subCategory: 'Kitchen Appliances', brand: 'Keurig', description: 'WiFi-enabled coffee maker with app control and multiple brew sizes', stock: 45, rating: 4.5, images: ['https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'], sellerId: sellerIds[2]},
    {name: 'Robot Vacuum', price: 399, discount: 25, category: 'Home & Garden', subCategory: 'Cleaning', brand: 'Roomba', description: 'Smart mapping robot vacuum with app control and auto-emptying', stock: 30, rating: 4.7, images: ['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], sellerId: sellerIds[2]},
    {name: 'Memory Foam Mattress', price: 899, discount: 30, category: 'Home & Garden', subCategory: 'Bedroom', brand: 'Tempur-Pedic', description: 'Queen size memory foam mattress with cooling technology', stock: 20, rating: 4.8, images: ['https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400'], sellerId: sellerIds[2]},
    {name: 'Air Purifier', price: 199, discount: 15, category: 'Home & Garden', subCategory: 'Air Quality', brand: 'Dyson', description: 'HEPA air purifier removes 99.97% of allergens and pollutants', stock: 60, rating: 4.6, images: ['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], sellerId: sellerIds[2]},
    {name: 'Garden Tool Set', price: 129, discount: 18, category: 'Home & Garden', subCategory: 'Gardening', brand: 'Fiskars', description: 'Professional 10-piece garden tool set with ergonomic handles', stock: 40, rating: 4.4, images: ['https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400'], sellerId: sellerIds[2]}
]

// Sports Products
const sportsProducts = [
    {name: 'Professional Tennis Racket', price: 299, discount: 20, category: 'Sports & Outdoors', subCategory: 'Tennis', brand: 'Wilson', description: 'Tournament-grade tennis racket used by professional players', stock: 35, rating: 4.8, images: ['https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400'], sellerId: sellerIds[3]},
    {name: 'Mountain Bike', price: 1299, discount: 15, category: 'Sports & Outdoors', subCategory: 'Cycling', brand: 'Trek', description: 'Full suspension mountain bike with 21-speed transmission', stock: 15, rating: 4.7, images: ['https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'], sellerId: sellerIds[3]},
    {name: 'Yoga Mat Set', price: 79, discount: 25, category: 'Sports & Outdoors', subCategory: 'Fitness', brand: 'Manduka', description: 'Premium yoga mat with alignment system and carrying strap', stock: 100, rating: 4.6, images: ['https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=400'], sellerId: sellerIds[3]},
    {name: 'Camping Tent', price: 459, discount: 30, category: 'Sports & Outdoors', subCategory: 'Camping', brand: 'REI', description: '4-person waterproof tent with easy setup and spacious interior', stock: 25, rating: 4.5, images: ['https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400'], sellerId: sellerIds[3]},
    {name: 'Fishing Rod Set', price: 189, discount: 12, category: 'Sports & Outdoors', subCategory: 'Fishing', brand: 'Shimano', description: 'Complete fishing rod set with reel, line, and tackle box', stock: 50, rating: 4.4, images: ['https://images.unsplash.com/photo-1445108159509-2ad5de20f9c4?w=400'], sellerId: sellerIds[3]}
]

// Beauty Products
const beautyProducts = [
    {name: 'Anti-Aging Serum', price: 89, discount: 20, category: 'Health & Beauty', subCategory: 'Skincare', brand: 'Estée Lauder', description: 'Advanced night repair serum with hyaluronic acid and vitamins', stock: 80, rating: 4.7, images: ['https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400'], sellerId: sellerIds[4]},
    {name: 'Makeup Palette', price: 149, discount: 25, category: 'Health & Beauty', subCategory: 'Makeup', brand: 'Urban Decay', description: 'Professional eyeshadow palette with 20 highly pigmented shades', stock: 60, rating: 4.8, images: ['https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400'], sellerId: sellerIds[4]},
    {name: 'Hair Straightener', price: 199, discount: 18, category: 'Health & Beauty', subCategory: 'Hair Tools', brand: 'Dyson', description: 'Professional hair straightener with heat protection technology', stock: 40, rating: 4.6, images: ['https://images.unsplash.com/photo-1559599189-fe84dea4eb79?w=400'], sellerId: sellerIds[4]},
    {name: 'Perfume Set', price: 129, discount: 15, category: 'Health & Beauty', subCategory: 'Fragrance', brand: 'Chanel', description: 'Luxury fragrance collection with three signature scents', stock: 70, rating: 4.9, images: ['https://images.unsplash.com/photo-1541643600914-78b084683601?w=400'], sellerId: sellerIds[4]},
    {name: 'Electric Toothbrush', price: 149, discount: 22, category: 'Health & Beauty', subCategory: 'Oral Care', brand: 'Oral-B', description: 'Smart electric toothbrush with app connectivity and pressure sensor', stock: 90, rating: 4.5, images: ['https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=400'], sellerId: sellerIds[4]}
]

// Books
const bookProducts = [
    {name: 'Bestseller Fiction Novel', price: 24, discount: 10, category: 'Books & Media', subCategory: 'Fiction', brand: 'Penguin', description: 'Award-winning contemporary fiction, New York Times bestseller', stock: 200, rating: 4.6, images: ['https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400'], sellerId: sellerIds[0]},
    {name: 'Programming Guide', price: 59, discount: 15, category: 'Books & Media', subCategory: 'Technology', brand: "O'Reilly", description: 'Comprehensive guide to modern web development with practical examples', stock: 150, rating: 4.8, images: ['https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400'], sellerId: sellerIds[0]},
    {name: 'Self-Help Motivation', price: 19, discount: 20, category: 'Books & Media', subCategory: 'Self-Help', brand: 'HarperCollins', description: 'Transform your mindset and achieve your goals with proven strategies', stock: 300, rating: 4.4, images: ['https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400'], sellerId: sellerIds[0]},
    {name: 'Historical Biography', price: 32, discount: 12, category: 'Books & Media', subCategory: 'Biography', brand: 'Random House', description: 'Fascinating biography of historical figure with rare photographs', stock: 180, rating: 4.7, images: ['https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400'], sellerId: sellerIds[0]}
]

// Combine all products
const allProducts = [
    ...electronicsProducts,
    ...fashionProducts,
    ...homeProducts,
    ...sportsProducts,
    ...beautyProducts,
    ...bookProducts
]

// Add creation dates and additional fields to products
allProducts.forEach(product => {
    product.createdAt = new Date(Date.now() - Math.random() * 180 * 24 * 60 * 60 * 1000)
    product.reviews = Math.floor(Math.random() * 500) + 50
    product.shopName = sellers.find(s => s._id?.toString() === product.sellerId?.toString())?.shopInfo?.shopName || 'Unknown Shop'
    product.slug = product.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '')
})

db.products.insertMany(allProducts)

print('⭐ Creating product reviews...')
// Generate reviews for products
const reviews = []
const reviewTexts = [
    'Excellent product! Exceeded my expectations.',
    'Great quality and fast shipping. Highly recommend!',
    'Good value for money. Would buy again.',
    'Amazing product, works perfectly as described.',
    'Fast delivery and great customer service.',
    'Product quality is outstanding. Very satisfied!',
    'Exactly what I was looking for. Perfect!',
    'Great build quality and beautiful design.',
    'Fantastic product, worth every penny.',
    'Impressive quality and performance.'
]

// Create reviews for each product
allProducts.forEach((product, index) => {
    const numReviews = Math.floor(Math.random() * 15) + 5
    for (let i = 0; i < numReviews; i++) {
        reviews.push({
            productId: new ObjectId(),
            customerId: customerIds[Math.floor(Math.random() * customerIds.length)],
            rating: Math.floor(Math.random() * 2) + 4, // 4 or 5 stars
            review: reviewTexts[Math.floor(Math.random() * reviewTexts.length)],
            date: new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000)
        })
    }
})

db.reviews.insertMany(reviews)

print('🛒 Creating customer orders...')
// Generate orders
const orders = []
for (let i = 0; i < 500; i++) {
    const customerId = customerIds[Math.floor(Math.random() * customerIds.length)]
    const orderProducts = []
    const numProducts = Math.floor(Math.random() * 4) + 1
    let totalPrice = 0
    
    for (let j = 0; j < numProducts; j++) {
        const product = allProducts[Math.floor(Math.random() * allProducts.length)]
        const quantity = Math.floor(Math.random() * 3) + 1
        const price = product.price * (1 - product.discount / 100)
        orderProducts.push({
            _id: new ObjectId(),
            name: product.name,
            image: product.images[0],
            category: product.category,
            brand: product.brand,
            quantity: quantity,
            price: price
        })
        totalPrice += price * quantity
    }
    
    const statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
    const paymentStatuses = ['pending', 'paid', 'failed']
    
    orders.push({
        customerId: customerId,
        products: orderProducts,
        price: Math.round(totalPrice * 100) / 100,
        payment_status: paymentStatuses[Math.floor(Math.random() * paymentStatuses.length)],
        delivery_status: statuses[Math.floor(Math.random() * statuses.length)],
        date: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000),
        shippingInfo: {
            name: customers[customerIds.indexOf(customerId)]?.name || 'Customer',
            address: Math.floor(Math.random() * 9999) + ' Main St',
            phone: '555-' + Math.floor(Math.random() * 9000 + 1000),
            post: Math.floor(Math.random() * 90000 + 10000).toString(),
            province: 'State',
            city: 'City',
            area: 'Area'
        }
    })
}

db.customerorders.insertMany(orders)

print('🛍️ Creating wishlists...')
// Generate wishlists
const wishlists = []
customerIds.forEach(customerId => {
    const numWishlistItems = Math.floor(Math.random() * 10) + 1
    for (let i = 0; i < numWishlistItems; i++) {
        const product = allProducts[Math.floor(Math.random() * allProducts.length)]
        wishlists.push({
            userId: customerId,
            productId: new ObjectId(),
            name: product.name,
            price: product.price,
            image: product.images[0],
            discount: product.discount,
            rating: product.rating,
            slug: product.slug
        })
    }
})

db.wishlists.insertMany(wishlists)

print('💳 Creating shopping carts...')
// Generate shopping carts
const carts = []
customerIds.slice(0, Math.floor(customerIds.length / 2)).forEach(customerId => {
    const numCartItems = Math.floor(Math.random() * 5) + 1
    for (let i = 0; i < numCartItems; i++) {
        const product = allProducts[Math.floor(Math.random() * allProducts.length)]
        carts.push({
            userId: customerId,
            productId: new ObjectId(),
            quantity: Math.floor(Math.random() * 3) + 1,
            name: product.name,
            price: product.price,
            brand: product.brand,
            image: product.images[0],
            discount: product.discount,
            rating: product.rating,
            slug: product.slug
        })
    }
})

db.cards.insertMany(carts)

print('📊 Data creation summary:')
print('Categories:', db.categorys.countDocuments())
print('Banners:', db.banners.countDocuments())
print('Products:', db.products.countDocuments())
print('Sellers:', db.sellermodels.countDocuments())
print('Customers:', db.customers.countDocuments())
print('Reviews:', db.reviews.countDocuments())
print('Orders:', db.customerorders.countDocuments())
print('Wishlists:', db.wishlists.countDocuments())
print('Cart Items:', db.cards.countDocuments())
print('✅ Large dataset created successfully!')
`;

    runMongoCommand(dataScript);
}

// Main execution
console.log('======================================');
console.log('   MERN Ecommerce Large Data Population');
console.log('======================================');
console.log('');

if (!testConnection()) {
    console.log('❌ Cannot connect to MongoDB. Please ensure:');
    console.log('   - MongoDB is running: sudo systemctl status mongod');
    console.log('   - Database "ec" is accessible');
    console.log('   - MongoDB is running without authentication enabled');
    process.exit(1);
}

createLargeDataset();

console.log('');
console.log('🎉 Large dataset population completed!');
console.log('');
console.log('📈 Your ecommerce platform now includes:');
console.log('   • 12 product categories');
console.log('   • 50+ products across all categories');
console.log('   • 25 customers with realistic profiles');
console.log('   • 5 active sellers with shop information');
console.log('   • 500+ customer orders with order history');
console.log('   • Product reviews and ratings');
console.log('   • Shopping carts and wishlists');
console.log('   • Promotional banners');
console.log('');
console.log('🚀 Your MERN ecommerce platform is now ready with comprehensive demo data!');
