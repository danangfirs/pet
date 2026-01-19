import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/notification_item.dart';

final List<Pet> dummyPets = [
  Pet(
    id: 'p1',
    name: 'Milo',
    breed: 'Golden Retriever',
    imageUrl: 'https://images.unsplash.com/photo-1568572933382-74d440642117?q=80&w=2574&auto=format&fit=crop',
    batteryLevel: 0.9,
    isSafe: true,
    lastSeen: '2 menit lalu',
    location: 'Area Rumah',
    position: const Offset(0.3, 0.4),
  ),
  Pet(
    id: 'p2',
    name: 'Luna',
    breed: 'Kucing Persia',
    imageUrl: 'https://images.unsplash.com/photo-1574158622682-e40e6984100d?q=80&w=2680&auto=format&fit=crop',
    batteryLevel: 0.65,
    isSafe: true,
    lastSeen: '15 menit lalu',
    location: 'Taman Komplek',
    position: const Offset(0.7, 0.3),
  ),
  Pet(
    id: 'p3',
    name: 'Rocky',
    breed: 'Beagle',
    imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=2874&auto=format&fit=crop',
    batteryLevel: 0.15,
    isSafe: false,
    lastSeen: '1 jam lalu',
    location: 'Dekat Supermarket',
    position: const Offset(0.6, 0.7),
  ),
];

final List<NotificationItem> dummyNotifications = [
  NotificationItem(
    icon: Icons.shield,
    iconColor: Colors.orangeAccent,
    title: 'Peringatan Pagar Virtual',
    subtitle: 'Rocky telah keluar dari area aman "Rumah".',
    time: '5 menit lalu',
  ),
  NotificationItem(
    icon: Icons.battery_alert,
    iconColor: Colors.redAccent,
    title: 'Baterai Lemah',
    subtitle: 'Baterai tracker Rocky tersisa 15%. Segera isi ulang.',
    time: '1 jam lalu',
  ),
  NotificationItem(
    icon: Icons.check_circle,
    iconColor: Colors.greenAccent,
    title: 'Kembali ke Area Aman',
    subtitle: 'Luna telah kembali ke area aman "Taman Komplek".',
    time: '3 jam lalu',
  ),
   NotificationItem(
    icon: Icons.signal_cellular_off,
    iconColor: Colors.grey,
    title: 'Sinyal Hilang',
    subtitle: 'Sinyal tracker Milo terputus untuk sementara.',
    time: 'Kemarin',
  ),
];
