import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  Client client = Client();
  Account account = Account(client);
  Storage storage = Storage(client);
  Database database = Database(client);

  client
          .setEndpoint(
              'https://localhost/v1') // Make sure your endpoint is accessible from your emulator, use IP if needed
          .setProject('5e63e0a61d9c2') // Your project ID
          .setSelfSigned() // Do not use this in production
      ;

  runApp(MaterialApp(
    home: Playground(
      client: client,
      account: account,
      storage: storage,
      database: database,
    ),
  ));
}

class Playground extends StatefulWidget {
  Playground({this.client, this.account, this.storage, this.database});
  final Client client;
  final Account account;
  final Storage storage;
  final Database database;

  @override
  PlaygroundState createState() => PlaygroundState();
}

class PlaygroundState extends State<Playground> {
  String username = "Loading...";

  @override
  void initState() {
    _getAccount();
    super.initState();
  }

  _getAccount() {
    widget.account.get().then((response) {
      setState(() {
        username = response.data['name'];
      });
    }).catchError((error) {
      print(error);
      setState(() {
        username = 'Anonymous User';
      });
    });
  }

  _uploadFile() {
    FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false)
        .then((response) {
      if (response == null) return;
      final file = response.files.single;
      if (!kIsWeb) {
        final path = file.path;
        MultipartFile.fromFile(path, filename: file.name).then((response) {
          widget.storage.createFile(
              file: response, read: ['*'], write: []).then((response) {
            print(response);
          }).catchError((error) {
            print(error.response);
          });
        }).catchError((error) {
          print(error);
        });
      } else {
        if (file.bytes == null) return;
        final uploadFile =
            MultipartFile.fromBytes(file.bytes, filename: file.name);
        widget.storage.createFile(
            file: uploadFile, read: ['*'], write: ['*']).then((response) {
          print(response);
        }).catchError((error) {
          print(error.response);
        });
      }
    }).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Appwrite + Flutter = ❤️"),
            backgroundColor: Colors.pinkAccent[200]),
        body: Container(
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
          Padding(padding: EdgeInsets.all(20.0)),
          ButtonTheme(
            minWidth: 280.0,
            height: 50.0,
            child: ElevatedButton(
                child: Text("Login with Email",
                    style: TextStyle(color: Colors.black, fontSize: 20.0)),
                style: ElevatedButton.styleFrom(primary: Colors.grey),
                onPressed: () {
                  widget.account
                      .createSession(
                          email: 'user@appwrite.io', password: 'password')
                      .then((value) {
                    print(value);
                    _getAccount();
                  }).catchError((error) {
                    print(error.message);
                  });
                }),
          ),
          Padding(padding: EdgeInsets.all(20.0)),
          ButtonTheme(
            minWidth: 280.0,
            height: 50.0,
            child: RaisedButton(
                child: Text("Create Doc",
                    style: TextStyle(color: Colors.white, fontSize: 20.0)),
                color: Colors.blue,
                onPressed: () {
                  widget.database
                      .createDocument(
                          collectionId: '5f2e3c52f03c0',
                          data: {'username': 'hello2'},
                          read: ['*'],
                          write: ['*'])
                      .then((value) {})
                      .catchError((error) {
                        print(error.response);
                      });
                }),
          ),
          const SizedBox(height: 10.0),
          ButtonTheme(
            minWidth: 280.0,
            height: 50.0,
            child: RaisedButton(
                child: Text("Upload file",
                    style: TextStyle(color: Colors.white, fontSize: 20.0)),
                color: Colors.blue,
                onPressed: () {
                  _uploadFile();
                }),
          ),
          Padding(padding: EdgeInsets.all(20.0)),
          ButtonTheme(
            minWidth: 280.0,
            height: 50.0,
            child: RaisedButton(
                child: Text("Login with Facebook",
                    style: TextStyle(color: Colors.white, fontSize: 20.0)),
                color: Colors.blue,
                onPressed: () {
                  widget.account
                      .createOAuth2Session(provider: 'facebook')
                      .then((value) {
                    widget.account.get().then((response) {
                      setState(() {
                        username = response.data['name'];
                      });
                    }).catchError((error) {
                      setState(() {
                        username = 'Anonymous User';
                      });
                    });
                  });
                }),
          ),
          Padding(padding: EdgeInsets.all(10.0)),
          ButtonTheme(
            minWidth: 280.0,
            height: 50.0,
            child: RaisedButton(
                child: Text("Login with GitHub",
                    style: TextStyle(color: Colors.white, fontSize: 20.0)),
                color: Colors.black87,
                onPressed: () {
                  widget.account
                      .createOAuth2Session(
                          provider: 'github', success: '', failure: '')
                      .then((value) {
                    widget.account.get().then((response) {
                      setState(() {
                        username = response.data['name'];
                      });
                    }).catchError((error) {
                      setState(() {
                        username = 'Anonymous User';
                      });
                    });
                  });
                }),
          ),
          Padding(padding: EdgeInsets.all(10.0)),
          ButtonTheme(
            minWidth: 280.0,
            height: 50.0,
            child: RaisedButton(
                child: Text("Login with Google",
                    style: TextStyle(color: Colors.white, fontSize: 20.0)),
                color: Colors.red,
                onPressed: () {
                  widget.account
                      .createOAuth2Session(provider: 'google')
                      .then((value) {
                    widget.account.get().then((response) {
                      setState(() {
                        username = response.data['name'];
                      });
                    }).catchError((error) {
                      setState(() {
                        username = 'Anonymous User';
                      });
                    });
                  });
                }),
          ),
          Padding(padding: EdgeInsets.all(20.0)),
          Divider(),
          Padding(padding: EdgeInsets.all(20.0)),
          Text(username, style: TextStyle(color: Colors.black, fontSize: 20.0)),
          Padding(padding: EdgeInsets.all(20.0)),
          Divider(),
          Padding(padding: EdgeInsets.all(20.0)),
          ButtonTheme(
            minWidth: 280.0,
            height: 50.0,
            child: RaisedButton(
                child: Text('Logout',
                    style: TextStyle(color: Colors.white, fontSize: 20.0)),
                color: Colors.red[700],
                onPressed: () {
                  widget.account
                      .deleteSession(sessionId: 'current')
                      .then((response) {
                    setState(() {
                      username = 'Anonymous User';
                    });
                  }).catchError((error) {
                    print('error');
                    print(error.response);
                  });
                }),
          ),
          Padding(padding: EdgeInsets.all(20.0)),
        ]))));
  }
}
