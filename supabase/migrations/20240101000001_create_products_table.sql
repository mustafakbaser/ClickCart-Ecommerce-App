-- Create products table
create table if not exists public.products (
    id uuid default gen_random_uuid() primary key,
    legacy_id text unique,
    title text not null,
    description text not null,
    price decimal(10,2) not null check (price >= 0),
    image_url text not null,
    category text not null,
    stock integer not null check (stock >= 0),
    featured boolean default false,
    created_at timestamptz default timezone('utc'::text, now()) not null,
    updated_at timestamptz default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security (RLS)
alter table public.products enable row level security;

-- Create policies
create policy "Products are viewable by everyone"
    on products for select
    using ( true );

create policy "Only authenticated users can create products"
    on products for insert
    with check ( auth.role() = 'authenticated' );

create policy "Only authenticated users can update products"
    on products for update
    using ( auth.role() = 'authenticated' );

-- Create indexes
create index products_category_idx on products(category);
create index products_featured_idx on products(featured);
create index products_legacy_id_idx on products(legacy_id);

-- Insert additional products (3 per category)
insert into public.products (legacy_id, title, description, price, image_url, category, stock, featured) values
-- Electronics (3 new products)
('123e4567-e89b-12d3-a456-426614174022',
 'Portable Power Station',
 'High-capacity 1000Wh portable battery with AC outlets, USB ports, and solar charging capability',
 899.99,
 'https://images.unsplash.com/photo-1598085322003-5c4bf871c363?w=500',
 'Electronics',
 20,
 false),

('123e4567-e89b-12d3-a456-426614174023',
 '4K Webcam Pro',
 'Professional streaming camera with AI-powered autofocus and background blur',
 199.99,
 'https://images.unsplash.com/photo-1587476353350-5d13573e0ea3?w=500',
 'Electronics',
 40,
 true),

('123e4567-e89b-12d3-a456-426614174024',
 'Smart Home Hub',
 'Central control unit for home automation with voice control and device scheduling',
 149.99,
 'https://images.unsplash.com/photo-1558002038-1055f870f6c7?w=500',
 'Electronics',
 30,
 false),

-- Fashion (3 new products)
('123e4567-e89b-12d3-a456-426614174025',
 'Merino Wool Sweater',
 'Premium New Zealand merino wool sweater with seamless construction',
 129.99,
 'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=500',
 'Fashion',
 45,
 true),

('123e4567-e89b-12d3-a456-426614174026',
 'Crossbody Leather Bag',
 'Handcrafted full-grain leather bag with adjustable strap and brass hardware',
 179.99,
 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=500',
 'Fashion',
 35,
 false),

('123e4567-e89b-12d3-a456-426614174027',
 'Smart Casual Blazer',
 'Unstructured cotton-blend blazer perfect for both office and casual wear',
 249.99,
 'https://images.unsplash.com/photo-1592878904946-b3cd8ae243d0?w=500',
 'Fashion',
 25,
 true),

-- Home & Garden (3 new products)
('123e4567-e89b-12d3-a456-426614174028',
 'Indoor Herb Garden Kit',
 'Self-watering indoor garden with LED grow lights and 6 herb pods',
 89.99,
 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=500',
 'Home & Garden',
 50,
 true),

('123e4567-e89b-12d3-a456-426614174029',
 'Smart Air Purifier',
 'HEPA air purifier with air quality monitoring and smartphone control',
 299.99,
 'https://images.unsplash.com/photo-1626436629565-8a147b7642df?w=500',
 'Home & Garden',
 30,
 false),

('123e4567-e89b-12d3-a456-426614174030',
 'Premium Bedding Set',
 '1000 thread count Egyptian cotton bedding set with duvet cover and pillowcases',
 199.99,
 'https://images.unsplash.com/photo-1629140727571-9b5c6f6267b4?w=500',
 'Home & Garden',
 40,
 true),

-- Sports & Outdoors (3 new products)
('123e4567-e89b-12d3-a456-426614174031',
 'Electric Skateboard',
 'Dual-motor electric skateboard with wireless remote and regenerative braking',
 699.99,
 'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=500',
 'Sports & Outdoors',
 15,
 true),

('123e4567-e89b-12d3-a456-426614174032',
 'Inflatable SUP Board',
 'Complete paddle board set with pump, paddle, and carrying backpack',
 449.99,
 'https://images.unsplash.com/photo-1526383103106-edad26ae7572?w=500',
 'Sports & Outdoors',
 20,
 false),

('123e4567-e89b-12d3-a456-426614174033',
 'Climbing Gear Set',
 'Complete set including harness, chalk bag, and climbing shoes',
 299.99,
 'https://images.unsplash.com/photo-1522163182402-834f871fd851?w=500',
 'Sports & Outdoors',
 25,
 true),

-- Books (3 new products)
('123e4567-e89b-12d3-a456-426614174034',
 'Artificial Intelligence: A Modern Approach',
 'Comprehensive guide to AI and machine learning with practical applications',
 79.99,
 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=500',
 'Books',
 60,
 true),

('123e4567-e89b-12d3-a456-426614174035',
 'Sustainable Living Guide',
 'Practical handbook for eco-friendly lifestyle and sustainable practices',
 29.99,
 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500',
 'Books',
 80,
 false),

('123e4567-e89b-12d3-a456-426614174036',
 'World History Collection',
 'Illustrated collection of major historical events and their impact',
 89.99,
 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500',
 'Books',
 45,
 true);

 -- Insert additional sample products
insert into public.products (legacy_id, title, description, price, image_url, category, stock, featured) values
-- Electronics (Additional)
('123e4567-e89b-12d3-a456-426614174004',
 'Samsung 65" QLED 4K TV',
 'Quantum Dot technology delivers brilliant colors with 100% Color Volume, Quantum Processor optimizes every scene',
 1299.99,
 'https://images.unsplash.com/photo-1593784991095-a205069470b6?w=500',
 'Electronics',
 20,
 true),

('123e4567-e89b-12d3-a456-426614174005',
 'iPad Air 5th Generation',
 'M1 chip. 10.9-inch Liquid Retina display with True Tone and P3 wide color',
 599.99,
 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500',
 'Electronics',
 45,
 false),

('123e4567-e89b-12d3-a456-426614174006',
 'Bose QuietComfort Earbuds II',
 'Wireless Bluetooth earbuds with personalized noise cancellation and high-fidelity audio',
 299.99,
 'https://images.unsplash.com/photo-1590658165737-15a047b1c33f?w=500',
 'Electronics',
 35,
 true),

-- Fashion (Additional)
('123e4567-e89b-12d3-a456-426614174007',
 'Designer Wool Coat',
 'Premium wool blend winter coat with satin lining and genuine horn buttons',
 449.99,
 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=500',
 'Fashion',
 25,
 true),

('123e4567-e89b-12d3-a456-426614174008',
 'Italian Leather Boots',
 'Handcrafted Chelsea boots made from full-grain Italian leather with Goodyear welt construction',
 279.99,
 'https://images.unsplash.com/photo-1542840410-3092f99611a3?w=500',
 'Fashion',
 40,
 false),

-- Home & Garden (New Category)
('123e4567-e89b-12d3-a456-426614174009',
 'Smart Garden Irrigation System',
 'WiFi-enabled automatic watering system with weather monitoring and smartphone control',
 199.99,
 'https://images.unsplash.com/photo-1588964895597-cfccd6e2dbf9?w=500',
 'Home & Garden',
 30,
 true),

('123e4567-e89b-12d3-a456-426614174010',
 'Ergonomic Office Chair',
 'Premium mesh back office chair with lumbar support and adjustable armrests',
 349.99,
 'https://images.unsplash.com/photo-1592078615290-033ee584e267?w=500',
 'Home & Garden',
 25,
 false),

('123e4567-e89b-12d3-a456-426614174011',
 'Robot Vacuum Cleaner',
 'Smart mapping technology with multi-floor plans and automatic dust bin emptying',
 499.99,
 'https://images.unsplash.com/photo-1588072432836-e10032774350?w=500',
 'Home & Garden',
 20,
 true),

-- Sports & Outdoors (New Category)
('123e4567-e89b-12d3-a456-426614174012',
 'Carbon Fiber Mountain Bike',
 'Professional grade mountain bike with full suspension and hydraulic disc brakes',
 2499.99,
 'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=500',
 'Sports & Outdoors',
 10,
 true),

('123e4567-e89b-12d3-a456-426614174013',
 'Smart Fitness Watch',
 'Advanced health monitoring with GPS, heart rate tracking, and 7-day battery life',
 199.99,
 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=500',
 'Sports & Outdoors',
 50,
 true),

('123e4567-e89b-12d3-a456-426614174014',
 'Professional Tennis Racket',
 'Lightweight graphite construction with optimal power and control',
 159.99,
 'https://images.unsplash.com/photo-1622279457486-62dbd3a8552e?w=500',
 'Sports & Outdoors',
 35,
 false),

-- Books (New Category)
('123e4567-e89b-12d3-a456-426614174015',
 'The Art of Programming',
 'Comprehensive guide to modern software development practices and principles',
 49.99,
 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500',
 'Books',
 100,
 true),

('123e4567-e89b-12d3-a456-426614174016',
 'Photography Masterclass',
 'Complete guide to digital photography with practical exercises and case studies',
 39.99,
 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=500',
 'Books',
 75,
 false),

-- Additional Electronics
('123e4567-e89b-12d3-a456-426614174017',
 'Gaming Desktop PC',
 'Custom built gaming PC with RTX 4080, 32GB RAM, and 2TB SSD',
 2999.99,
 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=500',
 'Electronics',
 15,
 true),

-- Additional Fashion
('123e4567-e89b-12d3-a456-426614174018',
 'Designer Sunglasses',
 'Polarized UV protection lenses with Italian acetate frames',
 199.99,
 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500',
 'Fashion',
 60,
 false),

-- Additional Home & Garden
('123e4567-e89b-12d3-a456-426614174019',
 'Smart Home Security System',
 'Complete home security solution with cameras, sensors, and 24/7 monitoring',
 599.99,
 'https://images.unsplash.com/photo-1558002038-1055f870f6c7?w=500',
 'Home & Garden',
 25,
 true),

-- Additional Sports & Outdoors
('123e4567-e89b-12d3-a456-426614174020',
 'Camping Tent 4-Person',
 'All-season waterproof tent with quick setup and premium materials',
 299.99,
 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=500',
 'Sports & Outdoors',
 30,
 false),

-- Additional Books
('123e4567-e89b-12d3-a456-426614174021',
 'Financial Intelligence',
 'Comprehensive guide to personal finance and investment strategies',
 34.99,
 'https://images.unsplash.com/photo-1554244933-d876deb6b2ff?w=500',
 'Books',
 85,
 true);
