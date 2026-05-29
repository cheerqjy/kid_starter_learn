import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/vocabulary_item.dart';
import '../widgets/page_header.dart';
import '../widgets/vocabulary_card.dart';

class VocabularyScreen extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final List<VocabularyItem> items;

  const VocabularyScreen({
    Key? key,
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
    required this.items,
  }) : super(key: key);

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final _scrollController = ScrollController();
  final _tts = FlutterTts();
  double offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.38);
    await _tts.setPitch(1.0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      offset = _scrollController.hasClients ? _scrollController.offset : 0;
    });
  }

  Future<void> _speak(String text) async {
    HapticFeedback.selectionClick();
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PageHeader(
              title: widget.title,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
              offset: offset,
              onTap: () => _speak(widget.title),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = widget.items[index];
                  return VocabularyCard(
                    item: item,
                    onTap: () => _speak(item.title),
                  );
                },
                childCount: widget.items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
