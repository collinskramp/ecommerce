#!/usr/bin/env node

/**
 * Comprehensive Database Population Script for MERN Multi-Vendor Ecommerce
 * This script populates all collections with realistic sample data
 * Duplicates will be overwritten using upsert operations
 */

const { execSync } = require('child_process');

// MongoDB connection details
const MONGO_CMD = 'docker exec -it my-mongo mongosh ec --authenticationDatabase admin -u admin -p password --eval';

// Helper function to run MongoDB commands
function runMongoCommand(script) {
    try {
        console.log('Executing MongoDB command...');
        const result = execSync(`${MONGO_CMD} "${script}"`, { encoding: 'utf8' });
        console.log(result);
        return result;
    } catch (error) {
        console.error('Error executing command:', error.message);
        return null;
    }
}

// Sample data definitions
const sampleData = {
    // Admin users
    admins: [
        {
            name: 'Super Admin',
            email: 'admin@admin.com',
            password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', // 'secret'
            image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
            role: 'admin'
        },
        {
            name: 'Admin Manager',
            email: 'manager@admin.com',
            password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', // 'secret'
            image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            role: 'admin'
        }
    ],

    // Categories
    categories: [
        { name: 'Electronics', image: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400', slug: 'electronics' },
        { name: 'Clothing & Fashion', image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400', slug: 'clothing-fashion' },
        { name: 'Home & Garden', image: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400', slug: 'home-garden' },
        { name: 'Sports & Outdoors', image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400', slug: 'sports-outdoors' },
        { name: 'Books & Media', image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', slug: 'books-media' },
        { name: 'Health & Beauty', image: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400', slug: 'health-beauty' },
        { name: 'Automotive', image: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400', slug: 'automotive' },
        { name: 'Toys & Games', image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', slug: 'toys-games' }
    ],

    // Customers
    customers: [
        { name: 'John Smith', email: 'john@customer.com', password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually' },
        { name: 'Sarah Johnson', email: 'sarah@customer.com', password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually' },
        { name: 'Mike Wilson', email: 'mike@customer.com', password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually' },
        { name: 'Emily Davis', email: 'emily@customer.com', password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually' },
        { name: 'Alex Chen', email: 'alex@customer.com', password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually' },
        { name: 'Lisa Brown', email: 'lisa@customer.com', password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually' }
    ]
};

console.log('🚀 Starting Comprehensive Database Population...\n');

// 1. Clear existing data and populate admins
console.log('1️⃣ Populating Admin Users...');
runMongoCommand(`
    db.admins.deleteMany({});
    db.admins.insertMany([
        {
            name: 'Super Admin',
            email: 'admin@admin.com',
            password: '\\$2b\\$10\\$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
            image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
            role: 'admin',
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            name: 'Admin Manager',
            email: 'manager@admin.com',
            password: '\\$2b\\$10\\$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
            image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            role: 'admin',
            createdAt: new Date(),
            updatedAt: new Date()
        }
    ]);
`);

// 2. Populate categories
console.log('2️⃣ Populating Categories...');
runMongoCommand(`
    db.categorys.deleteMany({});
    db.categorys.insertMany([
        { name: 'Electronics', image: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400', slug: 'electronics', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Clothing & Fashion', image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400', slug: 'clothing-fashion', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Home & Garden', image: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400', slug: 'home-garden', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Sports & Outdoors', image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400', slug: 'sports-outdoors', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Books & Media', image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', slug: 'books-media', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Health & Beauty', image: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400', slug: 'health-beauty', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Automotive', image: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400', slug: 'automotive', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Toys & Games', image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', slug: 'toys-games', createdAt: new Date(), updatedAt: new Date() }
    ]);
`);

// 3. Populate customers
console.log('3️⃣ Populating Customers...');
runMongoCommand(`
    db.customers.deleteMany({});
    db.customers.insertMany([
        { name: 'John Smith', email: 'john@customer.com', password: '\\$2b\\$10\\$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Sarah Johnson', email: 'sarah@customer.com', password: '\\$2b\\$10\\$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Mike Wilson', email: 'mike@customer.com', password: '\\$2b\\$10\\$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Emily Davis', email: 'emily@customer.com', password: '\\$2b\\$10\\$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Alex Chen', email: 'alex@customer.com', password: '\\$2b\\$10\\$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually', createdAt: new Date(), updatedAt: new Date() },
        { name: 'Lisa Brown', email: 'lisa@customer.com', password: '\\$2b\\$10\\$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', method: 'manually', createdAt: new Date(), updatedAt: new Date() }
    ]);
`);

// 4. Ensure sellers are active
console.log('4️⃣ Updating Sellers Status...');
runMongoCommand(`
    db.sellers.updateMany({}, { \\$set: { status: 'active', payment: 'active' } });
`);

// 5. Populate products (Enhanced with more variety)
console.log('5️⃣ Populating Products...');
runMongoCommand(`
    var sellers = db.sellers.find({}).toArray();
    var seller1Id = sellers[0]._id;
    var seller2Id = sellers[1]._id;
    
    db.products.deleteMany({});
    db.products.insertMany([
        // Electronics
        {
            sellerId: seller1Id,
            name: 'iPhone 15 Pro Max',
            slug: 'iphone-15-pro-max',
            category: 'Electronics',
            brand: 'Apple',
            price: 1199,
            stock: 50,
            discount: 10,
            description: 'Latest iPhone with Pro camera system, A17 Pro chip, and titanium design. Features advanced photography capabilities and lightning-fast performance.',
            shopName: 'Collins Tech Store',
            images: ['https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=500', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500'],
            rating: 4.8,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            sellerId: seller1Id,
            name: 'Samsung 65" 4K Smart TV',
            slug: 'samsung-65-4k-smart-tv',
            category: 'Electronics',
            brand: 'Samsung',
            price: 899,
            stock: 25,
            discount: 15,
            description: 'Ultra HD 4K Smart TV with HDR, built-in streaming apps, and crystal clear display technology.',
            shopName: 'Collins Tech Store',
            images: ['https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=500', 'https://images.unsplash.com/photo-1567690187548-f07b1d7bf5a9?w=500'],
            rating: 4.5,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            sellerId: seller2Id,
            name: 'MacBook Air M3',
            slug: 'macbook-air-m3',
            category: 'Electronics',
            brand: 'Apple',
            price: 1299,
            stock: 30,
            discount: 5,
            description: 'Supercharged by M3 chip. Up to 18 hours of battery life. Incredibly portable and powerful.',
            shopName: 'Fashion Hub',
            images: ['https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500', 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500'],
            rating: 4.9,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            sellerId: seller1Id,
            name: 'Sony WH-1000XM5 Headphones',
            slug: 'sony-wh-1000xm5-headphones',
            category: 'Electronics',
            brand: 'Sony',
            price: 399,
            stock: 40,
            discount: 20,
            description: 'Industry-leading noise canceling with Auto NC Optimizer. Crystal clear hands-free calling.',
            shopName: 'Collins Tech Store',
            images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500', 'https://images.unsplash.com/photo-1545127398-14699f92334b?w=500'],
            rating: 4.7,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        
        // Clothing & Fashion
        {
            sellerId: seller2Id,
            name: 'Premium Cotton T-Shirt',
            slug: 'premium-cotton-t-shirt',
            category: 'Clothing & Fashion',
            brand: 'StyleWear',
            price: 29.99,
            stock: 100,
            discount: 20,
            description: 'Comfortable premium cotton t-shirt available in multiple colors. Perfect for casual wear with excellent fabric quality.',
            shopName: 'Fashion Hub',
            images: ['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500', 'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=500'],
            rating: 4.3,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            sellerId: seller2Id,
            name: 'Denim Jeans - Slim Fit',
            slug: 'denim-jeans-slim-fit',
            category: 'Clothing & Fashion',
            brand: 'DenimCo',
            price: 79.99,
            stock: 75,
            discount: 25,
            description: 'High-quality denim jeans with slim fit design. Durable construction with comfortable stretch fabric.',
            shopName: 'Fashion Hub',
            images: ['https://images.unsplash.com/photo-1542272604-787c3835535d?w=500', 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=500'],
            rating: 4.6,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            sellerId: seller1Id,
            name: 'Leather Jacket - Classic',
            slug: 'leather-jacket-classic',
            category: 'Clothing & Fashion',
            brand: 'LeatherCraft',
            price: 199.99,
            stock: 20,
            discount: 30,
            description: 'Genuine leather jacket with classic design. Perfect for both casual and formal occasions.',
            shopName: 'Collins Tech Store',
            images: ['https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500', 'https://images.unsplash.com/photo-1520975954732-35dd22299614?w=500'],
            rating: 4.8,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            sellerId: seller2Id,
            name: 'Running Shoes - Air Max',
            slug: 'running-shoes-air-max',
            category: 'Clothing & Fashion',
            brand: 'SportsFeet',
            price: 129.99,
            stock: 60,
            discount: 15,
            description: 'Comfortable running shoes with air cushioning technology. Perfect for daily workouts and running.',
            shopName: 'Fashion Hub',
            images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500', 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500'],
            rating: 4.4,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        
        // Home & Garden
        {
            sellerId: seller1Id,
            name: 'Modern Table Lamp',
            slug: 'modern-table-lamp',
            category: 'Home & Garden',
            brand: 'HomeDecor',
            price: 45.99,
            stock: 30,
            discount: 12,
            description: 'Elegant modern table lamp with adjustable brightness. Perfect for reading and ambient lighting.',
            shopName: 'Collins Tech Store',
            images: ['https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=500', 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500'],
            rating: 4.4,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            sellerId: seller2Id,
            name: 'Garden Tool Set',
            slug: 'garden-tool-set',
            category: 'Home & Garden',
            brand: 'GreenThumb',
            price: 89.99,
            stock: 25,
            discount: 18,
            description: 'Complete garden tool set with high-quality stainless steel tools. Perfect for all gardening needs.',
            shopName: 'Fashion Hub',
            images: ['https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=500', 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=500'],
            rating: 4.6,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        
        // Sports & Outdoors
        {
            sellerId: seller2Id,
            name: 'Professional Basketball',
            slug: 'professional-basketball',
            category: 'Sports & Outdoors',
            brand: 'SportsPro',
            price: 24.99,
            stock: 40,
            discount: 8,
            description: 'Official size and weight basketball with excellent grip and durability for indoor and outdoor play.',
            shopName: 'Fashion Hub',
            images: ['https://images.unsplash.com/photo-1546519638-68e109498ffc?w=500', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500'],
            rating: 4.7,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            sellerId: seller1Id,
            name: 'Yoga Mat Premium',
            slug: 'yoga-mat-premium',
            category: 'Sports & Outdoors',
            brand: 'FitnessGear',
            price: 39.99,
            stock: 50,
            discount: 22,
            description: 'Non-slip premium yoga mat with extra cushioning. Perfect for yoga, pilates, and exercise routines.',
            shopName: 'Collins Tech Store',
            images: ['https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500', 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=500'],
            rating: 4.5,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        
        // Books & Media
        {
            sellerId: seller1Id,
            name: 'JavaScript: The Complete Guide',
            slug: 'javascript-complete-guide',
            category: 'Books & Media',
            brand: 'TechBooks',
            price: 39.99,
            stock: 60,
            discount: 30,
            description: 'Comprehensive guide to modern JavaScript programming. Covers ES6+, async programming, and advanced concepts.',
            shopName: 'Collins Tech Store',
            images: ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500', 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500'],
            rating: 4.9,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            sellerId: seller2Id,
            name: 'The Art of War - Classic',
            slug: 'art-of-war-classic',
            category: 'Books & Media',
            brand: 'ClassicBooks',
            price: 19.99,
            stock: 45,
            discount: 25,
            description: 'Timeless classic on strategy and philosophy. Beautiful hardcover edition with original text.',
            shopName: 'Fashion Hub',
            images: ['https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500'],
            rating: 4.7,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        
        // Health & Beauty
        {
            sellerId: seller2Id,
            name: 'Organic Face Cream Set',
            slug: 'organic-face-cream-set',
            category: 'Health & Beauty',
            brand: 'NaturalCare',
            price: 49.99,
            stock: 35,
            discount: 18,
            description: 'Premium organic face cream set with day and night creams. Made with natural ingredients for all skin types.',
            shopName: 'Fashion Hub',
            images: ['https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500', 'https://images.unsplash.com/photo-1570554886111-e80fcca6a029?w=500'],
            rating: 4.5,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            sellerId: seller1Id,
            name: 'Vitamin C Serum',
            slug: 'vitamin-c-serum',
            category: 'Health & Beauty',
            brand: 'SkinCare Pro',
            price: 29.99,
            stock: 80,
            discount: 35,
            description: 'High-potency Vitamin C serum for brightening and anti-aging. Clinical strength formulation.',
            shopName: 'Collins Tech Store',
            images: ['https://images.unsplash.com/photo-1556228453-efd6c1ff04b6?w=500', 'https://images.unsplash.com/photo-1583743089695-4b816a340f82?w=500'],
            rating: 4.6,
            createdAt: new Date(),
            updatedAt: new Date()
        }
    ]);
`);

// 6. Create banners
console.log('6️⃣ Creating Homepage Banners...');
runMongoCommand(`
    var products = db.products.find({}).limit(5).toArray();
    
    db.banners.deleteMany({});
    db.banners.insertMany([
        {
            productId: products[0]._id,
            banner: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=1200&h=400&fit=crop',
            link: '/product/' + products[0].slug,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            productId: products[1]._id,
            banner: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=1200&h=400&fit=crop',
            link: '/product/' + products[1].slug,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            productId: products[2]._id,
            banner: 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=1200&h=400&fit=crop',
            link: '/product/' + products[2].slug,
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            productId: products[3]._id,
            banner: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=1200&h=400&fit=crop',
            link: '/product/' + products[3].slug,
            createdAt: new Date(),
            updatedAt: new Date()
        }
    ]);
`);

// 7. Add product reviews
console.log('7️⃣ Adding Product Reviews...');
runMongoCommand(`
    var products = db.products.find({}).toArray();
    var customers = db.customers.find({}).toArray();
    
    db.reviews.deleteMany({});
    
    var reviews = [];
    var reviewTexts = [
        'Amazing product! Exceeded my expectations in every way.',
        'Great quality and fast shipping. Highly recommend!',
        'Good value for money. Works as described.',
        'Excellent customer service and product quality.',
        'Perfect for my needs. Will buy again!',
        'Outstanding quality and design. Love it!',
        'Fast delivery and great packaging. Product works perfectly.',
        'Exactly what I was looking for. Very satisfied!',
        'High quality materials and construction.',
        'Great product at a reasonable price point.'
    ];
    
    products.forEach((product, index) => {
        // Add 2-4 reviews per product
        var numReviews = Math.floor(Math.random() * 3) + 2;
        for (var i = 0; i < numReviews && i < customers.length; i++) {
            reviews.push({
                productId: product._id,
                name: customers[i].name,
                rating: Math.floor(Math.random() * 2) + 4, // 4-5 stars
                review: reviewTexts[Math.floor(Math.random() * reviewTexts.length)],
                date: new Date().toISOString().split('T')[0],
                createdAt: new Date(),
                updatedAt: new Date()
            });
        }
    });
    
    db.reviews.insertMany(reviews);
`);

// 8. Create customer orders
console.log('8️⃣ Creating Customer Orders...');
runMongoCommand(`
    var customers = db.customers.find({}).toArray();
    var products = db.products.find({}).toArray();
    
    db.customerOrders.deleteMany({});
    
    var orders = [];
    var orderStatuses = ['pending', 'processing', 'shipped', 'delivered'];
    var paymentStatuses = ['pending', 'paid', 'cancelled'];
    
    customers.forEach((customer, index) => {
        // Create 1-3 orders per customer
        var numOrders = Math.floor(Math.random() * 3) + 1;
        for (var i = 0; i < numOrders; i++) {
            var orderProducts = [];
            var totalPrice = 0;
            var numProductsInOrder = Math.floor(Math.random() * 3) + 1;
            
            for (var j = 0; j < numProductsInOrder; j++) {
                var randomProduct = products[Math.floor(Math.random() * products.length)];
                var quantity = Math.floor(Math.random() * 3) + 1;
                var discountedPrice = randomProduct.price * (1 - randomProduct.discount / 100);
                
                orderProducts.push({
                    _id: randomProduct._id,
                    name: randomProduct.name,
                    image: randomProduct.images[0],
                    category: randomProduct.category,
                    brand: randomProduct.brand,
                    price: randomProduct.price,
                    discount: randomProduct.discount,
                    quantity: quantity,
                    shopName: randomProduct.shopName
                });
                
                totalPrice += discountedPrice * quantity;
            }
            
            orders.push({
                customerId: customer._id,
                products: orderProducts,
                price: Math.round(totalPrice * 100) / 100,
                payment_status: paymentStatuses[Math.floor(Math.random() * paymentStatuses.length)],
                shippingInfo: {
                    name: customer.name,
                    address: '123 Main St, City, State 12345',
                    phone: '+1-555-0123',
                    post: '12345',
                    province: 'State',
                    city: 'City',
                    area: 'Downtown'
                },
                delivery_status: orderStatuses[Math.floor(Math.random() * orderStatuses.length)],
                date: new Date().toISOString().split('T')[0],
                createdAt: new Date(),
                updatedAt: new Date()
            });
        }
    });
    
    db.customerOrders.insertMany(orders);
`);

// 9. Create seller orders (authOrders)
console.log('9️⃣ Creating Seller Orders...');
runMongoCommand(`
    var customerOrders = db.customerOrders.find({}).toArray();
    var sellers = db.sellers.find({}).toArray();
    
    db.authorOrders.deleteMany({});
    
    var sellerOrders = [];
    
    customerOrders.forEach(order => {
        // Group products by seller
        var sellerGroups = {};
        
        order.products.forEach(product => {
            var sellerId = sellers.find(s => s.name === product.shopName.replace(' Store', '').replace(' Hub', ''))._id.toString();
            if (!sellerGroups[sellerId]) {
                sellerGroups[sellerId] = [];
            }
            sellerGroups[sellerId].push(product);
        });
        
        // Create seller order for each seller in the customer order
        Object.keys(sellerGroups).forEach(sellerId => {
            var sellerProducts = sellerGroups[sellerId];
            var sellerTotal = sellerProducts.reduce((sum, product) => {
                return sum + (product.price * (1 - product.discount / 100) * product.quantity);
            }, 0);
            
            sellerOrders.push({
                orderId: order._id,
                sellerId: ObjectId(sellerId),
                products: sellerProducts,
                price: Math.round(sellerTotal * 100) / 100,
                payment_status: order.payment_status,
                shippingInfo: JSON.stringify(order.shippingInfo),
                delivery_status: order.delivery_status,
                date: order.date,
                createdAt: new Date(),
                updatedAt: new Date()
            });
        });
    });
    
    if (sellerOrders.length > 0) {
        db.authorOrders.insertMany(sellerOrders);
    }
`);

// 10. Create shopping carts
console.log('🛒 Creating Shopping Carts...');
runMongoCommand(`
    var customers = db.customers.find({}).toArray();
    var products = db.products.find({}).toArray();
    
    db.cardProducts.deleteMany({});
    
    var cartItems = [];
    
    // Add some items to customers' carts
    customers.forEach((customer, index) => {
        if (index % 2 === 0) { // Every other customer has items in cart
            var numItems = Math.floor(Math.random() * 4) + 1;
            for (var i = 0; i < numItems; i++) {
                var randomProduct = products[Math.floor(Math.random() * products.length)];
                cartItems.push({
                    userId: customer._id,
                    productId: randomProduct._id,
                    quantity: Math.floor(Math.random() * 3) + 1,
                    createdAt: new Date(),
                    updatedAt: new Date()
                });
            }
        }
    });
    
    if (cartItems.length > 0) {
        db.cardProducts.insertMany(cartItems);
    }
`);

// 11. Create wishlists
console.log('❤️ Creating Wishlists...');
runMongoCommand(`
    var customers = db.customers.find({}).toArray();
    var products = db.products.find({}).toArray();
    
    db.wishlists.deleteMany({});
    
    var wishlistItems = [];
    
    customers.forEach((customer, index) => {
        if (index % 3 === 0) { // Every third customer has wishlist items
            var numItems = Math.floor(Math.random() * 5) + 1;
            for (var i = 0; i < numItems; i++) {
                var randomProduct = products[Math.floor(Math.random() * products.length)];
                wishlistItems.push({
                    userId: customer._id.toString(),
                    productId: randomProduct._id.toString(),
                    name: randomProduct.name,
                    price: randomProduct.price,
                    slug: randomProduct.slug,
                    discount: randomProduct.discount,
                    image: randomProduct.images[0],
                    rating: randomProduct.rating,
                    createdAt: new Date(),
                    updatedAt: new Date()
                });
            }
        }
    });
    
    if (wishlistItems.length > 0) {
        db.wishlists.insertMany(wishlistItems);
    }
`);

// 12. Create seller wallets
console.log('💰 Creating Seller Wallets...');
runMongoCommand(`
    var sellers = db.sellers.find({}).toArray();
    var currentYear = new Date().getFullYear();
    var currentMonth = new Date().getMonth() + 1;
    
    db.sellerWallets.deleteMany({});
    
    var walletEntries = [];
    
    sellers.forEach(seller => {
        // Create wallet entries for last 6 months
        for (var i = 0; i < 6; i++) {
            var month = currentMonth - i;
            var year = currentYear;
            
            if (month <= 0) {
                month += 12;
                year -= 1;
            }
            
            walletEntries.push({
                sellerId: seller._id.toString(),
                amount: Math.floor(Math.random() * 5000) + 1000, // $1000-$6000
                month: month,
                year: year,
                createdAt: new Date(),
                updatedAt: new Date()
            });
        }
    });
    
    db.sellerWallets.insertMany(walletEntries);
`);

// 13. Create withdrawal requests
console.log('💸 Creating Withdrawal Requests...');
runMongoCommand(`
    var sellers = db.sellers.find({}).toArray();
    
    db.withdrowRequest.deleteMany({});
    
    var withdrawals = [];
    var statuses = ['pending', 'success', 'cancelled'];
    
    sellers.forEach(seller => {
        // Create 1-3 withdrawal requests per seller
        var numRequests = Math.floor(Math.random() * 3) + 1;
        for (var i = 0; i < numRequests; i++) {
            withdrawals.push({
                sellerId: seller._id.toString(),
                amount: Math.floor(Math.random() * 2000) + 100, // $100-$2100
                status: statuses[Math.floor(Math.random() * statuses.length)],
                createdAt: new Date(),
                updatedAt: new Date()
            });
        }
    });
    
    db.withdrowRequest.insertMany(withdrawals);
`);

// 14. Final database summary
console.log('📊 Final Database Summary...');
runMongoCommand(`
    console.log('\\n=== FINAL DATABASE SUMMARY ===');
    console.log('👤 Admins:', db.admins.countDocuments());
    console.log('🏪 Sellers:', db.sellers.countDocuments());
    console.log('👥 Customers:', db.customers.countDocuments());
    console.log('📁 Categories:', db.categorys.countDocuments());
    console.log('🛍️ Products:', db.products.countDocuments());
    console.log('🎨 Banners:', db.banners.countDocuments());
    console.log('⭐ Reviews:', db.reviews.countDocuments());
    console.log('📦 Customer Orders:', db.customerOrders.countDocuments());
    console.log('🏷️ Seller Orders:', db.authorOrders.countDocuments());
    console.log('🛒 Cart Items:', db.cardProducts.countDocuments());
    console.log('❤️ Wishlist Items:', db.wishlists.countDocuments());
    console.log('💰 Wallet Entries:', db.sellerWallets.countDocuments());
    console.log('💸 Withdrawal Requests:', db.withdrowRequest.countDocuments());
    console.log('\\n✅ Database population completed successfully!');
`);

console.log('\n🎉 Database Population Complete!');
console.log('\n🌐 You can now test your applications with comprehensive sample data:');
console.log('   • Frontend: http://localhost:3000');
console.log('   • Dashboard: http://localhost:3001');
console.log('   • Admin Panel: http://localhost:3001/admin/login');
console.log('\n🔑 Login Credentials:');
console.log('   • Admin: admin@admin.com / secret');
console.log('   • Customers: john@customer.com / secret (and others)');
console.log('   • Sellers: Use your registered credentials');
