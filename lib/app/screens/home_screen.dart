import 'package:flutter/material.dart';
import 'package:kid_starter/app/screens/animal_screen.dart';
import 'package:kid_starter/app/screens/birds_screen.dart';

import '../controllers/vocabulary_modules.dart';
import '../models/vocabulary_item.dart';
import '../widgets/category_card.dart';
import 'alphabet_en_screen.dart';
import 'color_screen.dart';
import 'letter_sounds_screen.dart';
import 'numeric_en_screen.dart';
import 'phonics_screen.dart';
import 'prepositions_screen.dart';
import 'shape_screen.dart';
import 'story_screen.dart';
import 'vocabulary_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  CategoryCard _buildModuleCard(VocabularyModule module) {
    return CategoryCard(
      title: module.homeTitle,
      primaryColor: module.primaryColor,
      secondaryColor: module.secondaryColor,
      fontSize: module.homeFontSize,
      maxLines: module.homeMaxLines,
      letterSpacing: module.homeLetterSpacing,
      screen: VocabularyScreen(
        title: module.screenTitle,
        primaryColor: module.primaryColor,
        secondaryColor: module.secondaryColor,
        items: module.items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> categories = [
      CategoryCard(
        title: 'Animals',
        primaryColor: Colors.purpleAccent[100]!,
        secondaryColor: Colors.purple,
        screen: AnimalScreen(
          title: 'Animals',
          primaryColor: Colors.purpleAccent[100]!,
          secondaryColor: Colors.purple,
        ),
      ),
      CategoryCard(
        title: 'Birds',
        primaryColor: Colors.purpleAccent[100]!,
        secondaryColor: Colors.purple,
        screen: BirdsScreen(
          title: 'Birds',
          primaryColor: Colors.purpleAccent[100]!,
          secondaryColor: Colors.purple,
        ),
      ),
      CategoryCard(
        title: 'Colors',
        primaryColor: Colors.orangeAccent[100]!,
        secondaryColor: Colors.orange,
        screen: ColorScreen(
          title: 'Colors',
          primaryColor: Colors.orangeAccent[100]!,
          secondaryColor: Colors.orange,
        ),
      ),
      CategoryCard(
        title: '123',
        primaryColor: Colors.greenAccent[100]!,
        secondaryColor: Colors.green,
        screen: NumericEnScreen(
          title: '123',
          primaryColor: Colors.greenAccent[100]!,
          secondaryColor: Colors.green,
        ),
      ),
      CategoryCard(
        title: 'Phonics',
        primaryColor: Colors.amberAccent[100]!,
        secondaryColor: Colors.deepOrangeAccent,
        fontSize: 58,
        screen: const PhonicsScreen(),
      ),
      CategoryCard(
        title: 'Where?',
        primaryColor: Colors.lightBlueAccent[100]!,
        secondaryColor: Colors.blue,
        fontSize: 60,
        screen: const PrepositionsScreen(),
      ),
      CategoryCard(
        title: 'ABC',
        primaryColor: Colors.purpleAccent[100]!,
        secondaryColor: Colors.purple,
        screen: AlphabetEnScreen(
          title: 'ABC',
          primaryColor: Colors.purpleAccent[100]!,
          secondaryColor: Colors.purple,
        ),
      ),
      const CategoryCard(
        title: 'ABC\nSounds',
        primaryColor: Color(0xFFFFCC80),
        secondaryColor: Color(0xFFFF8A65),
        fontSize: 48,
        letterSpacing: 1.4,
        maxLines: 2,
        screen: LetterSoundsScreen(),
      ),
      _buildModuleCard(bodyPartsModule),
      _buildModuleCard(fruitsAndVeggiesModule),
      _buildModuleCard(flowersModule),
      _buildModuleCard(occupationsModule),
      _buildModuleCard(seasonsModule),
      _buildModuleCard(spaceModule),
      const CategoryCard(
        title: 'Stories',
        primaryColor: Color(0xFF3383CD),
        secondaryColor: Color(0xFF11249F),
        screen: StoriesScreen(
          title: 'Stories',
          primaryColor: Color(0xFF3383CD),
          secondaryColor: Color(0xFF11249F),
        ),
      ),
      CategoryCard(
        title: 'Shapes',
        primaryColor: Colors.redAccent[100]!,
        secondaryColor: Colors.red,
        screen: ShapesScreen(
          title: 'Shapes',
          primaryColor: Colors.redAccent[100]!,
          secondaryColor: Colors.red,
        ),
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
