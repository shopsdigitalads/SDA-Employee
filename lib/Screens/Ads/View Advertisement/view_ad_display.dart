import 'package:flutter/material.dart';
import 'package:sdaemployee/Services/API/Advertisement/advertisement_api.dart';
import 'package:sdaemployee/Widgets/Appbar.dart';
import 'package:sdaemployee/Widgets/Dialog.dart';
import 'package:sdaemployee/Widgets/Section.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ViewAdDisplay extends StatefulWidget {
  final List<dynamic> address_ids;
  final int ad_id;

  const ViewAdDisplay(
      {required this.ad_id, required this.address_ids, Key? key})
      : super(key: key);

  @override
  State<ViewAdDisplay> createState() => _ViewAdDisplayState();
}

class _ViewAdDisplayState extends State<ViewAdDisplay> {
  Map<String, dynamic> displays = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDisplays();
    });
  }

  Future<void> fetchDisplays() async {
    try {
      DialogClass().showLoadingDialog(context: context, isLoading: true);
      Map<String, dynamic> res = await AdvertisementApi()
          .fetchDisplayOfAds(widget.address_ids, widget.ad_id);
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      if (res['status']) {
        
        setState(() {
          displays = res['displays'] ?? {};
        });
        print(displays);
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Error",
          message: res['message'] ?? "Failed to fetch data.",
        );
      }
    } catch (e) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "Something went wrong.",
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void playVideo(String youtubeUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 300,
            padding: const EdgeInsets.all(8.0),
            child: YoutubePlayerWidget(youtubeUrl: youtubeUrl),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Ad Displays"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : displays.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: displays.entries.length,
                  itemBuilder: (context, index) {
                    final location = displays.entries.elementAt(index).key;
                    final types =
                        displays.entries.elementAt(index).value as Map<String, dynamic>;
                    return buildLocationSection(location, types);
                  },
                )
              : const Center(
                  child: Text(
                    "No displays available.",
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ),
    );
  }

  Widget buildLocationSection(String location, Map<String, dynamic> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Section().buildSectionTitle(location),
        ...types.entries.map((typeEntry) {
          final type = typeEntry.key;
          final displays = typeEntry.value as List<dynamic>;
          return buildDisplayTypeSection(type, displays);
        }).toList(),
        const Divider(height: 30, thickness: 1),
      ],
    );
  }

  Widget buildDisplayTypeSection(String type, List<dynamic> displays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            type,
            style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
        ),
        ...displays.map((display) => buildDisplayCard(display)).toList(),
      ],
    );
  }

  Widget buildDisplayCard(Map<String, dynamic> display) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: const Icon(Icons.smart_display_sharp, color: Colors.orangeAccent),
        title: Text(
          "Display ID: ${display['display_id']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Type: ${display['type']}",
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text("Play Video"),
          onPressed: () {
            playVideo(display['youtube_video_link']);
          },
        ),
      ),
    );
  }
}

class YoutubePlayerWidget extends StatefulWidget {
  final String youtubeUrl;

  const YoutubePlayerWidget({required this.youtubeUrl, Key? key}) : super(key: key);

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;

  return Container(
    width: double.infinity,
    height: screenHeight * 0.3, // 30% of screen height
    child: YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
    ),
  );
}

}
