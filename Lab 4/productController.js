const Product = require('../models/product');

const createProduct = async (name, price, category, inStock) => {
  try {
    const newProduct = new Product({ name, price, category, inStock });
    await newProduct.save();
    console.log(`Product created: ${name}`);
  } catch (err) {
    console.error('Error creating product:', err.message);
  }
};

const getAllProducts = async () => {
  try {
    const products = await Product.find();
    console.log('\n--- All Products ---');
    console.log(products);
  } catch (err) {
    console.error('Error fetching products:', err.message);
  }
};

const updateProduct = async (name, newPrice, newCategory) => {
  try {
    await Product.updateOne({ name: name }, { $set: { price: newPrice, category: newCategory } });
    console.log(`\nProduct updated: ${name}`);
  } catch (err) {
    console.error('Error updating product:', err.message);
  }
};

const deleteProduct = async (name) => {
  try {
    await Product.deleteOne({ name: name });
    console.log(`\nProduct deleted: ${name}`);
  } catch (err) {
    console.error('Error deleting product:', err.message);
  }
};

const findProductByCategory = async (category) => {
  try {
    const products = await Product.find({ category: category });
    console.log(`\n--- Products in category: ${category} ---`);
    console.log(products);
  } catch (err) {
    console.error('Error finding products by category:', err.message);
  }
};

module.exports = {
  createProduct,
  getAllProducts,
  updateProduct,
  deleteProduct,
  findProductByCategory
};