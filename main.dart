import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      title: 'Flutter Demo',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  bool audioPlayed = false;
  String audioAsset = "audio/blackswan.mp3";
  String albumAsset = "assets/images/audioimg.jpeg";
  int maxduration = 100;
  int currentpos = 0;
  String currentpostlabel = "00:00";
  late Uint8List audiobytes;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      ByteData bytes =
          await rootBundle.load(audioAsset); //load audio from assets
      audiobytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      //convert ByteData to Uint8List

      player.onDurationChanged.listen((Duration d) {
        //get the duration of audio
        maxduration = d.inMilliseconds;
        setState(() {});
      });

      player.onPositionChanged.listen((Duration p) {
        currentpos = p.inMilliseconds;

        //generating the duration label
        int shours = Duration(milliseconds: currentpos).inHours;
        int sminutes = Duration(milliseconds: currentpos).inMinutes;
        int sseconds = Duration(milliseconds: currentpos).inSeconds;

        int rhours = shours;
        int rminutes = sminutes - (shours * 60);
        int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

        currentpostlabel = "$rhours:$rminutes:$rseconds";

        setState(() {
          //refresh the UI
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      body: Center(
        child: Column(
          children: [
            Image.asset(
              albumAsset,
              height: 350,
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Black Swan (BTS)',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),
            Slider(
              value: double.parse(currentpos.toString()),
              min: 0,
              max: double.parse(maxduration.toString()),
              divisions: maxduration,
              label: currentpostlabel,
              onChanged: (double value) async {
                int seekval = value.round();
                Future<void> result =
                    player.seek(Duration(milliseconds: seekval));
                if (result == 1) {
                  currentpos = seekval;
                } else {
                  print("Seek Unsuccessful");
                }
              },
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (!isPlaying && !audioPlayed) {
                  await player.play(AssetSource(audioAsset));
                  setState(() {
                    isPlaying = true;
                    audioPlayed = true;
                  });
                } else if (audioPlayed && !isPlaying) {
                  await player.resume();
                  setState(() {
                    isPlaying = true;
                    audioPlayed = true;
                  });
                } else {
                  await player.pause();
                  setState(() {
                    isPlaying = false;
                  });
                }
              },
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(isPlaying ? "Pause" : "Play"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await player.stop();
                setState(() {
                  isPlaying = false;
                  audioPlayed = false;
                });
              },
              icon: const Icon(Icons.stop),
              label: const Text("Stop"),
            ),
          ],
        ),
      ),
    );
  }
}
