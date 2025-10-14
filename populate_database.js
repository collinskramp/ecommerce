#!/usr/bin/env node

/**
 * Comprehensive Demo Data Population Script for MERN Multi-Vendor Ecommerce
 * Fixes Redux store initialization issues and provides complete sample data
 * 
 * This script ensures:
 * - All required collections are created with proper structure
 * - Frontend Redux store gets properly initialized data
 * - No undefined properties in API responses
 */

const { MongoClient } = require('mongodb');
const bcrypt = require('bcrypt');
const { ObjectId } = require('mongodb');

// Configuration
const MONGO_URI = 'mongodb://admin:password@localhost:27017/ec?authSource=admin';
const DB_NAME = 'ec';

// Helper function to create hashed password
async function hashPassword(password) {
    return await bcrypt.hash(password, 10);
}

// Demo data with proper structure
const demoData = {
    // Admin collection
    admins: [
        {
            _id: new ObjectId(),
            name: 'Super Admin',
            email: 'admin@admin.com',
            password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', // 'secret'
            image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
            role: 'admin',
            createdAt: new Date(),
            updatedAt: new Date()
        }
    ],

    // Categories collection (note: using 'categories' not 'categorys')
    categories: [
        {
            _id: new ObjectId(),
            name: 'Electronics',
            image: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
            slug: 'electronics',
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            _id: new ObjectId(),
            name: 'Clothing & Fashion',
            image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
            slug: 'clothing-fashion',
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            _id: new ObjectId(),
            name: 'Home & Garden',
            image: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
            slug: 'home-garden',
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            _id: new ObjectId(),
            name: 'Sports & Fitness',
            image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
            slug: 'sports-fitness',
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            _id: new ObjectId(),
            name: 'Books & Media',
            image: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
            slug: 'books-media',
            createdAt: new Date(),
            updatedAt: new Date()
        }
    ],

    // Banners collection
    banners: [
        {
            _id: new ObjectId(),
            productId: null, // Will be set after products are created
            banner: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=300&fit=crop',
            link: '/products',
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            _id: new ObjectId(),
            productId: null,
            banner: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=300&fit=crop',
            link: '/categories/electronics',
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            _id: new ObjectId(),
            productId: null,
            banner: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=300&fit=crop',
            link: '/categories/clothing-fashion',
            createdAt: new Date(),
            updatedAt: new Date()
        }
    ],

    // Sellers collection
    sellers: [
        {
            _id: new ObjectId(),
            name: 'TechStore Electronics',
            email: 'seller1@techstore.com',
            password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', // 'secret'
            role: 'seller',
            status: 'active',
            payment: 'active',
            method: 'manually',
            image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            shopInfo: {
                shopName: 'TechStore Electronics',
                division: 'California',
                district: 'Los Angeles',
                subDistrict: 'Downtown'
            },
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            _id: new ObjectId(),
            name: 'Fashion Hub',
            email: 'seller2@fashionhub.com',
            password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', // 'secret'
            role: 'seller',
            status: 'active',
            payment: 'active',
            method: 'manually',
            image: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
            shopInfo: {
                shopName: 'Fashion Hub',
                division: 'New York',
                district: 'Manhattan',
                subDistrict: 'SoHo'
            },
            createdAt: new Date(),
            updatedAt: new Date()
        }
    ],

    // Customers collection
    customers: [
        {
            _id: new ObjectId(),
            name: 'John Doe',
            email: 'customer@example.com',
            password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', // 'secret'
            method: 'manually',
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            _id: new ObjectId(),
            name: 'Jane Smith',
            email: 'jane@example.com',
            password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', // 'secret'
            method: 'manually',
            createdAt: new Date(),
            updatedAt: new Date()
        }
    ],

    // Products collection (will be populated after sellers are created)
    products: []
};

// Generate products based on categories and sellers
function generateProducts(categories, sellers) {
    const products = [];
    
    const productTemplates = [
        // Electronics
        {
            name: 'Wireless Bluetooth Headphones',
            category: 'Electronics',
            brand: 'TechBrand',
            price: 99,
            discount: 10,
            description: 'High-quality wireless headphones with noise cancellation',
            images: [
                'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
                'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=400'
            ],
            stock: 50
        },
        {
            name: 'Smart Watch Pro',
            category: 'Electronics',
            brand: 'SmartTech',
            price: 299,
            discount: 15,
            description: 'Advanced smartwatch with health monitoring features',
            images: [
                'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
                'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400'
            ],
            stock: 30
        },
        {
            name: 'Laptop Gaming Beast',
            category: 'Electronics',
            brand: 'GameTech',
            price: 1299,
            discount: 5,
            description: 'High-performance gaming laptop with RTX graphics',
            images: [
                'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=400',
                'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400'
            ],
            stock: 15
        },
        // Clothing
        {
            name: 'Premium Cotton T-Shirt',
            category: 'Clothing & Fashion',
            brand: 'FashionCo',
            price: 29,
            discount: 20,
            description: 'Comfortable 100% cotton t-shirt available in multiple colors',
            images: [
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
                'https://images.unsplash.com/photo-1583743814966-8936f37f7831?w=400'
            ],
            stock: 100
        },
        {
            name: 'Designer Jeans',
            category: 'Clothing & Fashion',
            brand: 'DenimStyle',
            price: 89,
            discount: 25,
            description: 'Premium designer jeans with perfect fit',
            images: [
                'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
                'https://images.unsplash.com/photo-1506629905607-d8e2e0c77e28?w=400'
            ],
            stock: 60
        },
        // Home & Garden
        {
            name: 'Modern Table Lamp',
            category: 'Home & Garden',
            brand: 'HomeDecor',
            price: 59,
            discount: 15,
            description: 'Elegant modern table lamp for living room decoration',
            images: [
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
                'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'
            ],
            stock: 25
        }
    ];

    productTemplates.forEach((template, index) => {
        const category = categories.find(c => c.name === template.category);
        const seller = sellers[index % sellers.length]; // Distribute products among sellers
        
        if (category && seller) {
            products.push({
                _id: new ObjectId(),
                sellerId: seller._id,
                name: template.name,
                slug: template.name.toLowerCase().replace(/\s+/g, '-'),
                category: category.name,
                brand: template.brand,
                price: template.price,
                discount: template.discount,
                description: template.description,
                shopName: seller.shopInfo.shopName,
                images: template.images,
                stock: template.stock,
                rating: Math.floor(Math.random() * 2) + 4, // 4-5 star rating
                reviewCount: Math.floor(Math.random() * 50) + 10,
                createdAt: new Date(),
                updatedAt: new Date()
            });
        }
    });

    return products;
}

