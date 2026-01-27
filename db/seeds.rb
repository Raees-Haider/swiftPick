puts "Seeding database..."
IMAGES_DIR = Rails.root.join('app', 'assets', 'images')
PLACEHOLDER_PNG = "\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xdb\x00\x00\x00\x00IEND\xaeB`\x82".freeze

def placeholder_image
  require 'stringio'
  StringIO.new(PLACEHOLDER_PNG)
end

def attach_image(product, image_path, images_dir)
  return if product.image.attached?
  
  require 'stringio'
  
  if image_path && File.exist?(images_dir.join(image_path))
    ext = File.extname(image_path)[1..-1].downcase
    content_type = case ext
                   when 'jpg', 'jpeg' then 'image/jpeg'
                   when 'png' then 'image/png'
                   when 'webp' then 'image/webp'
                   when 'gif' then 'image/gif'
                   else 'image/jpeg'
                   end

    file_content = File.binread(images_dir.join(image_path))
    product.image.attach(
      io: StringIO.new(file_content),
      filename: image_path,
      content_type: content_type
    )
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
    puts "Admin user created"
  else
    puts "Admin user already exists"
  end
end

categories_data = [
  "Tech",
  "Books",
  "Home & Kitchen",
  "Gaming",
  "Home Decor",
  "Cleaning"
]

category_map = {}
ActiveRecord::Base.transaction do
  categories_data.each do |name|
    category = Category.find_or_create_by!(name: name)
    category_map[name] = category
  end
  puts "Created/verified #{category_map.count} categories"
end
products_data = [
  {
    name: "Gaming Laptop",
    description: "High-performance gaming laptop with RTX graphics card, 16GB RAM, and 1TB SSD storage. Perfect for gaming and professional work.",
    price: 1299.99,
    stock_quantity: 15,
    active: true,
    categories: ["Tech","Gaming"],
    image_path: "asus gamin laptop.jpg"
  },
  {
    name: "Headphones",
    description: "Premium noise-cancelling wireless headphones with 30-hour battery life and superior sound quality.",
    price: 6199.99,
    stock_quantity: 50,
    active: true,
    categories: ["Tech","Gaming"],
    image_path: "blackshark.jpg"
  },
  {
    name: "Sceptre Curved Gaming Monitor",
    description: "Sceptre New Curved 24.5-inch Gaming Monitor up to 240Hz 1080p R1500 1ms DisplayPort x2 HDMI x2 Blue Light Shift Build-in Speakers, Machine Black 2025 (C255B-FWT240 Series)",
    price: 356199.99,
    stock_quantity: 50,
    active: true,
    categories: ["Tech","Gaming"],
    image_path: "curved monitor.jpg"
  },
  {
    name: "Razer Tartarus V2",
    description: "Razer Tartarus V2 Gaming Keypad: Mecha Membrane Key Switches - One Handed Keyboard - 32 Programmable Keys",
    price: 34199.99,
    stock_quantity: 50,
    active: true,
    categories: ["Tech","Gaming"],
    image_path: "Razer Tartarus V2.jpg"
  },
  {
    name: "Meta Quest",
    description: "Meta Quest 3S 128GB | VR Headset — Thirty-Three Percent More Memory — 2X Graphical Processing Power — Virtual Reality",
    price: 356199.99,
    stock_quantity: 50,
    active: true,
    categories: ["Tech","Gaming"],
    image_path: "Meta Quest.jpg"
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
    price: 3499.99,
    stock_quantity: 80,
    active: true,
    categories: ["Books"],
    image_path: "book8.webp"
  },
  {
    name: "Theo of Golden",
    description: "Theo of Golden: A Novel",
    price: 3499.99,
    stock_quantity: 80,
    active: true,
    categories: ["Books"],
    image_path: "book4.webp"
  },
  {
    name: "The Housemaid",
    description: "The Housemaid",
    price: 3499.99,
    stock_quantity: 80,
    active: true,
    categories: ["Books"],
    image_path: "book3.webp"
  },
  {
    name: "Coffee Maker",
    description: "Programmable coffee maker with thermal carafe, 12-cup capacity, and auto-shutoff feature.",
    price: 79.99,
    stock_quantity: 40,
    active: true,
    categories: ["Home & Kitchen"],
    image_path: "coffee.jpg"
  },
  {
    name: "LED Night Light",
    description: "LED Night Light[2 Pack], Night Lights Plug into Wall, 3 Level Brightness Adjustable Plug in Night Light",
    price: 4499.99,
    stock_quantity: 80,
    active: true,
    categories: ["Home Decor"],
    image_path: "decore4.jpg"
  },
  {
    name: "Bookshelf Decor Thinker Statue",
    description: "Bookshelf Decor Thinker Statue - Abstract Art Reading Thinker Sculpture Figurine Aesthetic",
    price: 3499.99,
    stock_quantity: 80,
    active: true,
    categories: ["Home Decor"],
    image_path: "decore5.jpg"
  },
  {
    name: "Candle Plate Holder Tray",
    description: " Candle Plate Holder Tray: Round Wood Decorative Candle Plate Decor Farmhouse Table Centerpiece",
    price: 4699.99,
    stock_quantity: 80,
    active: true,
    categories: ["Home Decor"],
    image_path: "decore6.jpg"
  },
  {
    name: "Broom and Dustpan Set",
    description: "Broom and Dustpan Set, Self-Cleaning with Dustpan Teeth, Indoor&Outdoor Sweeping",
    price: 1299.99,
    stock_quantity: 80,
    active: true,
    categories: ["Cleaning"],
    image_path: "clean6.jpg"
  },
  {
    name: "Clorox Disinfecting",
    description: "Clorox Disinfecting All-Purpose Cleaner 32 Oz and Disinfecting Bathroom Cleaner",
    price: 2499.99,
    stock_quantity: 80,
    active: true,
    categories: ["Cleaning"],
    image_path: "Clean7.jpg"
  },
  {
    name: "Spin Mop",
    description: "O-Cedar EasyWring Microfiber Spin Mop, Bucket Floor Cleaning System, Red, Gray, Standard",
    price: 1499.99,
    stock_quantity: 80,
    active: true,
    categories: ["Cleaning"],
    image_path: "Clean8.jpg"
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
        product.category_id = categories.first.id
        product.category_ids = categories.map(&:id)
      end
    end
    
    attach_image(product, data[:image_path], IMAGES_DIR)
    
    product.save!
    
    is_new ? created_count += 1 : updated_count += 1
  end
end

puts "Processed #{products_data.count} products (#{created_count} created, #{updated_count} updated)"

puts "\n" + "="*50
puts "Seeding completed successfully!"
puts "="*50
puts "Admin Login Credentials:"
puts "  Email: admin@example.com"
puts "  Password: admin123"
puts "="*50
