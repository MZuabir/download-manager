import 'dart:io';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/files.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:pspdfkit_flutter/widgets/pspdfkit_widget.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(
  //     );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double progress = 0;
  bool downloaded = false;
  bool videoDownloading = false;
  var storageDir;
  bool open = false;
  bool downloading = false;

  // final ReceivePort _receivePort = ReceivePort();

  // static downloadingCallback(id, status, progress) {
  //   ///Looking up for a send port
  //   SendPort? sendPort = IsolateNameServer.lookupPortByName("downloading");

  //   ///ssending the data
  //   sendPort?.send([id, status, progress]);
  // }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();

  //   ///register a send port for the other isolates
  //   IsolateNameServer.registerPortWithName(
  //       _receivePort.sendPort, "downloading");

  //   ///Listening for the data is comming other isolataes
  //   _receivePort.listen((message) {
  //     setState(() {
  //       progress = message[2];
  //     });

  //     print(progress);
  //   });

  //   FlutterDownloader.registerCallback(downloadingCallback);
  final String pdfUrl =
      'https://pdfseva.com/wp-content/uploads/2023/07/Atomic-Habits-old.pdf'; //
  String progressString =
      'File is not downloaded yet'; //https://pspdfkit.com/downloads/pspdfkit-flutter-quickstart-guide.pdf
  final String album = 'My album';
  bool didDownload = false;

  Future DownloadFile(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: updateProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      var file = File(savePath).openSync(mode: FileMode.write);
      file.writeFromSync(response.data);
      await file.close();
    } catch (e) {
      print(e.toString());
    }
  }

  void updateProgress(done, total) {
    progress = done / total;
    setState(() {
      if (progress >= 1) {
        progressString = 'file has finished downloading. You can open file';
        didDownload = true;
      } else {
        progressString =
            'Download progress ${(progress * 100).toStringAsFixed(0)}% done';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloader"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   "$progress",
            //   style: const TextStyle(fontSize: 40),
            // ),
            Text(
              progressString,
            ),
            const SizedBox(
              height: 60,
            ),
            downloaded == false
                ? ElevatedButton(
                    child: const Text("Image download"),
                    onPressed: () async {
                      // final status = await Permission.storage.request();

                      // if (status.isGranted) {
                      //   final externalDir = await getExternalStorageDirectory();
                      //   print('this is directory ${externalDir!.path}');
                      //   final id = await FlutterDownloader.enqueue(
                      //     url:
                      //         "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg",
                      //     savedDir: externalDir.path,
                      //     fileName: "download",
                      //     showNotification: true,
                      //     openFileFromNotification: true,
                      //   ).then((value) =>
                      //       {print('downloaded file directory ${externalDir.path}')});
                      // } else {
                      //   print("Permission deined");
                      // }
                      // setState(() {
                      //   downloaded = true;
                      // });
                      // await GallerySaver.saveImage(
                      //         'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg',
                      //         albumName: album)
                      //     .then((value) {
                      //   setState(() {
                      //     downloaded = false;
                      //   });
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(content: Text('Photo downloaded')));
                      // });
                      storeInDcim(
                              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg',
                              'myPic.jpg')
                          .then((value) {
                        print('OK');
                      });
                    },
                  )
                : const CircularProgressIndicator(
                    backgroundColor: Colors.orange),
            videoDownloading == false
                ? ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        videoDownloading = true;
                      });
                      // await GallerySaver.saveVideo(
                      //         'https://assets.mixkit.co/videos/preview/mixkit-going-down-a-curved-highway-through-a-mountain-range-41576-large.mp4',
                      //         albumName: 'Flutter movies')
                      //     .then((value) {
                      //   setState(() {
                      //     videoDownloading = false;
                      //   });
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(content: Text('Video downloaded')));
                      // });
                      storeInMovies(
                              'https://assets.mixkit.co/videos/preview/mixkit-going-down-a-curved-highway-through-a-mountain-range-41576-large.mp4',
                              'myVideo.mp4')
                          .then((value) {
                        setState(() {
                          videoDownloading = false;
                        });
                      });
                    },
                    child: const Text('Video download'))
                : const CircularProgressIndicator(
                    color: Colors.orange,
                  ),
            ElevatedButton(
                onPressed: didDownload
                    ? null
                    : () async {
                        Dio dio = Dio();
                        storageDir = await getExternalStorageDirectory();
                        print(storageDir.toString());
                        DownloadFile(dio, pdfUrl, '${storageDir.path}/myPdf');
                      },
                child: const Text('PDF download')),
            ElevatedButton(
              onPressed: !didDownload
                  ? null
                  : () async {
                      var tempDir = await getExternalStorageDirectory();
                      if (didDownload && tempDir != null) {
                        print('${tempDir.path}/myPdf');
                        Pspdfkit.present(
                          '${tempDir.path}/myPdf',
                        ).then((value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PDFView(dir: tempDir.path)));
                        });
                      } else {
                        print('File not found');
                      }
                    },
              child: const Text('Open pdf'),
            ),
            downloading == false
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        downloading = true;
                      });
                      downloadFile(
                              'https://pdfseva.com/wp-content/uploads/2023/07/Atomic-Habits-old.pdf',
                              'myAtomicHab.pdf')
                          .then((value) {
                        setState(() {
                          downloading = false;
                        });
                      });
                    },
                    child: const Text('PDF'))
                : const CircularProgressIndicator(
                    color: Colors.orange,
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> storeInMovies(String url, String filename) async {
    String fileUrl = url;
    String fileName = filename;

    try {
      if (await Permission.storage.request().isGranted) {
        Directory? dcimDir = await getExternalStorageDirectory();

        String newPath = '';
        List<String> folders = dcimDir!.path.split('/');
        for (int x = 1; x < folders.length; x++) {
          String folder = folders[x];
          if (folder != 'Android') {
            newPath += '/' + folder;
          } else {
            break;
          }
        }
        newPath = newPath + '/Movies';
        dcimDir = Directory(newPath);
        if (dcimDir != null) {
          String savePath = '${dcimDir.path}/$fileName';

          final response = await http.get(Uri.parse(fileUrl));

          if (response.statusCode == 200) {
            File file = File(savePath);
            await file.writeAsBytes(response.bodyBytes);
            print('File downloaded successfully and saved at $savePath.');
            Fluttertoast.showToast(msg: 'File downloaded successfully');
          } else {
            print(
                'Failed to download file. Status code: ${response.statusCode}');
            Fluttertoast.showToast(msg: 'Failed to download');
          }
        } else {
          print('Could not access the external storage on the device.');
          Fluttertoast.showToast(
              msg: 'Could not access the external storage on the device.');
        }
      } else {
        print('Permission to access storage was denied.');
        Fluttertoast.showToast(msg: 'Permission to access storage was denied.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> storeInDocuments(String url, String filename) async {
    String fileUrl = url;
    String fileName = filename;

    try {
      if (await Permission.storage.request().isGranted) {
        Directory? dcimDir = await getExternalStorageDirectory();

        String newPath = '';
        List<String> folders = dcimDir!.path.split('/');
        for (int x = 1; x < folders.length; x++) {
          String folder = folders[x];
          if (folder != 'Android') {
            newPath += '/' + folder;
          } else {
            break;
          }
        }
        newPath = newPath + '/Documents';
        dcimDir = Directory(newPath);
        if (dcimDir != null) {
          String savePath = '${dcimDir.path}/$fileName';

          final response = await http.get(Uri.parse(fileUrl));

          if (response.statusCode == 200) {
            File file = File(savePath);
            await file.writeAsBytes(response.bodyBytes);
            print('File downloaded successfully and saved at $savePath.');
            Fluttertoast.showToast(msg: 'File downloaded successfully');
          } else {
            print(
                'Failed to download file. Status code: ${response.statusCode}');
            Fluttertoast.showToast(msg: 'Failed to download');
          }
        } else {
          print('Could not access the external storage on the device.');
          Fluttertoast.showToast(
              msg: 'Could not access the external storage on the device.');
        }
      } else {
        print('Permission to access storage was denied.');
        Fluttertoast.showToast(msg: 'Permission to access storage was denied.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> storeInDcim(String url, String filename) async {
    String fileUrl = url;
    String fileName = filename;

    try {
      if (await Permission.storage.request().isGranted) {
        Directory? dcimDir = await getExternalStorageDirectory();

        String newPath = '';
        List<String> folders = dcimDir!.path.split('/');
        for (int x = 1; x < folders.length; x++) {
          String folder = folders[x];
          if (folder != 'Android') {
            newPath += '/' + folder;
          } else {
            break;
          }
        }
        newPath = newPath + '/DCIM';
        dcimDir = Directory(newPath);
        if (dcimDir != null) {
          String savePath = '${dcimDir.path}/$fileName';

          final response = await http.get(Uri.parse(fileUrl));

          if (response.statusCode == 200) {
            File file = File(savePath);
            await file.writeAsBytes(response.bodyBytes);
            print('File downloaded successfully and saved at $savePath.');
            Fluttertoast.showToast(msg: 'File downloaded successfully');
          } else {
            print(
                'Failed to download file. Status code: ${response.statusCode}');
            Fluttertoast.showToast(msg: 'Failed to download');
          }
        } else {
          print('Could not access the external storage on the device.');
          Fluttertoast.showToast(
              msg: 'Could not access the external storage on the device.');
        }
      } else {
        print('Permission to access storage was denied.');
        Fluttertoast.showToast(msg: 'Permission to access storage was denied.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> downloadFile(String url, String filename) async {
    String fileUrl = url;
    String fileName = filename;

    try {
      if (await Permission.storage.request().isGranted) {
        // Directory? externalDir = await getExternalStorageDirectory();

        // if (externalDir != null) {
        //   String downloadsDir = '${externalDir.path}/Download';
        //   Directory(downloadsDir).createSync(recursive: true);

        //   String savePath = '$downloadsDir/$fileName';

        //
        Directory? tempDir = await DownloadsPathProvider.downloadsDirectory;
        if (tempDir != null) {
          String tempPath = tempDir.path;
          var filePath = '$tempPath/$filename';

          final response = await http.get(Uri.parse(fileUrl));

          if (response.statusCode == 200) {
            File file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            print('File downloaded successfully and saved at $filePath.');
            Fluttertoast.showToast(msg: 'File downloaded successfully');
          } else {
            print(
                'Failed to download file. Status code: ${response.statusCode}');
            Fluttertoast.showToast(msg: 'Filed to download');
          }
        } else {
          print('Could not access the external storage on the device.');
          Fluttertoast.showToast(
              msg: 'Could not access the external storage on the device.');
        }
      } else {
        print('Permission to access storage was denied.');
        Fluttertoast.showToast(msg: 'Permission to access storage was denied.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> requestPermissionsAndDownload() async {
    var statusStorage = await Permission.storage.request();

    if (statusStorage.isGranted) {
      String fileUrl =
          'https://assets.mixkit.co/videos/preview/mixkit-going-down-a-curved-highway-through-a-mountain-range-41576-large.mp4'; // Replace with the actual URL
      String fileName = 'myFile';
      await downloadFile(fileUrl, fileName);
    } else {
      print('Permissions not granted. Unable to download file.');
    }
  }
}

class PDFView extends StatefulWidget {
  const PDFView({
    super.key,
    required this.dir,
  });
  final String dir;

  @override
  State<PDFView> createState() => _PDFViewState();
}

class _PDFViewState extends State<PDFView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF'),
      ),
      body: PspdfkitWidget(
        documentPath: widget.dir,
      ),
    );
  }
}







// import 'dart:io';
// import 'dart:isolate';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Downloader Demo'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   ReceivePort receivePort = ReceivePort();
//   int progress = 0;
//   @override
//   void initState() {
//     super.initState();
//     FlutterDownloader.registerCallback(downloadCallback);
//   }

//   void downloadCallback(String id, int status, int progress) {
//     // Handle the download progress update here
//     // You can update the UI with the new progress value
//     setState(() {
//       this.progress = progress;
//     });
//   }

//   final urlList = [
//     'https://images.pexels.com/photos/1563355/pexels-photo-1563355.jpeg?cs=srgb&dl=pexels-craig-adderley-1563355.jpg&fm=jpg',
//     'https://images.pexels.com/photos/1212693/pexels-photo-1212693.jpeg?cs=srgb&dl=pexels-katie-burandt-1212693.jpg&fm=jpg',
//     'https://cdn.pixabay.com/photo/2015/06/22/08/37/children-817365_640.jpg',
//     'https://images.pexels.com/photos/1563355/pexels-photo-1563355.jpeg?cs=srgb&dl=pexels-craig-adderley-1563355.jpg&fm=jpg',
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text('Flutter Downloader'),
//       ),
//       body: Container(child: Text('Progress')),
//       floatingActionButton: FloatingActionButton.extended(
//           onPressed: () async {
//             try {
//               final status = await Permission.storage.request();
//               if (status.isGranted) {
//                 final externalDir = await getExternalStorageDirectory();
//                 print('this is external path ${externalDir?.path}');
//                 final id = await FlutterDownloader.enqueue(
//                   url:
//                       'https://images.pexels.com/photos/1563355/pexels-photo-1563355.jpeg?cs=srgb&dl=pexels-craig-adderley-1563355.jpg&fm=jpg',
//                   savedDir: externalDir!.path,
//                   fileName: 'Download',
//                   showNotification: true,
//                   openFileFromNotification: true,
//                 );
//               }
//             } catch (e, stacktrace) {
//               print('Error during download: $e');
//               print('Stacktrace: $stacktrace');
//             }
//           },
//           label: const Text('Download Screen')),
//     );
//   }
// }




// // Future<void> requestDownload(String url, String fileName) async {
//   //   final dir = await getApplicationDocumentsDirectory();
//   //   var localPath = '${dir.path}/$fileName';
//   //   var savedDir = Directory(localPath); // Use Directory instead of File

//   //   // Check if the directory exists, if not, create it.
//   //   if (!await savedDir.exists()) {
//   //     await savedDir.create(recursive: true);
//   //   }

//   //   String? taskId = await FlutterDownloader.enqueue(
//   //     url: url,
//   //     fileName: fileName,
//   //     savedDir: savedDir.path,
//   //     showNotification: true,
//   //     openFileFromNotification: true,
//   //   );

//   //   print(taskId);
//   // }