// Main population function
async function populateDatabase() {
    let client;
    
    try {
        console.log('🔌 Connecting to MongoDB...');
        client = new MongoClient(MONGO_URI);
        await client.connect();
        console.log('✅ Connected to MongoDB');

        const db = client.db(DB_NAME);

        // Generate products
        demoData.products = generateProducts(demoData.categories, demoData.sellers);

        // Collections to populate
        const collections = [
            { name: 'admins', data: demoData.admins },
            { name: 'categories', data: demoData.categories },
            { name: 'banners', data: demoData.banners },
            { name: 'sellers', data: demoData.sellers },
            { name: 'customers', data: demoData.customers },
            { name: 'products', data: demoData.products }
        ];

        // Populate each collection
        for (const collection of collections) {
            console.log(`📝 Populating ${collection.name}...`);
            
            // Clear existing data
            await db.collection(collection.name).deleteMany({});
            
            // Insert new data
            if (collection.data.length > 0) {
                await db.collection(collection.name).insertMany(collection.data);
                console.log(`✅ Inserted ${collection.data.length} documents into ${collection.name}`);
            } else {
                console.log(`⚠️  No data to insert for ${collection.name}`);
            }
        }

        // Create additional demo data for proper Redux store initialization
        await createAdditionalDemoData(db);

        console.log('🎉 Database population completed successfully!');
        console.log('');
        console.log('📊 Demo Data Summary:');
        console.log(`   - ${demoData.categories.length} Categories`);
        console.log(`   - ${demoData.products.length} Products`);
        console.log(`   - ${demoData.banners.length} Banners`);
        console.log(`   - ${demoData.sellers.length} Sellers`);
        console.log(`   - ${demoData.customers.length} Customers`);
        console.log(`   - ${demoData.admins.length} Admins`);
        console.log('');
        console.log('🔑 Demo Login Credentials:');
        console.log('   Admin: admin@admin.com / secret');
        console.log('   Seller: seller1@techstore.com / secret');
        console.log('   Customer: customer@example.com / secret');

    } catch (error) {
        console.error('❌ Error populating database:', error);
        process.exit(1);
    } finally {
        if (client) {
            await client.close();
            console.log('🔌 MongoDB connection closed');
        }
    }
}

// Create additional demo data for Redux store
async function createAdditionalDemoData(db) {
    console.log('📊 Creating additional demo data...');

    // Create reviews for products
    const products = await db.collection('products').find({}).toArray();
    const customers = await db.collection('customers').find({}).toArray();

    const reviews = [];
    products.forEach(product => {
        const numReviews = Math.floor(Math.random() * 3) + 1; // 1-3 reviews per product
        for (let i = 0; i < numReviews; i++) {
            const customer = customers[Math.floor(Math.random() * customers.length)];
            reviews.push({
                _id: new ObjectId(),
                productId: product._id,
                customerId: customer._id,
                name: customer.name,
                rating: Math.floor(Math.random() * 2) + 4, // 4-5 stars
                review: [
                    'Great product, highly recommended!',
                    'Excellent quality and fast shipping.',
                    'Perfect item, exactly as described.',
                    'Good value for money.',
                    'Will definitely buy again!'
                ][Math.floor(Math.random() * 5)],
                date: new Date(),
                createdAt: new Date(),
                updatedAt: new Date()
            });
        }
    });

    if (reviews.length > 0) {
        await db.collection('reviews').deleteMany({});
        await db.collection('reviews').insertMany(reviews);
        console.log(`✅ Created ${reviews.length} product reviews`);
    }

    // Create wishlists
    const wishlists = [];
    customers.forEach(customer => {
        const wishlistProducts = products.slice(0, Math.floor(Math.random() * 3) + 1); // 1-3 products
        wishlistProducts.forEach(product => {
            wishlists.push({
                _id: new ObjectId(),
                userId: customer._id,
                productId: product._id,
                createdAt: new Date(),
                updatedAt: new Date()
            });
        });
    });

    if (wishlists.length > 0) {
        await db.collection('wishlists').deleteMany({});
        await db.collection('wishlists').insertMany(wishlists);
        console.log(`✅ Created ${wishlists.length} wishlist items`);
    }
}

// Run the population script
if (require.main === module) {
    populateDatabase();
}

module.exports = { populateDatabase };
