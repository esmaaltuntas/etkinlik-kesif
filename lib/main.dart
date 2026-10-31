
import 'package:flutter/material.dart';
import 'event_model.dart';
import 'event_service.dart';
import 'favorite_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Etkinlik Keşif',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final EventService service = EventService();
  final FavoriteService favoriteService = FavoriteService();

  late Future<List<Event>> etkinlikler;

  Set<String> favoriler = {};

  int seciliSayfa = 0;
  String seciliKategori = 'Tümü';
  String aramaMetni = '';

  final List<String> kategoriler = [
    'Tümü',
    'Hackathon',
    'Panel',
    'Seminer',
    'Sosyal',
    'Workshop',
  ];

  @override
  void initState() {
    super.initState();
    etkinlikler = service.getEvents();
    favorileriYukle();
  }

  Future<void> favorileriYukle() async {
    final kayitliFavoriler =
        await favoriteService.favorileriGetir();

    if (!mounted) return;

    setState(() {
      favoriler = kayitliFavoriler;
    });
  }

  Future<void> favoriDegistir(String id) async {
    setState(() {
      if (favoriler.contains(id)) {
        favoriler.remove(id);
      } else {
        favoriler.add(id);
      }
    });

    await favoriteService.favorileriKaydet(favoriler);
  }

  void tekrarYukle() {
    setState(() {
      etkinlikler = service.getEvents();
    });
  }

  String tarihFormatla(DateTime tarih) {
    return '${tarih.day}.${tarih.month}.${tarih.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          seciliSayfa == 0
              ? 'Etkinlik Keşfet'
              : 'Favorilerim',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: FutureBuilder<List<Event>>(
        future: etkinlikler,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Etkinlikler yüklenemedi.'),
                  const SizedBox(height: 10),
                  Text('${snapshot.error}'),
                  ElevatedButton(
                    onPressed: tekrarYukle,
                    child: const Text('Tekrar dene'),
                  ),
                ],
              ),
            );
          }

          final List<Event> tumEtkinlikler =
              snapshot.data ?? <Event>[];

          List<Event> gosterilecekEtkinlikler =
              tumEtkinlikler;

          // Favoriler sayfasında favorileri göster.
          if (seciliSayfa == 1) {
            gosterilecekEtkinlikler =
                gosterilecekEtkinlikler
                    .where((e) => favoriler.contains(e.id))
                    .toList();
          }

          // Seçilen kategoriye göre filtrele.
          if (seciliKategori != 'Tümü') {
            gosterilecekEtkinlikler =
                gosterilecekEtkinlikler
                    .where(
                      (e) => e.category == seciliKategori,
                    )
                    .toList();
          }
          // Arama metnine göre filtrele.
if (aramaMetni.isNotEmpty) {
  gosterilecekEtkinlikler =
      gosterilecekEtkinlikler.where((e) {
    return e.title
        .toLowerCase()
        .contains(aramaMetni.toLowerCase());
  }).toList();
}

          

          return Column(
            children: [
              Padding(
  padding: const EdgeInsets.all(12),
  child: TextField(
    decoration: InputDecoration(
      hintText: 'Etkinlik ara...',
      prefixIcon: const Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      filled: true,
    ),
    onChanged: (deger) {
      setState(() {
        aramaMetni = deger;
      });
    },
  ),
),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  itemCount: kategoriler.length,
                  itemBuilder: (context, index) {
                    final kategori = kategoriler[index];
                    final secili =
                        seciliKategori == kategori;

                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                      ),
                      child: ChoiceChip(
                        label: Text(kategori),
                        selected: secili,
                        onSelected: (value) {
                          setState(() {
                            seciliKategori = kategori;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: gosterilecekEtkinlikler.isEmpty
    ? Center(
        child: Text(
          seciliSayfa == 1
              ? 'Henüz favori etkinliğin yok.'
              : 'Bu kategoride etkinlik bulunamadı.',
        ),
      )
    : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: gosterilecekEtkinlikler.length,
                  itemBuilder: (context, index) {
                    final etkinlik =
                        gosterilecekEtkinlikler[index];

                    final favorideMi =
                        favoriler.contains(etkinlik.id);

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 16,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Image.network(
                                etkinlik.imageUrl,
                                width: double.infinity,
                                height: 190,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Container(
                                    height: 190,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 45,
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  onPressed: () {
                                    favoriDegistir(
                                      etkinlik.id,
                                    );
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                  ),
                                  icon: Icon(
                                    favorideMi
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EtkinlikDetaySayfasi(
                                    etkinlik: etkinlik,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    etkinlik.category,
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    etkinlik.title,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        tarihFormatla(
                                          etkinlik.startDate,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          etkinlik.location,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Düzenleyen: ${etkinlik.organizer}',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Kontenjan: ${etkinlik.registeredCount}/${etkinlik.capacity}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: seciliSayfa,
        onDestinationSelected: (index) {
          setState(() {
            seciliSayfa = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event),
            label: 'Etkinlikler',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
        ],
      ),
    );
  }
}

class EtkinlikDetaySayfasi extends StatelessWidget {
  final Event etkinlik;

  const EtkinlikDetaySayfasi({
    super.key,
    required this.etkinlik,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlik Detayı'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              etkinlik.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etkinlik.category,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    etkinlik.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  detaySatiri(
                    Icons.calendar_month,
                    'Başlangıç',
                    '${etkinlik.startDate.day}.${etkinlik.startDate.month}.${etkinlik.startDate.year}',
                  ),
                  detaySatiri(
                    Icons.access_time,
                    'Saat',
                    '${etkinlik.startDate.hour.toString().padLeft(2, '0')}:${etkinlik.startDate.minute.toString().padLeft(2, '0')}',
                  ),
                  detaySatiri(
                    Icons.location_on,
                    'Konum',
                    etkinlik.location,
                  ),
                  detaySatiri(
                    Icons.groups,
                    'Düzenleyen',
                    etkinlik.organizer,
                  ),
                  detaySatiri(
                    Icons.event_seat,
                    'Kontenjan',
                    '${etkinlik.registeredCount}/${etkinlik.capacity}',
                  ),
                  detaySatiri(
                    Icons.wifi,
                    'Etkinlik türü',
                    etkinlik.isOnline
                        ? 'Online'
                        : 'Yüz yüze',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Etiketler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: etkinlik.tags.map((etiket) {
                      return Chip(
                        label: Text(etiket),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detaySatiri(
    IconData ikon,
    String baslik,
    String deger,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(deger),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
