class DonationApiService {
  // Ganti baseUrl sesuai domain deployment Django PWS atau IP lokal (misal: 10.0.2.2 untuk emulator Android)
  static const String baseUrl = 'http://localhost:8000';

  // Contoh placeholder fetch data donasi
  Future<List<dynamic>> fetchDonations() async {
    // Akan diimplementasikan menggunakan http.get / pbp_django_auth
    return [];
  }

  // Contoh placeholder kirim donasi
  Future<bool> createDonation(Map<String, dynamic> data) async {
    // Akan diimplementasikan menggunakan http.post / pbp_django_auth
    return true;
  }
}