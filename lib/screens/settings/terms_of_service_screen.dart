import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
        title: const Text('Syarat & Ketentuan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Syarat & Ketentuan Penggunaan',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Terakhir diperbarui: 24 Juli 2024',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _buildParagraph(
              'Selamat datang di aplikasi kami. Syarat dan Ketentuan ini mengatur penggunaan Anda terhadap aplikasi kami yang beroperasi 100% offline. Dengan mengunduh, menginstal, atau menggunakan aplikasi ini, Anda secara tegas menyetujui dan terikat oleh semua syarat yang tercantum di bawah ini.',
            ),
            _buildSectionTitle(context, '1. Sifat Aplikasi Offline'),
            _buildParagraph(
              'Aplikasi ini dirancang untuk berfungsi sepenuhnya tanpa koneksi internet. Semua data yang Anda masukkan dan kelola disimpan secara eksklusif di penyimpanan lokal perangkat Anda. Aplikasi ini tidak mengirimkan data apa pun ke server kami atau pihak ketiga mana pun.',
            ),
            _buildSectionTitle(context, '2. Kepemilikan dan Tanggung Jawab Data'),
            _buildParagraph(
              'Anda memiliki kepemilikan penuh dan tanggung jawab penuh atas semua data yang Anda masukkan ke dalam aplikasi. Karena data disimpan secara lokal, kami tidak memiliki akses, kontrol, atau kemampuan untuk memulihkan data Anda jika perangkat Anda hilang, rusak, atau jika Anda menghapus aplikasi. Anda sangat dianjurkan untuk secara rutin membuat cadangan (backup) data Anda sendiri.',
            ),
            _buildSectionTitle(context, '3. Lisensi Penggunaan'),
            _buildParagraph(
              'Kami memberikan Anda lisensi terbatas, non-eksklusif, tidak dapat dialihkan, dan dapat dibatalkan untuk menggunakan aplikasi ini untuk tujuan pribadi atau bisnis internal Anda, sesuai dengan Syarat dan Ketentuan ini.',
            ),
            _buildSectionTitle(context, '4. Larangan Penggunaan'),
            _buildParagraph(
              'Anda setuju untuk tidak:\n'
              '• Menyalin, memodifikasi, atau mendistribusikan aplikasi.\n'
              '• Melakukan rekayasa balik (reverse engineer) atau mencoba mengekstrak kode sumber aplikasi.\n'
              '• Menggunakan aplikasi untuk tujuan ilegal atau melanggar hukum yang berlaku.\n'
              '• Menghapus atau mengubah pemberitahuan hak cipta atau kepemilikan lainnya.',
            ),
            _buildSectionTitle(context, '5. Penafian Jaminan (Disclaimer of Warranties)'),
            _buildParagraph(
              'Aplikasi ini disediakan "SEBAGAIMANA ADANYA" dan "SEBAGAIMANA TERSEDIA", tanpa jaminan dalam bentuk apa pun, baik tersurat maupun tersirat. Kami tidak menjamin bahwa aplikasi akan bebas dari kesalahan, bug, atau gangguan.',
            ),
            _buildSectionTitle(context, '6. Batasan Tanggung Jawab'),
            _buildParagraph(
              'Dalam batas maksimal yang diizinkan oleh hukum, kami tidak akan bertanggung jawab atas segala kerusakan tidak langsung, insidental, khusus, konsekuensial, atau ganti rugi, termasuk namun tidak terbatas pada, kehilangan keuntungan, kehilangan data, atau gangguan bisnis yang timbul dari atau terkait dengan penggunaan atau ketidakmampuan Anda untuk menggunakan aplikasi ini.',
            ),
            _buildSectionTitle(context, '7. Perubahan pada Syarat & Ketentuan'),
            _buildParagraph(
              'Kami berhak untuk mengubah Syarat dan Ketentuan ini dari waktu ke waktu. Setiap perubahan akan diberitahukan kepada Anda melalui pembaruan aplikasi di Google Play Store. Dengan terus menggunakan aplikasi setelah perubahan tersebut, Anda dianggap menyetujui syarat yang telah diperbarui.',
            ),
            _buildSectionTitle(context, '8. Hukum yang Mengatur'),
            _buildParagraph(
              'Syarat dan Ketentuan ini diatur oleh dan ditafsirkan sesuai dengan hukum yang berlaku di Republik Indonesia.',
            ),
            _buildSectionTitle(context, '9. Informasi Kontak'),
            _buildParagraph(
              'Jika Anda memiliki pertanyaan mengenai Syarat dan Ketentuan ini, silakan hubungi kami melalui informasi yang tersedia di halaman "Kontak Kami" di dalam aplikasi.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
} 