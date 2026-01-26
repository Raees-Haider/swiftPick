puts "Seeding database..."
IMAGES_DIR = Rails.root.join('app', 'assets', 'images')
PLACEHOLDER_PNG = "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xdb\x00\x00\x00\x00IEND\xaeB`\x82".freeze

def placeholder_image
  require 'stringio'
  StringIO.new(PLACEHOLDER_PNG)
end

def attach_image(product, image_path, images_dir)
  return if product.image.attached?
  
  if image_path && File.exist?(images_dir.join(image_path))
    ext = File.extname(image_path)[1..-1].downcase
    content_type = case ext
                   when 'jpg', 'jpeg' then 'image/jpeg'
                   when 'png' then 'image/png'
                   when 'webp' then 'image/webp'
                   when 'gif' then 'image/gif'
                   else 'image/jpeg'
                   end
    
    File.open(images_dir.join(image_path), 'rb') do |file|
      product.image.attach(io: file, filename: image_path, content_type: content_type)
    end
  else
    product.image.attach(
      io: placeholder_image,
      filename: "#{product.name.parameterize}.png",
      content_type: 'image/png'
    )
  end
end

ActiveRecord::Base.transaction do
  admin = User.find_or_initialize_by(email: "admin@example.com")
  if admin.new_record?
    admin.assign_attributes(
      name: "Admin User",
      password: "admin123",
      role: "admin"
    )
    admin.save!
    puts "✓ Admin user created"
  else
    puts "✓ Admin user already exists"
  end
end

categories_data = [
  "Tech",
  "Books",
  "Home & Kitchen",
  "Gaming"
]

category_map = {}
ActiveRecord::Base.transaction do
  categories_data.each do |name|
    category = Category.find_or_create_by!(name: name)
    category_map[name] = category
  end
  puts "✓ Created/verified #{category_map.count} categories"
end
products_data = [
  {
    name: "Gaming Laptop",
    description: "High-performance gaming laptop with RTX graphics card, 16GB RAM, and 1TB SSD storage. Perfect for gaming and professional work.",
    price: 1299.99,
    stock_quantity: 15,
    active: true,
    categories: ["Tech","Gaming"],
    image_path: "gaming.jpg"
  },
  {
    name: "Wireless Headphones",
    description: "Premium noise-cancelling wireless headphones with 30-hour battery life and superior sound quality.",
    price: 199.99,
    stock_quantity: 50,
    active: true,
    categories: ["Tech","Gaming"],
    image_path: "Headphone.jpg"
  },
  {
    name: "Smartphone",
    description: "Latest generation smartphone with advanced camera system, 5G connectivity, and all-day battery life.",
    price: 899.99,
    stock_quantity: 30,
    active: true,
    categories: ["Tech","Gaming"],
    image_path: "Smartphone.jpg"
  },
  {
    name: "The Correspondent",
    description: "The Correspondent: A Novel by Virginia Evans (Author)",
    price: 16.99,
    stock_quantity: 200,
    active: true,
    categories: ["Books"],
    image_path: "book5.webp"
  },
  {
    name: "Heated Rivalry",
    description: "Heated Rivalry: Now Streaming on Crave and HBO Max (Game Changers, 2) by Rachel Reid (Author)",
    price: 34.99,
    stock_quantity: 80,
    active: true,
    categories: ["Books"],
    image_path: "book6.webp"
  },
  {
    name: "The Healing Power of Resilience",
    description: "The Healing Power of Resilience: A New Prescription for Health and Well-Being by Dr Tara Narula ",
    price: 34.99,
    stock_quantity: 80,
    active: true,
    categories: ["Books"],
    image_path: "book7.webp"
  },
  {
    name: "Reframe Your Brain",
    description: "Reframe Your Brain: The User Interface for Happiness and Success (The Scott Adams Success Series)",
    price: 34.99,
    stock_quantity: 80,
    active: true,
    categories: ["Books"],
    image_path: "book8.webp"
  },
  {
    name: "Coffee Maker",
    description: "Programmable coffee maker with thermal carafe, 12-cup capacity, and auto-shutoff feature.",
    price: 79.99,
    stock_quantity: 40,
    active: true,
    categories: ["Home & Kitchen"],
    image_path: "coffee.jpg"
  }
]

created_count = 0
updated_count = 0

ActiveRecord::Base.transaction do
  products_data.each do |data|
    product = Product.find_or_initialize_by(name: data[:name])
    is_new = product.new_record?
    
    product.assign_attributes(
      description: data[:description],
      price: data[:price],
      stock_quantity: data[:stock_quantity],
      active: data[:active]
    )
    
    if data[:categories].present?
      categories = data[:categories].map { |name| category_map[name] }.compact
      
      if categories.any?
        # Set primary category_id (required NOT NULL constraint)
        product.category_id = categories.first.id
        # Set all categories for many-to-many relationship
        product.category_ids = categories.map(&:id)
      end
    end
    
    # Attach image before saving (required for validation)
    attach_image(product, data[:image_path], IMAGES_DIR)
    
    product.save!
    
    is_new ? created_count += 1 : updated_count += 1
  end
end

puts "✓ Processed #{products_data.count} products (#{created_count} created, #{updated_count} updated)"

puts "\n" + "="*50
puts "Seeding completed successfully!"
puts "="*50
puts "Admin Login Credentials:"
puts "  Email: admin@example.com"
puts "  Password: admin123"
puts "="*50
