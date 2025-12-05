#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#show: codly-init.with()
#codly(zebra-fill: none)

#set text(font: "Times New Roman", size: 12pt)
#set align(center)

#text(1.5em, weight: "bold", [IMPLEMENTASI PIPELINE GENERASI DATA SINTETIS MENGGUNAKAN CTGAN])

#v(1em)

Dosen Pengampu Mata Kuliah: John Doe S.Si

#v(1.5em)

#image("logo-telkom.png", width: 65%)

#v(1em)

Disusun Oleh:

#grid(
  columns: (auto, auto),
  column-gutter: 3em,
  row-gutter: 0.5em,
  align: (left, right),

  "Muhammad Karov Ardava Barus", "103052300001",
  "Muhammad Al Fayyedh Denof", "103052330042",
  "Avatar Bintang Ramadhan", "103052300007",
  "Runa Raditya Rizki Hidayat", "103052300037",
)

#v(1cm)

PROGRAM STUDI S1 SAINS DATA \
FAKULTAS INFORMATIKA \
UNIVERSITAS TELKOM \
BANDUNG \
2025

#pagebreak()
#set align(left)
#set par(
  first-line-indent: (amount: 1.25cm, all: true),
  spacing: 1.5em,
  justify: true
)

#show outline.entry.where(level: 1): set block(above: 1.2em)

#outline(title: "Daftar Isi")

#pagebreak()

= I. Pendahuluan

== 1.1 Latar Belakang
Pada minggu sebelumnya, kami telah merancang alur kerja (_pipeline_) untuk pembuatan data sintetis guna mengatasi masalah privasi dan ketidakseimbangan kelas pada dataset _Telco Customer Churn_. Minggu ke-4 ini berfokus pada tahap eksekusi teknis, yaitu mengimplementasikan rancangan tersebut ke dalam kode program menggunakan bahasa Python dan pustaka _Synthetic Data Vault_ (SDV).

== 1.2 Tujuan
Tujuan dari laporan progres minggu ke-4 ini adalah:
1.  Melakukan instalasi dan konfigurasi lingkungan pengembangan.
2.  Melakukan _preprocessing_ data untuk persiapan pelatihan model.
3.  Melatih model _Conditional Tabular GAN_ (CTGAN) menggunakan data asli.
4.  Membangkitkan (_generate_) dataset sintetis sebanyak 2.000 sampel.

= II. Implementasi Teknis

== 2.1 Persiapan Lingkungan
Kami menggunakan pustaka `sdv` versi terbaru. Instalasi dilakukan menggunakan `uv` untuk manajemen paket yang lebih cepat dan efisien.

#codly(languages: codly-languages)
```python
!uv pip install sdv
```

== 2.2 Preprocessing Data
Sebelum data dimasukkan ke dalam model, dilakukan beberapa tahapan pembersihan:
1.  **Penghapusan Identitas Langsung**: Kolom `customerID` dihapus karena merupakan _Direct Identifier_ yang unik untuk setiap pengguna dan tidak boleh dipelajari oleh model generatif.
2.  **Konversi Tipe Data**: Kolom `TotalCharges` dipastikan bertipe numerik, dan nilai kosong (_missing values_) diisi dengan nilai rata-rata (_mean imputation_).

```python
# Hapus Direct Identifiers
df_train = df.drop(columns=['customerID'])

# Handling Missing Values
df_train['TotalCharges'] = pd.to_numeric(df_train['TotalCharges'], errors='coerce')
df_train['TotalCharges'].fillna(df_train['TotalCharges'].mean(), inplace=True)
```

== 2.3 Pelatihan Model (Training)
Kami menggunakan algoritma `CTGANSynthesizer`. Metadata tabel (tipe data setiap kolom) dideteksi secara otomatis oleh library `sdv`. Model dilatih selama **100 epoch** untuk memastikan model mempelajari distribusi data dengan cukup baik.

```python
from sdv.single_table import CTGANSynthesizer
from sdv.metadata import SingleTableMetadata

# Deteksi Metadata
metadata = SingleTableMetadata()
metadata.detect_from_dataframe(df_train)

# Inisialisasi dan Training
synthesizer = CTGANSynthesizer(metadata, epochs=100, verbose=True)
synthesizer.fit(df_train)
```

== 2.4 Generasi Data (Sampling)
Setelah model dilatih, kami membangkitkan data sintetis. Sesuai dengan persyaratan tugas (minimal 1.500 sampel), kami membangkitkan **2.000 baris data**.

```python
# Generate 2000 baris data
n_samples = 2000
synthetic_data = synthesizer.sample(num_rows=n_samples)

# Simpan ke CSV
synthetic_data.to_csv('output/synthetic_telco_churn.csv', index=False)
```

= III. Hasil Implementasi

== 3.1 Proses Training
Proses pelatihan berjalan lancar dengan indikator _loss_ untuk Generator dan Discriminator yang terpantau stabil selama 100 epoch.

// #figure(
//   image("training-process.png", width: 80%),
//   caption: [Log Proses Training CTGAN]
// )
// *Catatan: Masukkan screenshot output cell training di sini.*

== 3.2 Sampel Data Sintetis
Berikut adalah cuplikan 5 baris pertama dari dataset sintetis yang berhasil dibangkitkan. Data ini memiliki struktur kolom yang sama persis dengan data asli (kecuali `customerID` yang memang sengaja tidak dibangkitkan).

// #figure(
//   image("synthetic-data-preview.png", width: 90%),
//   caption: [Preview Dataset Sintetis Hasil Generasi]
// )
// *Catatan: Masukkan screenshot df.head() di sini.*

== 3.3 Output File
File hasil generasi telah disimpan dengan nama `synthetic_telco_churn.csv` di dalam folder `output/`. File ini siap digunakan untuk tahap evaluasi utilitas dan privasi pada minggu berikutnya.

= IV. Kesimpulan

Implementasi _pipeline_ generasi data sintetis pada Minggu 4 telah berhasil dilakukan. Model CTGAN sukses dilatih menggunakan dataset _Telco Customer Churn_ yang telah diproses, dan menghasilkan 2.000 baris data sintetis. Langkah selanjutnya adalah melakukan evaluasi mendalam untuk membandingkan kualitas statistik dan privasi antara data asli dan data sintetis.
