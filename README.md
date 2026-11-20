# ❤️ sayangin mobile

## Tautan Penting
- Situs web (PWS): [muhammad-ghazi51-sayang-in.pws.cs.ui.ac.id](https://muhammad-ghazi51-sayang-in.pws.cs.ui.ac.id)
- Repositori situs web Django: [PBP-D-Kelompok-6/sayangin](https://github.com/PBP-D-Kelompok-6/sayangin)
- Desain Figma: [Figma](https://www.figma.com/design/gwE9NWB3Qvtjp4aHCL2q0R)
- APK: *menyusul setelah Checkpoint 1*

## Anggota Kelompok 6 - PBP D
| NPM | Nama |
|:---|:---|
| 2506551775 | Ira Arianti Alawiah |
| 2506584451 | Daffa Akmal Mahadaya Pasaribu |
| 2506621945 | Rania Yasin |
| 2506599541 | Muhammad Zaki Radipradana |
| 2506537751 | Muhammad Ghazi Alfisyahri Latief |

## Deskripsi Aplikasi
**sayangin** adalah platform jual-beli barang *preloved* yang masih layak pakai. Setiap pengguna punya **lemari digital** untuk mendata barang miliknya. Barang yang sudah lama tidak dipakai akan diingatkan oleh sistem, dengan pilihan untuk dijual, didonasikan, atau disimpan.

Donasi di sayangin dibuat **tepat sasaran**: lembaga seperti panti sosial dan sekolah mempublikasikan daftar kebutuhan yang spesifik, lalu pengguna mencocokkannya dengan barang di lemarinya. Untuk menjaga motivasi, aplikasi dilengkapi **gamifikasi**: poin dampak, papan peringkat, tantangan pribadi, dan lencana pencapaian.

Aplikasi mobile ini membawa fitur-fitur tersebut ke HP, dengan data yang sama seperti di situs web.

## Daftar Modul dan Pembagian Kerja
| Modul | Deskripsi | Penanggung Jawab |
|:---|:---|:---:|
| **Autentikasi dan Profil Pengguna** | Login, registrasi, dan logout dari aplikasi; membedakan akun personal dan akun lembaga; mengelola data diri, alamat, dan preferensi akun. | Ghazi |
| **Marketplace dan Transaksi** | Katalog barang *preloved* dengan pencarian dan filter, keranjang belanja, *checkout*, dan riwayat pembelian. | Ira |
| **Lemari Digital** | Mendata dan mengelola barang pribadi, melacak kapan terakhir dipakai, serta menawarkan opsi jual, donasi, atau simpan. | Daffa |
| **Donasi Tepat Sasaran** | Lembaga membuat daftar kebutuhan barang; pengguna mengajukan tawaran donasi yang cocok dari lemarinya. | Zaki |
| **Dampak dan Sosial (Gamifikasi)** | Dasbor poin dampak dan jumlah aksi (bulan ini atau sepanjang waktu), papan peringkat publik, tantangan pribadi (tambah, ubah, hapus), dan lencana pencapaian. | Rania |

## Peran Pengguna
### Pengguna Personal
Pengguna utama sayangin. Punya Lemari Digital, bisa membeli sekaligus menjual barang tanpa akun penjual terpisah, dan bisa berdonasi ke lembaga sesuai kebutuhan mereka. Pengguna personal juga memiliki dasbor Dampak, tantangan, dan lencana.

### Lembaga Mitra
Akun untuk penerima manfaat seperti panti asuhan, panti jompo, sekolah, atau komunitas sosial. Lembaga tidak punya Lemari Digital maupun akses jual-beli. Lembaga mempublikasikan daftar kebutuhan barang dan memperbarui status donasi yang sudah diterima.

### Tamu (belum login)
Bisa melihat halaman publik seperti papan peringkat Dampak (nama pengguna disamarkan), tetapi perlu login untuk bertransaksi, berdonasi, atau melihat dasbor Dampak.

## Alur Integrasi Data (Flutter ↔ Django)
```
Widget Flutter ──► fungsi API per modul ──► CookieRequest (pbp_django_auth) ──► endpoint DRF di situs web
      ▲                                                                                │
      └──────────── model Dart (fromJson) ◄──────────── respons JSON ◄─────────────────┘
```
1. **Login**: aplikasi mengirim username dan password ke endpoint autentikasi Django melalui `CookieRequest.login()`. Django membuat *session*, dan cookie session disimpan oleh `CookieRequest`.
2. **Satu sesi untuk semua modul**: `CookieRequest` disediakan sekali di atas `MaterialApp` dengan `Provider`, sehingga setiap modul memakai cookie login yang sama.
3. **Mengambil dan mengirim data**: setiap modul memanggil endpoint Django REST Framework miliknya secara asinkron (`get`, `post`, dan untuk ubah/hapus `PATCH`/`DELETE`) dengan cookie session tersebut.
4. **Otorisasi di server**: endpoint DRF memeriksa login dan peran akun (personal atau lembaga), lalu hanya mengembalikan data milik pengguna tersebut.
5. **Menampilkan data**: respons JSON diubah menjadi model Dart (`fromJson`) dan ditampilkan di widget, lengkap dengan tampilan *loading* dan *error*.

Karena aplikasi dan situs web memakai database yang sama, data yang dibuat di aplikasi langsung muncul di situs web, dan sebaliknya.

## Daftar Endpoint Django REST Framework
Alamat dasar: `https://muhammad-ghazi51-sayang-in.pws.cs.ui.ac.id`

### Dampak dan Sosial (Rania)
| Method | Endpoint | Fungsi | Akses |
|:---|:---|:---|:---|
| GET | `/dampak/api/dashboard/?periode=bulan\|semua` | Poin, jumlah aksi, lencana, 5 besar peringkat, dan tantangan di dasbor | Akun personal |
| GET | `/dampak/api/peringkat/?periode=bulan\|semua` | Papan peringkat 10 besar dan cara mendapat poin | Semua (tamu: nama disamarkan) |
| GET | `/dampak/api/tantangan/?jenis=&status=` | Daftar tantangan milik pengguna, bisa difilter | Akun personal |
| POST | `/dampak/api/tantangan/` | Membuat tantangan baru | Akun personal |
| GET | `/dampak/api/tantangan/<id>/` | Detail satu tantangan | Pemilik tantangan |
| PATCH | `/dampak/api/tantangan/<id>/` | Mengubah tantangan | Pemilik tantangan |
| DELETE | `/dampak/api/tantangan/<id>/` | Menghapus tantangan | Pemilik tantangan |

### Autentikasi dan Profil Pengguna (Ghazi)
*Menyusul.*

### Marketplace dan Transaksi (Ira)
*Menyusul.*

### Lemari Digital (Daffa)
*Menyusul.*

### Donasi Tepat Sasaran (Zaki)
*Menyusul.*
