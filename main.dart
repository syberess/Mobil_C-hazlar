import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esma Polat Kütüphane Yönetimi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: KitaplarimSayfasi(),
    );
  }
}

class KitaplarimSayfasi extends StatefulWidget {
  @override
  _KitaplarimSayfasiState createState() => _KitaplarimSayfasiState();
}

class _KitaplarimSayfasiState extends State<KitaplarimSayfasi> {
  final CollectionReference kitaplarRef =
      FirebaseFirestore.instance.collection('kitaplar');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kitaplarım'),
      ),
      body: StreamBuilder(
        stream: kitaplarRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          
          var kitaplar = snapshot.data?.docs;

          return ListView.builder(
            itemCount: kitaplar?.length,
            itemBuilder: (context, index) {
              var kitap = kitaplar?[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text(kitap['kitapAdi']),
                subtitle: Text('${kitap['yazarAdi']} - ${kitap['sayfaSayisi']} sayfa'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                KitapEklemeSayfasi(kitapBilgisi: kitap),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _kitapSil(kitaplar?.[index].id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KitapEklemeSayfasi(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _kitapSil(String kitapId) async {
    await kitaplarRef.doc(kitapId).delete();
    setState(() {});
  }
}

class KitapEklemeSayfasi extends StatefulWidget {
  final Map<String, dynamic>? kitapBilgisi;

  KitapEklemeSayfasi({this.kitapBilgisi});

  @override
  _KitapEklemeSayfasiState createState() => _KitapEklemeSayfasiState();
}

class _KitapEklemeSayfasiState extends State<KitapEklemeSayfasi> {
  final TextEditingController _kitapAdiController = TextEditingController();
  final TextEditingController _yayineviController = TextEditingController();
  final TextEditingController _yazarController = TextEditingController();
  final TextEditingController _sayfaSayisiController = TextEditingController();
  final TextEditingController _basimYiliController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();

  bool _listedeYayinlansin = false;

  @override
  void initState() {
    super.initState();

    if (widget.kitapBilgisi != null) {
      _kitapAdiController.text = widget.kitapBilgisi!['kitapAdi'];
      _yayineviController.text = widget.kitapBilgisi!['yayinevi'];
      _yazarController.text = widget.kitapBilgisi!['yazarAdi'];
      _sayfaSayisiController.text = widget.kitapBilgisi!['sayfaSayisi'].toString();
      _basimYiliController.text = widget.kitapBilgisi!['basimYili'].toString();
      _kategoriController.text = widget.kitapBilgisi!['kategori'];
      _listedeYayinlansin = widget.kitapBilgisi!['listedeYayinlansin'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kitap Ekleme'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _kitapAdiController,
              decoration: InputDecoration(labelText: 'Kitap Adı'),
            ),
            TextField(
              controller: _yayineviController,
              decoration: InputDecoration(labelText: 'Yayınevi'),
            ),
            TextField(
              controller: _yazarController,
              decoration: InputDecoration(labelText: 'Yazar/Yazarlar'),
            ),
            TextField(
              controller: _sayfaSayisiController,
              decoration: InputDecoration(labelText: 'Sayfa Sayısı'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _basimYiliController,
              decoration: InputDecoration(labelText: 'Basım Yılı'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _kategoriController,
              decoration: InputDecoration(labelText: 'Kategori'),
            ),
            Row(
              children: [
                Text('Listede Yayınlanacak mı?'),
                Checkbox(
                  value: _listedeYayinlansin,
                  onChanged: (value) {
                    setState(() {
                      _listedeYayinlansin = value!;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _kitapKaydet();
              },
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _kitapKaydet() async {
    Map<String, dynamic> kitapBilgisi = {
      'kitapAdi': _kitapAdiController.text,
      'yayinevi': _yayineviController.text,
      'yazarAdi': _yazarController.text,
      'sayfaSayisi': int.tryParse(_sayfaSayisiController.text) ?? 0,
      'basimYili': int.tryParse(_basimYiliController.text) ?? 0,
      'kategori': _kategoriController.text,
      'listedeYayinlansin': _listedeYayinlansin,
    };

    if (widget.kitapBilgisi != null) {
      await FirebaseFirestore.instance
          .collection('kitaplar')
          .doc(widget.kitapBilgisi!['id'])
          .update(kitapBilgisi);
    } else {
      await FirebaseFirestore.instance.collection('kitaplar').add(kitapBilgisi);
    }

    Navigator.pop(context);
  }
}