import 'package:flutter/material.dart';
import 'package:maki/common/custom_appbar.dart';
import 'package:maki/details_page/shelf.dart';
import 'package:maki/details_page/youtube_embedded.dart';
import 'package:maki/models/anime_character.dart';
import 'package:maki/models/anime_details.dart';
import 'package:maki/models/anime_relation.dart';

import 'cover_info.dart';

// use a steteful page because we may load anime data later than the actual page so a refresh may be needed
class AnimeDetailsPage extends StatefulWidget {
  AnimeDetails? animeData;

  int? anilistID;

  AnimeDetailsPage({Key? key, required this.anilistID}) : super(key: key);

  AnimeDetailsPage.fromPrefetchedAnime({Key? key, required this.animeData}) : super(key: key);


  _onDetailsFetched(AnimeDetails anime) {
    animeData = anime;
  }

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

// state item
class _AnimeDetailsPageState extends State<AnimeDetailsPage> {

  void _onRelatedAnimePressed(dynamic anime) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AnimeDetailsPage(anilistID: (anime as AnimeRelation).anilistID,))
    );
  }

  Widget _loadedPageLayout() {
    const elementPadding = 20.0;

    List<Widget> pageElements = [CoverInfo(anime: widget.animeData as AnimeDetails)]; // top info are guaranteed to be present


    if(widget.animeData?.trailerUrl != null) {
      pageElements.add(const SizedBox(height: elementPadding));
      pageElements.add(ClipRRect(borderRadius: BorderRadius.circular(10.0), child: YoutubeEmbedded(url: widget.animeData?.trailerUrl ?? "")));
    }


    if(widget.animeData?.relations != null && (widget.animeData?.relations as List<AnimeRelation>).isNotEmpty) {
      var relations = widget.animeData?.relations as List<AnimeRelation>;

      pageElements.add(const SizedBox(height: elementPadding));
      pageElements.add(Shelf(items: relations, title: "Relations", onItemPressed: _onRelatedAnimePressed));
    }

    if(widget.animeData?.characters != null && (widget.animeData?.characters as List<AnimeCharacter>).isNotEmpty) {
      var characters = widget.animeData?.characters as List<AnimeCharacter>;

      pageElements.add(const SizedBox(height: elementPadding));
      pageElements.add(Shelf(items: characters, title: "Characters"));
    }

    if(widget.animeData?.altTitle != null) {
      pageElements.add(const SizedBox(height: elementPadding));
      pageElements.add(Text("Alternative Title\n${widget.animeData?.altTitle}"));
    }

    if(widget.animeData?.studio != null && widget.animeData?.studio != "Unknown Studio") {
      pageElements.add(const SizedBox(height: elementPadding));
      pageElements.add(Text("Studio\n${widget.animeData?.studio}"));
    }

    if(widget.animeData?.airStartDate != null && widget.animeData?.airFinalDate != null) {
      pageElements.add(const SizedBox(height: elementPadding));
      pageElements.add(Text("Air Period\nFrom ${widget.animeData?.airStartDate} to ${widget.animeData?.airFinalDate}"));
    }

    return ListView(
      padding: const EdgeInsets.all(10.0),
      children: pageElements,
    );
  }

  Widget _loadFromRemoteLayout() {
    return FutureBuilder<AnimeDetails>(
        future: fetchAnimeDetails(widget.anilistID as int),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            widget._onDetailsFetched(snapshot.data as AnimeDetails);
            return _loadedPageLayout();

          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {

      return WillPopScope(
        onWillPop: () async {
          return Navigator.canPop(context);
        },
        child: Scaffold(
            appBar: const CustomAppBar(
              showBackButton: true,
            ),
            body: widget.animeData != null ? _loadedPageLayout() : _loadFromRemoteLayout(),
        ),
      );
  }
}
