import 'package:flutter/material.dart';
import 'package:kid_starter/app/screens/animal_screen.dart';
import 'package:kid_starter/app/screens/birds_screen.dart';

import '../controllers/vocabulary_modules.dart';
import '../models/vocabulary_item.dart';
import '../services/learning_progress_service.dart';
import '../widgets/category_card.dart';
import 'alphabet_en_screen.dart';
import 'color_screen.dart';
import 'letter_sounds_screen.dart';
import 'numeric_en_screen.dart';
import 'parent_report_screen.dart';
import 'phonics_screen.dart';
import 'prepositions_screen.dart';
import 'shape_screen.dart';
import 'story_screen.dart';
import 'vocabulary_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  CategoryCard _buildModuleCard(VocabularyModule module, String moduleId) {
    return CategoryCard(
      title: module.homeTitle,
      primaryColor: module.primaryColor,
      secondaryColor: module.secondaryColor,
      fontSize: module.homeFontSize,
      maxLines: module.homeMaxLines,
      letterSpacing: module.homeLetterSpacing,
      onOpen: () => LearningProgressService.markModuleOpened(moduleId),
      screen: VocabularyScreen(
        title: module.screenTitle,
        primaryColor: module.primaryColor,
        secondaryColor: module.secondaryColor,
        items: module.items,
      ),
    );
  }

  Widget _buildPathCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7D1), Color(0xFFE6F2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Path',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF303030),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '先学最简单的看图认知，再进入字母发音、音标和介词。这样更符合小朋友的理解顺序。',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF4B4B4B),
            ),
          ),
          SizedBox(height: 14),
          Text(
            '1. ABC  2. 123  3. Colors  4. Animals / Shapes  5. ABC Sounds  6. Phonics  7. Where?  8. Stories',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2854C5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> categories = [
      _buildPathCard(),
      CategoryCard(
        title: 'ABC',
        primaryColor: Colors.purpleAccent[100]!,
        secondaryColor: Colors.purple,
        onOpen: () => LearningProgressService.markModuleOpened('abc'),
        screen: AlphabetEnScreen(
          title: 'ABC',
          primaryColor: Colors.purpleAccent[100]!,
          secondaryColor: Colors.purple,
        ),
      ),
      CategoryCard(
        title: '123',
        primaryColor: Colors.greenAccent[100]!,
        secondaryColor: Colors.green,
        onOpen: () => LearningProgressService.markModuleOpened('numbers'),
        screen: NumericEnScreen(
          title: '123',
          primaryColor: Colors.greenAccent[100]!,
          secondaryColor: Colors.green,
        ),
      ),
      CategoryCard(
        title: 'Colors',
        primaryColor: Colors.orangeAccent[100]!,
        secondaryColor: Colors.orange,
        onOpen: () => LearningProgressService.markModuleOpened('colors'),
        screen: ColorScreen(
          title: 'Colors',
          primaryColor: Colors.orangeAccent[100]!,
          secondaryColor: Colors.orange,
        ),
      ),
      CategoryCard(
        title: 'Animals',
        primaryColor: Colors.purpleAccent[100]!,
        secondaryColor: Colors.purple,
        onOpen: () => LearningProgressService.markModuleOpened('animals'),
        screen: AnimalScreen(
          title: 'Animals',
          primaryColor: Colors.purpleAccent[100]!,
          secondaryColor: Colors.purple,
        ),
      ),
      CategoryCard(
        title: 'Shapes',
        primaryColor: Colors.redAccent[100]!,
        secondaryColor: Colors.red,
        onOpen: () => LearningProgressService.markModuleOpened('shapes'),
        screen: ShapesScreen(
          title: 'Shapes',
          primaryColor: Colors.redAccent[100]!,
          secondaryColor: Colors.red,
        ),
      ),
      CategoryCard(
        title: 'ABC\nSounds',
        primaryColor: const Color(0xFFFFCC80),
        secondaryColor: const Color(0xFFFF8A65),
        fontSize: 48,
        letterSpacing: 1.4,
        maxLines: 2,
        onOpen: () => LearningProgressService.markModuleOpened('abc_sounds'),
        screen: const LetterSoundsScreen(),
      ),
      CategoryCard(
        title: 'Phonics',
        primaryColor: Colors.amberAccent[100]!,
        secondaryColor: Colors.deepOrangeAccent,
        fontSize: 58,
        onOpen: () => LearningProgressService.markModuleOpened('phonics'),
        screen: const PhonicsScreen(),
      ),
      CategoryCard(
        title: 'Where?',
        primaryColor: Colors.lightBlueAccent[100]!,
        secondaryColor: Colors.blue,
        fontSize: 60,
        onOpen: () => LearningProgressService.markModuleOpened('prepositions'),
        screen: const PrepositionsScreen(),
      ),
      CategoryCard(
        title: 'Stories',
        primaryColor: const Color(0xFF3383CD),
        secondaryColor: const Color(0xFF11249F),
        onOpen: () => LearningProgressService.markModuleOpened('stories'),
        screen: const StoriesScreen(
          title: 'Stories',
          primaryColor: Color(0xFF3383CD),
          secondaryColor: Color(0xFF11249F),
        ),
      ),
      CategoryCard(
        title: 'Birds',
        primaryColor: Colors.purpleAccent[100]!,
        secondaryColor: Colors.purple,
        onOpen: () => LearningProgressService.markModuleOpened('birds'),
        screen: BirdsScreen(
          title: 'Birds',
          primaryColor: Colors.purpleAccent[100]!,
          secondaryColor: Colors.purple,
        ),
      ),
      _buildModuleCard(bodyPartsModule, 'body'),
      _buildModuleCard(fruitsAndVeggiesModule, 'fruits'),
      _buildModuleCard(flowersModule, 'flowers'),
      _buildModuleCard(occupationsModule, 'jobs'),
      _buildModuleCard(seasonsModule, 'seasons'),
      _buildModuleCard(spaceModule, 'space'),
      CategoryCard(
        title: 'For\nParents',
        primaryColor: const Color(0xFFA7C7FF),
        secondaryColor: const Color(0xFF5C6BC0),
        fontSize: 48,
        letterSpacing: 1.2,
        maxLines: 2,
        onOpen: () => LearningProgressService.markModuleOpened('parents'),
        screen: const ParentReportScreen(),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          image: const DecorationImage(
            image: AssetImage('assets/images/bg-bottom.png'),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 188.0,
              backgroundColor: Colors.grey[50],
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  'assets/images/bg-top.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(categories),
            ),
          ],
        ),
      ),
    );
  }
}
