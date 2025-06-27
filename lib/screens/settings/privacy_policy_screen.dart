import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(height: 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kebijakan Privasi',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Terakhir diperbarui: 24 Juli 2024',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _buildParagraph(
              'Aplikasi ini adalah aplikasi yang beroperasi 100% offline. Kebijakan Privasi ini menjelaskan bagaimana kami menangani data Anda. Dengan menginstal dan menggunakan aplikasi ini, Anda menyetujui praktik yang dijelaskan dalam kebijakan ini.',
            ),
            _buildSectionTitle(context, '1. Tidak Ada Pengumpulan Data Pribadi'),
            _buildParagraph(
              'Kami tidak mengumpulkan, menyimpan, atau mentransmisikan informasi identitas pribadi (Personally Identifiable Information - PII) apa pun dari Anda. Ini termasuk, namun tidak terbatas pada, nama, alamat email, nomor telepon, atau lokasi Anda. Semua data yang Anda buat dalam aplikasi disimpan secara eksklusif di penyimpanan lokal perangkat Anda.',
            ),
            _buildSectionTitle(context, '2. Data yang Disimpan di Perangkat Anda'),
            _buildParagraph(
              'Semua data yang Anda masukkan ke dalam aplikasi (seperti catatan transaksi, data pelanggan, dll.) disimpan secara lokal di perangkat Anda. Data ini tidak dapat diakses oleh kami atau pihak ketiga mana pun. Anda memiliki kendali penuh atas data Anda.',
            ),
            _buildSectionTitle(context, '3. Keamanan Data'),
            _buildParagraph(
              'Keamanan data Anda adalah tanggung jawab Anda. Karena data disimpan di perangkat Anda, keamanannya bergantung pada keamanan perangkat Anda sendiri. Kami menyarankan Anda untuk menggunakan fitur keamanan perangkat seperti kunci layar (PIN, pola, atau sidik jari) untuk melindungi data Anda dari akses yang tidak sah.',
            ),
            _buildSectionTitle(context, '4. Izin Aplikasi (Permissions)'),
            _buildParagraph(
              'Aplikasi ini mungkin meminta izin tertentu (misalnya, akses ke penyimpanan) agar dapat berfungsi dengan baik. Izin ini hanya digunakan untuk menyimpan dan mengelola data aplikasi secara lokal di perangkat Anda. Kami tidak menggunakan izin ini untuk mengakses data pribadi Anda lainnya atau untuk mengirimkan informasi apa pun dari perangkat Anda.',
            ),
            _buildSectionTitle(context, '5. Tidak Ada Layanan Pihak Ketiga'),
            _buildParagraph(
              'Aplikasi ini tidak mengintegrasikan layanan pihak ketiga mana pun untuk analitik, iklan, atau tujuan lainnya yang dapat mengumpulkan data dari Anda.',
            ),
            _buildSectionTitle(context, '6. Privasi Anak-Anak'),
            _buildParagraph(
              'Aplikasi ini tidak ditujukan untuk anak-anak di bawah umur 13 tahun, dan kami tidak dengan sengaja mengumpulkan informasi pribadi dari anak-anak. Jika kami mengetahui bahwa informasi tersebut telah diberikan kepada kami, kami tidak memiliki cara untuk menghapusnya karena data tidak dikirimkan kepada kami.',
            ),
            _buildSectionTitle(context, '7. Perubahan pada Kebijakan Privasi'),
            _buildParagraph(
              'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Setiap pembaruan akan disertakan dalam versi baru aplikasi yang dirilis di Google Play Store. Anda disarankan untuk meninjau kebijakan ini secara berkala.',
            ),
            _buildSectionTitle(context, '8. Kontak Kami'),
            _buildParagraph(
              'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, silakan hubungi kami melalui informasi yang disediakan di halaman "Kontak Kami".',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 