import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constant.dart';
import '../services/learning_progress_service.dart';
import '../widgets/page_header.dart';

class ParentReportScreen extends StatefulWidget {
  const ParentReportScreen({Key? key}) : super(key: key);

  @override
  State<ParentReportScreen> createState() => _ParentReportScreenState();
}

class _ParentReportScreenState extends State<ParentReportScreen> {
  final ScrollController _scrollController = ScrollController();
  double _offset = 0;
  late Future<LearningSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = LearningProgressService.loadSummary();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _offset = _scrollController.hasClients ? _scrollController.offset : 0;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _summaryFuture = LearningProgressService.loadSummary();
    });
  }

  String _nextStep(LearningSummary summary) {
    const orderedModules = [
      ('abc', '先继续学 ABC'),
      ('numbers', '下一步学 123'),
      ('colors', '接着学 Colors'),
      ('animals', '然后看看 Animals'),
      ('shapes', '再练 Shapes'),
      ('abc_sounds', '开始学 ABC Sounds'),
      ('phonics', '接着学 Phonics'),
      ('prepositions', '再学方位介词'),
      ('stories', '最后听一听 Stories'),
    ];

    for (final entry in orderedModules) {
      if (!summary.openedModules.contains(entry.$1)) {
        return entry.$2;
      }
    }

    return '可以复习 ABC Sounds 和 Phonics，继续巩固发音。';
  }

  Widget _buildMetricCard(
      String title, String value, String hint, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kBodyTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              height: 1.4,
              color: kBodyTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTile(String title, bool done) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFE8F7EB) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: done ? const Color(0xFF33A852) : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kTitleTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: PageHeader(
                title: 'Parents',
                primaryColor: const Color(0xFF90CAF9),
                secondaryColor: const Color(0xFF5C6BC0),
                offset: _offset,
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<LearningSummary>(
                future: _summaryFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final summary = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF7F9FF), Color(0xFFE8F2FF)],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '家长入口',
                                style: GoogleFonts.notoSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: kTitleTextColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '这里会记录孩子学过哪些模块、看过多少字母视频、拿到了多少奖励星星。',
                                style: GoogleFonts.notoSans(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: kBodyTextColor,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '建议下一步：${_nextStep(summary)}',
                                style: GoogleFonts.notoSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2854C5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.15,
                          children: [
                            _buildMetricCard(
                              '路线进度',
                              '${(summary.routeProgress * 100).round()}%',
                              '基础课程路线完成度',
                              const Color(0xFF5C6BC0),
                            ),
                            _buildMetricCard(
                              '奖励星星',
                              '${summary.starsEarned}',
                              '答对小游戏会累计星星',
                              const Color(0xFFFF8A65),
                            ),
                            _buildMetricCard(
                              '字母视频',
                              '${summary.watchedVideos.length}/26',
                              '已看过多少个磨耳朵视频',
                              const Color(0xFF26A69A),
                            ),
                            _buildMetricCard(
                              '数字练习',
                              '${summary.numbersPracticed}',
                              '点击数字和数量卡片的次数',
                              const Color(0xFF43A047),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildMetricCard(
                          'Stories 和 Shapes',
                          '${summary.storiesPlayed} 次故事 / ${summary.shapesPracticed} 次形状',
                          '可以在这两个模块里反复听、反复看、反复点。',
                          const Color(0xFFEC407A),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '推荐学习路线',
                                style: GoogleFonts.notoSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: kTitleTextColor,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildRouteTile('1. ABC 认识字母',
                                  summary.openedModules.contains('abc')),
                              _buildRouteTile('2. 123 认识数字',
                                  summary.openedModules.contains('numbers')),
                              _buildRouteTile('3. Colors 看颜色',
                                  summary.openedModules.contains('colors')),
                              _buildRouteTile(
                                  '4. Animals / Shapes 看图学词',
                                  summary.openedModules.contains('animals') ||
                                      summary.openedModules.contains('shapes')),
                              _buildRouteTile('5. ABC Sounds 学字母发音',
                                  summary.openedModules.contains('abc_sounds')),
                              _buildRouteTile('6. Phonics 学更细的发音',
                                  summary.openedModules.contains('phonics')),
                              _buildRouteTile(
                                  '7. Where? 学方位介词',
                                  summary.openedModules
                                      .contains('prepositions')),
                              _buildRouteTile('8. Stories 听小故事',
                                  summary.openedModules.contains('stories')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
