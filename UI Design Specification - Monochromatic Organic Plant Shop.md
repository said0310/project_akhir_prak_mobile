# **UI Design Specification: Monochromatic Organic Plant Shop**

---

Dokumen spesifikasi desain ini disusun agar replikasi antarmuka aplikasi tanaman bergaya *monochromatic earthy green*, kartu *glassmorphism*, dan efek objek produk timbul (*3D pop-out*) dapat langsung diterapkan di Figma, kode (CSS/Flutter), maupun *UI generator*.

## **1\. Konsep & Arah Visual**

> * **Gaya Desain:** Minimalis modern dengan palet *monochromatic forest & sage green* yang bersih tanpa wallpaper atau pola latar belakang.  
> * **Kedalaman Visual (Depth):** Dibangun lewat tiga tingkat warna hijau (gelap, medium matte, dan transparan terang), permukaan kartu kaca buram lembut (*frosted sage glass*), serta objek produk potongan PNG transparan yang menembus tepi atas kartu agar terlihat timbul.  
> * **Target Kanvas & Grid:** Mobile Portrait 390 x 844 px (rasio 9:16), margin horizontal layar 24 px, skala spasi kelipatan 4 px.

## **2\. Sistem Warna (Color Palette & Tokens)**

| Token Nama | Preview & Kode Warna | Penggunaan pada Desain   |
| :---- | :---- | :---- |
| bg-primary | \#496A4D | Latar belakang utama seluruh layar (matte forest sage) |
| surface-dark | \#344E37 | Tombol notifikasi, search bar, tombol \>, tombol \+, dan Bottom Navigation Bar |
| surface-glass | rgba(218, 232, 219, 0.30) *(efektif: \#7F9A82)* | Permukaan kartu produk (*glass card*) di atas background utama |
| glass-border | rgba(255, 255, 255, 0.14) | Garis tepi tipis (1 px) untuk pantulan pinggiran kaca |
| text-white | \#FFFFFF | Heading besar (*All Plants*, *Promotion*), tab aktif (*All*), indikator tab, ikon lonceng, ikon \+, ikon nav aktif |
| text-muted-light | \#C6D6C7 | Sapaan (*Hello\!*), nama user, tab tidak aktif, dan deskripsi promosi |
| text-placeholder | \#9FB5A1 | Placeholder search... dan ikon panah \> |
| text-card-dark | \#263B28 | Nama produk (*Monstera*, *Deliciosa*) dan harga (*\$22*, *\$20*) di dalam kartu |
| icon-nav-inactive | \#BCC7BD | Ikon Home, Heart, dan Profile pada Bottom Navigation Bar |
| shadow-object | rgba(18, 32, 20, 0.38) | Bayangan kontak (*contact drop shadow*) tepat di bawah alas pot |

## **3\. Sistem Tipografi (Font & Hirarki)**

Menggabungkan dua karakter huruf yang kontras: font *wide/extended* ekstra tebal untuk judul bagian dan *geometric sans-serif* untuk antarmuka.

> * **Display / Section Heading:** *Monument Extended (Ultrabold)* atau *Akira Expanded*. Alternatif Google Fonts gratis: **Unbounded (800/900)** atau **Syne (800)**.  
> * **UI / Body / Labels:** **Poppins** (alternatif: *Plus Jakarta Sans* atau *Montserrat*).

| Elemen | Font Family | Weight | Size | Line Height | Warna   |
| :---- | :---- | :---- | :---- | :---- | :---- |
| Section Heading (*All Plants*, *Promotion*) | Monument Extended / Unbounded | ExtraBold (800–900) | 24–26 px | 1.15 | \#FFFFFF |
| Greeting (*Hello\!*) | Poppins | Regular (400) | 14 px | 1.3 | \#C6D6C7 |
| User Name (*Nuril Anggara*) | Poppins | SemiBold (600) | 18–20 px | 1.3 | \#C6D6C7 |
| Search Input (*search...*) | Poppins | Regular (400) | 14 px | 1.4 | \#9FB5A1 |
| Category Tab Aktif (*All*) | Poppins | SemiBold (600) | 15 px | 1.3 | \#FFFFFF |
| Category Tab Pasif | Poppins | Regular (400) | 15 px | 1.3 | \#C6D6C7 |
| Product Name (*Monstera*, *Deliciosa*) | Poppins | SemiBold (600) | 18 px | 1.2 | \#263B28 |
| Product Price (*\$22*, *\$20*) | Poppins | SemiBold (600) | 16 px | 1.2 | \#263B28 |
| Promo Subtext | Poppins | Regular (400) | 13–14 px | 1.5 | \#C6D6C7 |

## **4\. Pengaturan Kartu Glass & Efek Gambar Timbul (3D Pop-Out)**

### **A. Spesifikasi Kartu Glass (Glass Card)**

> * **Dimensi Kartu:** Lebar 200–215 px, Tinggi 265–280 px.  
> * **Corner Radius:** 28–32 px di keempat sudut.  
> * **Permukaan Glassmorphism:** Fill rgba(218, 232, 219, 0.30), efek blur backdrop-filter: blur(12px), stroke tipis 1 px solid rgba(255, 255, 255, 0.14).  
> * **Padding Internal:** 18 px pada sisi kiri, kanan, dan bawah.

### **B. Teknik Pengaturan Gambar Agak Timbul (Pop-Out Layering)**

> 1. **Aset Cutout Transparan:** Wajib menggunakan gambar PNG/WebP tanpa latar belakang kotak agar tanaman dan pot menyatu dengan permukaan kaca.  
> 2. **Overflow Visible (Jangan Clip):** Nonaktifkan *Clip Content* pada frame kartu. Beri ruang atas (padding-top: 28–32 px) pada container carousel agar pucuk daun yang keluar tidak terpotong oleh batas *scroll view*.  
> 3. **Negative Top Offset:** Tempatkan gambar tanaman dengan posisi top: \-24 px sampai \-28 px dari batas atas kartu dan lebar 108%–112% agar ujung daun sedikit melampaui bingkai atas dan samping.  
> 4. **Contact Shadow di Bawah Pot:** Fokuskan bayangan pada objek pot (bukan kotak kartu). Gunakan drop-shadow(0px 14px 16px rgba(18, 32, 20, 0.38)) atau tambahkan elips gelap dengan *Gaussian Blur* 14 px tepat di bawah alas pot agar pot terasa berdiri di atas kartu.

**Urutan Layer (Z-Index dari Belakang ke Depan):**

1\. Background Layar (\#496A4D) → 2\. Kartu Glass (surface-glass, radius 30 px) → 3\. Bayangan Kontak Alas Pot → 4\. Gambar Tanaman PNG (top: \-26 px) → 5\. Teks Nama & Harga (kiri bawah) \+ Tombol \+ (kanan bawah).

## **5\. Blueprint Layout & Spesifikasi Komponen (Atas ke Bawah)**

> 1. **Header Bar:** Flex horizontal space-between, rata tengah vertikal. Kiri: teks bertumpuk *"Hello\!"* dan nama pengguna (gap: 4 px). Kanan: tombol notifikasi 48 x 48 px, radius 14 px, fill \#344E37, ikon lonceng putih solid 22 px.  
> 2. **Search & Filter Row:** Jarak dari header 24–28 px, gap: 14 px. Search bar flex: 1, tinggi 52 px, radius 16 px, fill \#344E37, padding kiri 20 px. Tombol kanan 52 x 52 px, radius 16 px, fill \#344E37, ikon chevron kanan \> warna \#9FB5A1.  
> 3. **Category Tabs:** Jarak dari search row 20 px, distribusi merata (*All*, *Big plants*, *Outdoor*, *Indoor*). Indikator tab aktif berupa garis putih horizontal lebar 18 px, tinggi 2.5 px, radius 2 px, berjarak 6 px di bawah label aktif.  
> 4. **Section "All Plants" & Carousel:** Jarak dari tabs 24 px. Judul rata kiri. Carousel horizontal (gap: 20 px), kartu pertama sejajar padding kiri 24 px, kartu kedua terlihat sebagian (*peek*) di sisi kanan. Footer kartu berisi nama & harga (kiri bawah) serta tombol \+ ukuran 34 x 34 px, radius 10 px, fill \#344E37, ikon plus putih 16 px (kanan bawah).  
> 5. **Section "Promotion":** Jarak dari carousel 32 px. Judul display putih diikuti subteks margin-top: 8 px dengan lebar maksimal 85% agar terbagi rapi dalam dua baris.  
> 6. **Bottom Navigation Bar:** Menempel di dasar layar (lebar 100%, tinggi 80 px), fill \#344E37, radius sudut atas kiri & kanan 40 px (sudut bawah 0 px). Berisi 4 ikon solid ukuran 26–28 px merata horizontal: Home (\#BCC7BD), Plant/Leaf (**Aktif** \#FFFFFF), Heart (\#BCC7BD), Profile (\#BCC7BD).

## **6\. Referensi Kode Siap Pakai**

### **CSS (Web / Figma Dev Mode)**

.glass-plant-card {  
  position: relative;  
  width: 208px;  
  height: 270px;  
  background: rgba(218, 232, 219, 0.30);  
  backdrop-filter: blur(12px);  
  \-webkit-backdrop-filter: blur(12px);  
  border: 1px solid rgba(255, 255, 255, 0.14);  
  border-radius: 30px;  
  overflow: visible;  
  padding: 18px;  
  display: flex;  
  flex-direction: column;  
  justify-content: flex-end;  
}

.plant-popout-image {  
  position: absolute;  
  top: \-26px;  
  left: 50%;  
  transform: translateX(-50%);  
  width: 112%;  
  height: auto;  
  pointer-events: none;  
  filter: drop-shadow(0px 14px 16px rgba(18, 32, 20, 0.38));  
}

### **Flutter (Widget Structure)**

Stack(  
  clipBehavior: Clip.none, // Wajib agar objek timbul keluar kartu  
  children: \[  
    ClipRRect(  
      borderRadius: BorderRadius.circular(30),  
      child: BackdropFilter(  
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),  
        child: Container(  
          width: 208,  
          height: 270,  
          padding: const EdgeInsets.all(18),  
          decoration: BoxDecoration(  
            color: const Color(0xFFD9E8DA).withOpacity(0.30),  
            borderRadius: BorderRadius.circular(30),  
            border: Border.all(color: Colors.white.withOpacity(0.14)),  
          ),  
          // Footer: Nama Produk, Harga, dan Tombol '+'  
        ),  
      ),  
    ),  
    Positioned(  
      top: \-26,  
      left: \-8,  
      right: \-8,  
      child: Image.asset('assets/monstera\_cutout.png', fit: BoxFit.contain),  
    ),  
  \],  
);