
import 'package:flutter/material.dart';
import 'package:note_basket/kategoriler.dart';
import 'package:note_basket/models/notlar.dart';
import 'package:note_basket/utils/database_helper.dart';

import 'models/kategori.dart';
import 'not_detay.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Note Basket",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: NotListesi(),
    );
  }
}

class NotListesi extends StatelessWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text("Not Sepeti"),
        ),
        actions: [
          PopupMenuButton(itemBuilder: (context){
            return [            PopupMenuItem(child:ListTile(leading: Icon(Icons.category),title: Text("Kategoriler"),onTap:()=> _kategoriSayfasi(context),) ,)
            ];
          })
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              kategoriEkleDialog(context);
            },
            heroTag: "KategoriEkle",
            tooltip: "Kategori EKle",
            child: Icon(Icons.category_outlined),
            mini: true,
          ),
          FloatingActionButton(
            onPressed: () {
              detaysSayfasinaGit(context);
            },
            heroTag: "NotEkle",
            tooltip: "Not Ekle",
            child: Icon(Icons.note_add_sharp),
          ),
        ],
      ),
      body: Notlar(),
    );
  }

  void kategoriEkleDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String yeniKategoriAdi;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Ekle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: [
              Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onSaved: (yeniDeger) {
                        yeniKategoriAdi = yeniDeger;
                      },
                      decoration: InputDecoration(
                          labelText: "Kategori Adı",
                          border: OutlineInputBorder()),
                      validator: (girilenKategoriAdi) {
                        if (girilenKategoriAdi.length < 3) {
                          return "En az 3 karakter giriniz.";
                        } else {
                          return null;
                        }
                      },
                    ),
                  )),
              ButtonBar(
                children: [
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.deepPurpleAccent,
                    child: Text(
                      "Vazgeç",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        databaseHelper
                            .kategorliEkle(Kategori(yeniKategoriAdi))
                            .then((kategoriID) {
                          if (kategoriID > 0) {
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text("Kategori Eklendi"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    color: Colors.deepPurpleAccent,
                    child: Text(
                      "Keydet",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  void detaysSayfasinaGit(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => NotDetay(baslik: "Yeni Not")));
  }

  _kategoriSayfasi(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) =>Kategoriler()));
  }


}

class Notlar extends StatefulWidget {
  @override
  _NotlarState createState() => _NotlarState();
}

class _NotlarState extends State<Notlar> {
  List<Not> tumNotlar;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumNotlar = List<Not>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: databaseHelper.notListesiniGetir(),
        builder: (context, AsyncSnapshot<List<Not>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            tumNotlar = snapshot.data;
            return ListView.builder(
                itemCount: tumNotlar.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(leading: _oncelikIconuAta(tumNotlar[index].notOncelik),
                    backgroundColor: Colors.white10,title: Text(tumNotlar[index].notBaslik,style: TextStyle(fontSize: 20),),
                  children: [
                    Container(padding: EdgeInsets.all(5),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(padding: const EdgeInsets.all(8.0),child: Text("Kategori : ",style: TextStyle(color: Colors.black54,fontSize: 20),),),
                            Padding(padding: const EdgeInsets.all(8.0),child: Text(tumNotlar[index].kategoriBaslik,style: TextStyle(color: Colors.black,fontSize: 20),),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(padding: const EdgeInsets.all(8.0),child: Text("Oluşturulma Tarihi : ",style: TextStyle(color: Colors.black54,fontSize: 20),),),
                            Padding(padding: const EdgeInsets.all(8.0),child: Text(databaseHelper.dateFormat(DateTime.parse(tumNotlar[index].notTarih)),style: TextStyle(color: Colors.black,fontSize: 20),),),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("İçerik : \n "+tumNotlar[index].notIcerik,style: TextStyle(fontSize: 20),),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          children: [
                            FlatButton(onPressed: () => _notSil(tumNotlar[index].notID), child: Text("SİL"),color: Colors.red,),
                            FlatButton(onPressed: () =>detaysSayfasinaGit(context, tumNotlar[index]), child: Text("Güncelle"),color: Colors.green,),
                          ],
                        )

                      ],),
                    )
                  ],);
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }


  void detaysSayfasinaGit(BuildContext context, Not not) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => NotDetay(baslik: "Notu Düzenle", duzenlenecekNot:not)));
  }
  _oncelikIconuAta(int notOncelik) {
    switch(notOncelik){

      case 0:
        return CircleAvatar(child: Text("AZ",style: TextStyle(color: Colors.white),),backgroundColor: Colors.red.shade200,);
        break;
      case 1:
        return CircleAvatar(child: Text("ORTA",style: TextStyle(color: Colors.white),),backgroundColor: Colors.red.shade600,);
        break;
      case 2:
        return CircleAvatar(child: Text("ACİL",style: TextStyle(color: Colors.white),),backgroundColor: Colors.red.shade900,);
        break;
    }
  }

  _notSil(int notID) {
    databaseHelper.notSil(notID).then((silinenID){
      if(silinenID !=0){
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Not Silindi....")));
        setState(() {

        });
      }
    });
  }
}
