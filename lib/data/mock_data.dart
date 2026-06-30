import '../models/cart_item.dart';
import '../models/user_account.dart';
import '../models/vegetable.dart';

final mockVegetables = <Vegetable>[
  Vegetable(
    id: 'v1',
    name: 'Cải bó xôi',
    category: 'Rau lá',
    price: 28000,
    unit: 'bó',
    stock: 42,
    description:
        'Cải bó xôi tươi, giàu sắt và vitamin. Thu hoạch trong ngày từ nông trại đạt chuẩn.',
    imageUrl:
        'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=900',
  ),
  Vegetable(
    id: 'v2',
    name: 'Cà chua bi',
    category: 'Rau quả',
    price: 45000,
    unit: '500g',
    stock: 30,
    description:
        'Cà chua bi vị ngọt thanh, giòn mọng, phù hợp làm salad hoặc ăn trực tiếp.',
    imageUrl: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=900',
  ),
  Vegetable(
    id: 'v3',
    name: 'Bông cải xanh',
    category: 'Rau hoa',
    price: 52000,
    unit: '500g',
    stock: 18,
    description:
        'Bông cải xanh chắc bông, vị ngọt tự nhiên, giàu chất xơ và chất chống oxy hóa.',
    imageUrl:
        'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=900',
  ),
  Vegetable(
    id: 'v4',
    name: 'Cà rốt Đà Lạt',
    category: 'Rau củ',
    price: 35000,
    unit: 'kg',
    stock: 55,
    description:
        'Cà rốt Đà Lạt củ đều, giòn ngọt, thích hợp cho món canh, xào và nước ép.',
    imageUrl:
        'https://images.unsplash.com/photo-1447175008436-170170753dd2?w=900',
  ),
  Vegetable(
    id: 'v5',
    name: 'Xà lách lô lô',
    category: 'Rau lá',
    price: 32000,
    unit: '500g',
    stock: 25,
    description:
        'Xà lách lô lô xanh sạch, lá giòn, được trồng theo phương pháp thủy canh.',
    imageUrl:
        'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=900',
  ),
  Vegetable(
    id: 'v6',
    name: 'Ớt chuông',
    category: 'Rau quả',
    price: 68000,
    unit: '500g',
    stock: 16,
    description: 'Ớt chuông nhiều màu, ít hạt, vị ngọt nhẹ và giàu vitamin C.',
    imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=900',
  ),
  Vegetable(
    id: 'v7',
    name: 'Khoai tây',
    category: 'Rau củ',
    price: 38000,
    unit: 'kg',
    stock: 61,
    description:
        'Khoai tây ruột vàng, bở thơm, phù hợp chiên, nghiền hoặc nấu súp.',
    imageUrl:
        'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=900',
  ),
  Vegetable(
    id: 'v8',
    name: 'Bí ngòi xanh',
    category: 'Rau quả',
    price: 42000,
    unit: 'kg',
    stock: 21,
    description:
        'Bí ngòi non, mềm ngọt, ít calo và dễ chế biến trong nhiều món ăn.',
    imageUrl:
        'https://images.unsplash.com/photo-1596636478939-59fed7a083f2?w=900',
  ),
];

final mockCart = <CartItem>[
  CartItem(vegetable: mockVegetables[1], quantity: 2),
  CartItem(vegetable: mockVegetables[3]),
];

const mockAccounts = <UserAccount>[
  UserAccount(
    id: 'u1',
    name: 'Nguyễn Minh Anh',
    email: 'minhanh@gmail.com',
    role: UserRole.user,
  ),
  UserAccount(
    id: 'u2',
    name: 'Trần Hoàng Nam',
    email: 'nam.staff@green.vn',
    role: UserRole.staff,
  ),
  UserAccount(
    id: 'u3',
    name: 'Lê Thu Hà',
    email: 'ha@gmail.com',
    role: UserRole.user,
  ),
  UserAccount(
    id: 'u4',
    name: 'Phạm Quốc Bảo',
    email: 'bao.admin@green.vn',
    role: UserRole.admin,
  ),
  UserAccount(
    id: 'u5',
    name: 'Võ Thanh Trúc',
    email: 'truc@gmail.com',
    role: UserRole.user,
    active: false,
  ),
];
