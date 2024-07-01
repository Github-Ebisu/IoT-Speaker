import 'package:flutter/material.dart';

import '../../../cloud_functions/realtime_db.dart';
import '../../../models/song.dart';
import '../play_song/play_song.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key, required this.title});

  final String title;

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    _getSongList();
    _resetControl();
  }

  void _resetControl() async {
    await RealTimeDBService().resetControl();
  }

  void _getSongList() {
    RealTimeDBService().getSongsStream().listen((snapshot) {
      if (snapshot != null) {
        setState(() {
          songs = snapshot as List<Song>;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (songs.isEmpty) ? getProgressBar() : getListView();
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          child: Container(
            height: 400,
            color: Colors.grey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Modal Bottom Sheet"),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close Bottom Sheet"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void navigate(Song song, int position) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PlaySong(
                playingSong: song,
                songs: songs,
                position: position,
              )),
    );
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget getListView() {
    return Container(
      color: Colors.black,
      child: ListView.separated(
        itemBuilder: (context, position) {
          return getRow(position);
        },
        separatorBuilder: (context, index) {
          return const Divider(
            color: Colors.white54,
            thickness: 1,
            indent: 24,
            endIndent: 24,
          );
        },
        itemCount: songs.length,
        shrinkWrap: true,
      ),
    );
  }

  Widget getRow(int position) {
    return _SongItemSection(
      parent: this,
      song: songs[position],
      positon: position,
    );
  }
}

class _SongItemSection extends StatelessWidget {
  final _MusicPageState parent;
  final Song song;
  final int positon;

  _SongItemSection({
    required this.parent,
    required this.song,
    required this.positon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 24, right: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/images/itune.png',
            image: song.image,
            width: 48,
            height: 48,
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/itune.png',
                width: 48,
                height: 48,
              );
            },
          ),
        ),
        title: Text(
          song.title,
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w400),
        ),
        subtitle: Text(
          song.artist,
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w400),
        ),
        onTap: () {
          parent.navigate(song, positon);
        },
      ),
    );
  }
}
