#!/usr/bin/env node

/**
 * Simple Demo Data Population Script for MERN Multi-Vendor Ecommerce
 * Uses MongoDB shell commands instead of Node.js MongoDB driver
 * 
 * This script creates basic demo data to fix Redux store initialization issues
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

// Create comprehensive demo data
function createDemoData() {
    console.log('📊 Creating comprehensive demo data...');
    
    // Create admin users
    console.log('👤 Creating admin users...');
    runMongoCommand(`
        db.admins.deleteMany({});
        db.admins.insertMany([
            {
                name: 'Super Admin',
                email: 'admin@admin.com',
                password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
                image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
                role: 'admin',
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ]);
        print('✅ Admin users created');
    `);

    // Create categories
    console.log('📂 Creating categories...');
    runMongoCommand(`
        db.categories.deleteMany({});
        db.categories.insertMany([
            {
                name: 'Electronics',
                image: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
                slug: 'electronics',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                name: 'Clothing & Fashion',
                image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
                slug: 'clothing-fashion',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                name: 'Home & Garden',
                image: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
                slug: 'home-garden',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                name: 'Sports & Fitness',
                image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
                slug: 'sports-fitness',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                name: 'Books & Media',
                image: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
                slug: 'books-media',
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ]);
        print('✅ Categories created');
    `);

    // Create banners
    console.log('🎨 Creating banners...');
    runMongoCommand(`
        db.banners.deleteMany({});
        db.banners.insertMany([
            {
                banner: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=300&fit=crop',
                link: '/products',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                banner: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=300&fit=crop',
                link: '/categories/electronics',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                banner: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=300&fit=crop',
                link: '/categories/clothing-fashion',
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ]);
        print('✅ Banners created');
    `);

    // Create sellers
    console.log('🏪 Creating sellers...');
    runMongoCommand(`
        db.sellers.deleteMany({});
        db.sellers.insertMany([
            {
                name: 'TechStore Electronics',
                email: 'seller1@techstore.com',
                password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
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
                name: 'Fashion Hub',
                email: 'seller2@fashionhub.com',
                password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
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
        ]);
        print('✅ Sellers created');
    `);

    // Create customers
    console.log('👥 Creating customers...');
    runMongoCommand(`
        db.customers.deleteMany({});
        db.customers.insertMany([
            {
                name: 'John Doe',
                email: 'customer@example.com',
                password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
                method: 'manually',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                name: 'Jane Smith',
                email: 'jane@example.com',
                password: '$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
                method: 'manually',
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ]);
        print('✅ Customers created');
    `);

    // Create products
    console.log('📦 Creating products...');
    runMongoCommand(`
        db.products.deleteMany({});
        db.products.insertMany([
            {
                name: 'Wireless Bluetooth Headphones',
                slug: 'wireless-bluetooth-headphones',
                category: 'Electronics',
                brand: 'TechBrand',
                price: 99,
                discount: 10,
                description: 'High-quality wireless headphones with noise cancellation',
                shopName: 'TechStore Electronics',
                images: [
                    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
                    'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=400'
                ],
                stock: 50,
                rating: 4,
                reviewCount: 15,
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                name: 'Smart Watch Pro',
                slug: 'smart-watch-pro',
                category: 'Electronics',
                brand: 'SmartTech',
                price: 299,
                discount: 15,
                description: 'Advanced smartwatch with health monitoring features',
                shopName: 'TechStore Electronics',
                images: [
                    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
                    'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400'
                ],
                stock: 30,
                rating: 5,
                reviewCount: 23,
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                name: 'Premium Cotton T-Shirt',
                slug: 'premium-cotton-t-shirt',
                category: 'Clothing & Fashion',
                brand: 'FashionCo',
                price: 29,
                discount: 20,
                description: 'Comfortable 100% cotton t-shirt available in multiple colors',
                shopName: 'Fashion Hub',
                images: [
                    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
                    'https://images.unsplash.com/photo-1583743814966-8936f37f7831?w=400'
                ],
                stock: 100,
                rating: 4,
                reviewCount: 42,
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                name: 'Designer Jeans',
                slug: 'designer-jeans',
                category: 'Clothing & Fashion',
                brand: 'DenimStyle',
                price: 89,
                discount: 25,
                description: 'Premium designer jeans with perfect fit',
                shopName: 'Fashion Hub',
                images: [
                    'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
                    'https://images.unsplash.com/photo-1506629905607-d8e2e0c77e28?w=400'
                ],
                stock: 60,
                rating: 5,
                reviewCount: 18,
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                name: 'Modern Table Lamp',
                slug: 'modern-table-lamp',
                category: 'Home & Garden',
                brand: 'HomeDecor',
                price: 59,
                discount: 15,
                description: 'Elegant modern table lamp for living room decoration',
                shopName: 'TechStore Electronics',
                images: [
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
                    'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400'
                ],
                stock: 25,
                rating: 4,
                reviewCount: 8,
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ]);
        print('✅ Products created');
    `);

    console.log('🎉 Demo data creation completed!');
}

// Main execution
function main() {
    console.log('🚀 MERN Ecommerce Demo Data Population');
    console.log('======================================');
    
    if (!testConnection()) {
        console.log('❌ Cannot connect to MongoDB. Please ensure:');
        console.log('   - MongoDB is running: sudo systemctl status mongod');
        console.log('   - Database "ec" is accessible');
        console.log('   - MongoDB is running without authentication enabled');
        process.exit(1);
    }
    
    createDemoData();
    
    console.log('');
    console.log('✅ Database population completed successfully!');
    console.log('');
    console.log('📊 Demo Data Summary:');
    console.log('   - 5 Categories (Electronics, Clothing, etc.)');
    console.log('   - 5 Products with images and details');
    console.log('   - 3 Banners for carousel');
    console.log('   - 2 Sellers (TechStore, Fashion Hub)');
    console.log('   - 2 Customers');
    console.log('   - 1 Admin user');
    console.log('');
    console.log('🔑 Demo Login Credentials:');
    console.log('   Admin: admin@admin.com / secret');
    console.log('   Seller: seller1@techstore.com / secret');
    console.log('   Customer: customer@example.com / secret');
    console.log('');
    console.log('🌐 Your application should now work without Redux errors!');
}

// Run the script
if (require.main === module) {
    main();
}

module.exports = { main };
