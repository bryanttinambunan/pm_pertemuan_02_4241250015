import 'package:flutter/material.dart';

typedef Product = ({String nama, String kategori, int harga});
typedef OrderItem = ({
  String kode,
  String nama,
  String kategori,
  int harga,
  int jumlah,
});
typedef RejectedItem = ({String teks, String alasan});

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kasir Oleh-Oleh Medan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B52),
          surface: const Color(0xFFF7F8F5),
        ),
        useMaterial3: true,
      ),
      home: const CashierPage(),
    );
  }
}

class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  final TextEditingController _orderController = TextEditingController();
  final Map<String, Product> _catalog = {
    'P01': (nama: 'Kopi Sidikalang 250 g', kategori: 'Kopi', harga: 45000),
    'P02': (nama: 'Kopi Gayo 250 g', kategori: 'Kopi', harga: 55000),
    'P03': (nama: 'Teh Kayu Aro 100 g', kategori: 'Teh', harga: 25000),
    'P04': (nama: 'Gula Aren 500 g', kategori: 'Pemanis', harga: 30000),
    'P05': (nama: 'Bolu Meranti', kategori: 'Makanan', harga: 80000),
  };

  List<OrderItem> _orderItems = [];
  List<RejectedItem> _rejectedItems = [];
  bool _hasSubmitted = false;

  int get _total => _orderItems
      .map((item) => item.harga * item.jumlah)
      .fold(0, (total, subtotal) => total + subtotal);

  int get _discount => _total >= 100000 ? _total * 10 ~/ 100 : 0;

  Set<String> get _categories =>
      _orderItems.map((item) => item.kategori).toSet();

  void _processOrder() {
    final List<OrderItem> accepted = [];
    final List<RejectedItem> rejected = [];

    for (final section in _orderController.text.split(',')) {
      final String order = section.trim();
      if (order.isEmpty) {
        continue;
      }

      final List<String> parts = order.split('x');
      if (parts.length != 2) {
        rejected.add((teks: order, alasan: 'Format harus KODExJUMLAH'));
        continue;
      }

      final String code = parts[0].trim().toUpperCase();
      final int? quantity = int.tryParse(parts[1].trim());
      if (quantity == null || quantity <= 0) {
        rejected.add((
          teks: order,
          alasan: 'Jumlah harus bilangan bulat positif',
        ));
        continue;
      }

      final Product? product = _catalog[code];
      if (product == null) {
        rejected.add((teks: order, alasan: 'Kode produk tidak ditemukan'));
        continue;
      }

      accepted.add((
        kode: code,
        nama: product.nama,
        kategori: product.kategori,
        harga: product.harga,
        jumlah: quantity,
      ));
    }

    setState(() {
      _orderItems = accepted;
      _rejectedItems = rejected;
      _hasSubmitted = true;
    });
  }

  @override
  void dispose() {
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir Oleh-Oleh Medan'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildSectionTitle('Katalog Produk', 'Pilih kode untuk pesanan Anda'),
          const SizedBox(height: 12),
          ..._catalog.entries.map((entry) => _buildProductCard(entry)),
          const SizedBox(height: 24),
          _buildSectionTitle('Pesanan', 'Pisahkan setiap item dengan koma'),
          const SizedBox(height: 12),
          TextField(
            key: const Key('orderInput'),
            controller: _orderController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _processOrder(),
            decoration: InputDecoration(
              hintText: 'Contoh: P01x2, P03x1',
              prefixIcon: const Icon(Icons.receipt_long_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            key: const Key('processOrderButton'),
            onPressed: _processOrder,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Proses Pesanan'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Struk Belanja', 'Ringkasan pesanan Anda'),
          const SizedBox(height: 12),
          _buildReceipt(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.storefront_outlined, color: colors.onPrimary, size: 38),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rasa Khas Sumatera Utara',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pesan oleh-oleh favoritmu dengan mudah.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colors.onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildProductCard(MapEntry<String, Product> entry) {
    final Product product = entry.value;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _iconForCategory(product.kategori),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(product.nama),
        subtitle: Text('${entry.key} · ${product.kategori}'),
        trailing: Text(
          formatRupiah(product.harga),
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildReceipt(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: !_hasSubmitted
            ? const Text('Masukkan pesanan untuk melihat struk.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_orderItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('Tidak ada item valid dalam pesanan.'),
                    )
                  else
                    ..._orderItems.map(_buildReceiptItem),
                  const Divider(height: 24),
                  _buildAmountRow('Total', _total),
                  const SizedBox(height: 8),
                  _buildAmountRow('Diskon (10%)', _discount),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Jumlah bayar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          formatRupiah(_total - _discount),
                          style: TextStyle(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kategori dibeli',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (_categories.isEmpty)
                    const Text('-')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _categories
                          .map((category) => Chip(label: Text(category)))
                          .toList(),
                    ),
                  if (_rejectedItems.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Item yang ditolak',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: colors.error),
                    ),
                    const SizedBox(height: 6),
                    ..._rejectedItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${item.teks}: ${item.alasan}',
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildReceiptItem(OrderItem item) {
    final int subtotal = item.harga * item.jumlah;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nama),
                Text(
                  '${item.kode} · ${item.jumlah} x ${formatRupiah(item.harga)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(formatRupiah(subtotal)),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, int amount) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(formatRupiah(amount)),
      ],
    );
  }

  IconData _iconForCategory(String category) {
    return switch (category) {
      'Kopi' => Icons.coffee_outlined,
      'Teh' => Icons.emoji_food_beverage_outlined,
      'Pemanis' => Icons.cookie_outlined,
      _ => Icons.bakery_dining_outlined,
    };
  }
}

String formatRupiah(int amount) {
  final String formatted = amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'Rp $formatted';
}
