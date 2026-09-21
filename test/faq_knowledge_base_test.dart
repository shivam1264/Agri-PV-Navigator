import 'package:flutter_test/flutter_test.dart';
import 'package:agri_pv_navigator/features/support/data/faq_knowledge_base.dart';
import 'package:agri_pv_navigator/repositories/support_repository.dart';

void main() {
  group('FaqKnowledgeBase Institutional Q&A Tests', () {
    test('contains all 12 user screenshot questions and categories', () {
      final items = FaqKnowledgeBase.items;
      expect(items.length, greaterThanOrEqualTo(12));

      // Category 1: Getting Started
      final gettingStarted = FaqKnowledgeBase.getByCategory('Getting Started');
      expect(gettingStarted.length, greaterThanOrEqualTo(3));
      final gsQuestions = gettingStarted.map((i) => i.questionEn).toList();
      expect(gsQuestions, contains('How do I add a new farm?'));
      expect(gsQuestions, contains('How to draw farm boundary on the map?'));
      expect(gsQuestions, contains('What crop types are supported?'));

      // Category 2: Using the App
      final usingApp = FaqKnowledgeBase.getByCategory('Using the App');
      expect(usingApp.length, greaterThanOrEqualTo(3));
      final usingQuestions = usingApp.map((i) => i.questionEn).toList();
      expect(usingQuestions, contains('How to set solar panel tilt angle?'));
      expect(usingQuestions, contains('How do I configure row spacing?'));
      expect(usingQuestions, contains('What is the BCI score?'));

      // Category 3: Technical Support
      final techSupport = FaqKnowledgeBase.getByCategory('Technical Support');
      expect(techSupport.length, greaterThanOrEqualTo(3));
      final techQuestions = techSupport.map((i) => i.questionEn).toList();
      expect(techQuestions, contains('3D view is not rendering correctly'));
      expect(techQuestions, contains('PDF report is not generating'));
      expect(techQuestions, contains('The app crashes on AR mode'));

      // Category 4: FAQs (Subsidies and Yields)
      final faqs = FaqKnowledgeBase.getByCategory('FAQs');
      expect(faqs.length, greaterThanOrEqualTo(3));
      final faqQuestions = faqs.map((i) => i.questionEn).toList();
      expect(faqQuestions, contains('Are there government subsidies for Agri-PV?'));
      expect(faqQuestions, contains('How much crop yield reduction to expect?'));
      expect(faqQuestions, contains('Can I integrate with existing solar systems?'));
    });

    test('every question has human persona, bilingual content, and actionable advice', () {
      for (final item in FaqKnowledgeBase.items) {
        // Personas
        expect(item.persona.name.isNotEmpty, isTrue);
        expect(item.persona.roleEn.isNotEmpty, isTrue);
        expect(item.persona.roleHi.isNotEmpty, isTrue);

        // English content
        expect(item.getQuestion(false).isNotEmpty, isTrue);
        expect(item.getAnswer(false).length, greaterThan(60)); // deep, rich answer
        expect(item.getRole(false).isNotEmpty, isTrue);

        // Hindi content
        expect(item.getQuestion(true).isNotEmpty, isTrue);
        expect(item.getAnswer(true).length, greaterThan(60)); // deep Hindi response
        expect(item.getRole(true).isNotEmpty, isTrue);

        // Action CTA and tags
        if (item.actionRoute != null) {
          expect(item.getActionLabel(false)?.isNotEmpty, isTrue);
          expect(item.getActionLabel(true)?.isNotEmpty, isTrue);
          expect(item.actionRoute!.startsWith('/'), isTrue);
        }
        expect(item.tags.isNotEmpty, isTrue);
      }
    });

    test('fuzzy search matches relevant queries accurately in English and Hindi', () {
      // Search for subsidy / कुसुम
      final subsidyResults = FaqKnowledgeBase.search('subsidy');
      expect(subsidyResults.any((i) => i.id == 'subsidies_for_agri_pv'), isTrue);

      final kusumHindi = FaqKnowledgeBase.search('सब्सिडी', isHindi: true);
      expect(kusumHindi.any((i) => i.id == 'subsidies_for_agri_pv'), isTrue);

      // Search for 3D view
      final threeDResults = FaqKnowledgeBase.search('3D view');
      expect(threeDResults.any((i) => i.id == '3d_view_rendering_trouble'), isTrue);

      // Search for tilt angle
      final tiltResults = FaqKnowledgeBase.search('tilt');
      expect(tiltResults.any((i) => i.id == 'set_tilt_angle'), isTrue);

      // Search for spacing / tractor
      final spacingResults = FaqKnowledgeBase.search('spacing');
      expect(spacingResults.any((i) => i.id == 'configure_row_spacing'), isTrue);
    });

    test('SupportRepository falls back gracefully to institutional knowledge base', () async {
      final repo = SupportRepository();
      // Should not throw and should return default items even if backend offline
      final faqs = await repo.getFaqs();
      expect(faqs.isNotEmpty, isTrue);
      expect(faqs.length, greaterThanOrEqualTo(12));
    });
  });
}
