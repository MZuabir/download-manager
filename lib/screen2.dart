// import 'dart:ffi';
// import 'dart:isolate';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';

// class Screen2 extends StatefulWidget {
//   const Screen2({super.key});

//   @override
//   State<Screen2> createState() => _Screen2State();
// }

// class _Screen2State extends State<Screen2> {
//   final ReceivePort _port = ReceivePort();
//   List<Map> downloadList = [];
//   @override
//   void initState() {
//     task();
//     _bindBackgroundIsolate();
//     FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _unbindBackgroundIsolate();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text('Downloads'),
//       ),
//       body: downloadList.isEmpty
//           ? const Center(
//               child: Text('No Downloads'),
//             )
//           : ListView.builder(
//               itemCount: downloadList.length,
//               itemBuilder: (context, index) {
//                 Map map = downloadList[index];
//                 String fileName = map['filename'];
//                 String progress = map['progress'];
//                 DownloadTaskStatus downloadTaskStatus = map['status'];
//                 String id = map['id'];
//                 String savedDir = map['savedDirectory'];
//                 return Card(
//                   elevation: 10,
//                   child: Column(
//                     children: [
//                       ListTile(
//                         isThreeLine: false,
//                         title: Text(fileName),
//                         subtitle: Text(downloadTaskStatus.toString()),
//                         trailing: SizedBox(
//                           width: 60,
//                           child: buttons(downloadTaskStatus, id, index),
//                         ),
//                       ),
//                       downloadTaskStatus == DownloadTaskStatus.complete
//                           ? Container()
//                           : const SizedBox(
//                               height: 5,
//                             ),
//                       downloadTaskStatus == DownloadTaskStatus.complete
//                           ? Container()
//                           : Padding(
//                               padding: const EdgeInsets.all(10),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text('$progress%'),
//                                   Row(
//                                     children: [
//                                       LinearProgressIndicator(
//                                           value: int.parse(progress) / 100)
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             )
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//   Widget downloadStatusWidget(DownloadTaskStatus downloadTaskStatus) {
//     return downloadTaskStatus == DownloadTaskStatus.canceled
//         ? const Text('Download canceled')
//         : downloadTaskStatus == DownloadTaskStatus.complete
//             ? const Text('Download completed')
//             : downloadTaskStatus == DownloadTaskStatus.failed
//                 ? const Text('Download failed')
//                 : downloadTaskStatus == DownloadTaskStatus.paused
//                     ? const Text('Download paused')
//                     : downloadTaskStatus == DownloadTaskStatus.running
//                         ? const Text('Downloading..')
//                         : const Text('Download waiting');
//   }

//   Future task() async {
//     List<DownloadTask>? getTasks = await FlutterDownloader.loadTasks();
//     getTasks!.forEach((element) {
//       Map map = Map();
//       map['status'] = element.status;
//       map['progress'] = element.progress;
//       map['id'] = element.taskId;
//       map['filename'] = element.filename;
//       map['savedDirectory'] = element.savedDir;
//       downloadList.add(map);
//     });
//     setState(() {});
//   }

//   Widget buttons(DownloadTaskStatus _status, String taskid, int index) {
//     void changeTaskID(String taskid, String newTaskID) {
//       Map? task = downloadList.firstWhere(
//         (element) => element['taskId'] == taskid,
//         orElse: () => {},
//       );
//       task['taskId'] = newTaskID;
//       setState(() {});
//     }

//     return _status == DownloadTaskStatus.canceled
//         ? GestureDetector(
//             child: const Icon(Icons.cached, size: 20, color: Colors.green),
//             onTap: () {
//               FlutterDownloader.retry(taskId: taskid).then((newTaskID) {
//                 changeTaskID(taskid, newTaskID!);
//               });
//             },
//           )
//         : _status == DownloadTaskStatus.failed
//             ? GestureDetector(
//                 child: const Icon(Icons.cached, size: 20, color: Colors.green),
//                 onTap: () {
//                   FlutterDownloader.retry(taskId: taskid).then((newTaskID) {
//                     changeTaskID(taskid, newTaskID!);
//                   });
//                 },
//               )
//             : _status == DownloadTaskStatus.paused
//                 ? Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       GestureDetector(
//                         child: const Icon(Icons.play_arrow,
//                             size: 20, color: Colors.blue),
//                         onTap: () {
//                           FlutterDownloader.resume(taskId: taskid).then(
//                             (newTaskID) => changeTaskID(taskid, newTaskID!),
//                           );
//                         },
//                       ),
//                       GestureDetector(
//                         child: const Icon(Icons.close,
//                             size: 20, color: Colors.red),
//                         onTap: () {
//                           FlutterDownloader.cancel(taskId: taskid);
//                         },
//                       )
//                     ],
//                   )
//                 : _status == DownloadTaskStatus.running
//                     ? Row(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           GestureDetector(
//                             child: const Icon(Icons.pause,
//                                 size: 20, color: Colors.green),
//                             onTap: () {
//                               FlutterDownloader.pause(taskId: taskid);
//                             },
//                           ),
//                           GestureDetector(
//                             child: const Icon(Icons.close,
//                                 size: 20, color: Colors.red),
//                             onTap: () {
//                               FlutterDownloader.cancel(taskId: taskid);
//                             },
//                           )
//                         ],
//                       )
//                     : _status == DownloadTaskStatus.complete
//                         ? GestureDetector(
//                             child: const Icon(Icons.delete,
//                                 size: 20, color: Colors.red),
//                             onTap: () {
//                               downloadList.removeAt(index);
//                               FlutterDownloader.remove(
//                                   taskId: taskid, shouldDeleteContent: true);
//                               setState(() {});
//                             },
//                           )
//                         : Container();
//   }

//   void _bindBackgroundIsolate() {
//     bool isSuccess = IsolateNameServer.registerPortWithName(
//         _port.sendPort, 'downloader_send_port');
//     if (!isSuccess) {
//       _unbindBackgroundIsolate();
//       _bindBackgroundIsolate();
//       return;
//     }
//     _port.listen((dynamic data) {
//       String id = data[0];
//       DownloadTaskStatus status = data[1];
//       int progress = data[2];
//       var task = downloadList.where((element) => element['id'] == id);
//       task.forEach((element) {
//         element['progress'] = progress;
//         element['status'] = status;
//         setState(() {});
//       });
//     });
//   }

//   static void downloadCallback(
//       String id, DownloadTaskStatus status, int progress) {
//     final SendPort? send =
//         IsolateNameServer.lookupPortByName('downloader_send_port');
//     send?.send([id, status, progress]);
//   }

//   void _unbindBackgroundIsolate() {
//     IsolateNameServer.removePortNameMapping('downloader_send_port');
//   }
// }
