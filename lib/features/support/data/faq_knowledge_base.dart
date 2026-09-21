import 'package:flutter/material.dart';

/// Specialist persona representing the human expert answering farmer queries.
class FaqPersona {
  final String id;
  final String name;
  final String roleEn;
  final String roleHi;
  final IconData icon;
  final Color badgeColor;

  const FaqPersona({
    required this.id,
    required this.name,
    required this.roleEn,
    required this.roleHi,
    required this.icon,
    required this.badgeColor,
  });

  static const aruna = FaqPersona(
    id: 'aruna',
    name: 'Dr. Aruna Rao',
    roleEn: 'Chief Agronomist & Crop Microclimate Specialist',
    roleHi: 'मुख्य कृषि वैज्ञानिक एवं फसल छाया विशेषज्ञ',
    icon: Icons.eco_rounded,
    badgeColor: Color(0xFF10B981), // Emerald
  );

  static const vikram = FaqPersona(
    id: 'vikram',
    name: 'Er. Vikramaditya Singh',
    roleEn: 'Senior Solar PV Systems & Structural Engineer',
    roleHi: 'वरिष्ठ सौर प्रणाली एवं स्ट्रक्चरल इंजीनियर',
    icon: Icons.solar_power_rounded,
    badgeColor: Color(0xFF0284C7), // Sky blue
  );

  static const kavita = FaqPersona(
    id: 'kavita',
    name: 'Kavita Desai',
    roleEn: 'Farm Economics & PM-KUSUM Subsidy Lead',
    roleHi: 'कृषि अर्थशास्त्र एवं पीएम-कुसुम सब्सिडी सलाहकार',
    icon: Icons.account_balance_rounded,
    badgeColor: Color(0xFF8B5CF6), // Purple
  );

  static const aakash = FaqPersona(
    id: 'aakash',
    name: 'Aakash Nair',
    roleEn: 'App Systems & 3D Simulation Engineer',
    roleHi: 'सॉफ्टवेयर एवं 3D सिमुलेशन इंजीनियर',
    icon: Icons.devices_rounded,
    badgeColor: Color(0xFFF59E0B), // Amber
  );
}

/// Rich FAQ item containing bilingual questions, conversational expert answers,
/// action shortcuts, and tags for intelligent fuzzy search.
class FaqItem {
  final String id;
  final String category; // 'Getting Started', 'Using the App', 'Technical Support', 'FAQs'
  final String questionEn;
  final String questionHi;
  final String answerEn;
  final String answerHi;
  final FaqPersona persona;
  final String? actionLabelEn;
  final String? actionLabelHi;
  final String? actionRoute;
  final List<String> tags;

  const FaqItem({
    required this.id,
    required this.category,
    required this.questionEn,
    required this.questionHi,
    required this.answerEn,
    required this.answerHi,
    required this.persona,
    this.actionLabelEn,
    this.actionLabelHi,
    this.actionRoute,
    this.tags = const [],
  });

  String getQuestion(bool isHindi) => isHindi ? questionHi : questionEn;
  String getAnswer(bool isHindi) => isHindi ? answerHi : answerEn;
  String getRole(bool isHindi) => isHindi ? persona.roleHi : persona.roleEn;
  String? getActionLabel(bool isHindi) => isHindi ? actionLabelHi : actionLabelEn;
}

/// Comprehensive institutional repository of all Agri-PV Q&As
class FaqKnowledgeBase {
  static const List<FaqItem> items = [
    // ══════════════════════════════════════════════════════════════════════════
    // CATEGORY 1: GETTING STARTED
    // ══════════════════════════════════════════════════════════════════════════
    FaqItem(
      id: 'add_new_farm',
      category: 'Getting Started',
      questionEn: 'How do I add a new farm?',
      questionHi: 'मैं नया खेत कैसे जोड़ूं?',
      answerEn:
          "Hello! Adding your farm is straightforward and takes under two minutes:\n\n"
          "1. Tap the '+ Add Farm' button on your Home screen or navigate to the Farm Location tab.\n"
          "2. Name your farm (e.g. 'Green Valley Plot 1') and enter your state or district.\n"
          "3. Select your primary soil type (Loam, Clay, Sandy, or Black Cotton) and primary crop.\n"
          "4. Mark your exact plot on the interactive satellite map to automatically calculate farm acreage.\n\n"
          "💡 Pro Tip: Entering accurate historical irrigation data will allow our optimizer to forecast water savings up to 35% under solar shade!",
      answerHi:
          "नमस्ते! अपने खेत को जोड़ना बहुत आसान है और इसमें 2 मिनट से भी कम समय लगता है:\n\n"
          "1. अपनी होम स्क्रीन पर '+ नया खेत जोड़ें' बटन दबाएं या 'खेत का स्थान' टैब पर जाएं।\n"
          "2. अपने खेत का नाम रखें (जैसे 'गंगा फार्म प्लॉट 1') और राज्य या जिला चुनें।\n"
          "3. अपनी मिट्टी का प्रकार (दोमट, चिकनी, रेतीली या काली मिट्टी) और मुख्य फसल चुनें।\n"
          "4. सैटेलाइट मैप पर अपने खेत की सीमाएं पिन करें, जिससे क्षेत्रफल अपने आप आ जाएगा।\n\n"
          "💡 विशेषज्ञ सलाह: सटीक सिंचाई विवरण दर्ज करने से हमारा सिस्टम सौर छाया में 35% तक पानी की बचत का सटीक अनुमान लगा सकेगा!",
      persona: FaqPersona.aruna,
      actionLabelEn: 'Add Farm Now',
      actionLabelHi: 'अभी खेत जोड़ें',
      actionRoute: '/farm-location',
      tags: ['add', 'farm', 'new', 'create', 'plot', 'acreage', 'location', 'map', 'खेत', 'जोड़ें', 'नया'],
    ),

    FaqItem(
      id: 'draw_boundary_map',
      category: 'Getting Started',
      questionEn: 'How to draw farm boundary on the map?',
      questionHi: 'मानचित्र पर खेत की सीमा कैसे बनाएं?',
      answerEn:
          "Hi there! Defining your boundary accurately ensures solar panel layouts fit your real topography:\n\n"
          "• Open the Farm Location screen and switch to Satellite View for clear fence-line visibility.\n"
          "• Tap on the corners of your field in sequence to drop boundary pins (minimum 3 pins required for a polygon).\n"
          "• Drag any pin to fine-tune its position along bunds, trees, or irrigation channels.\n"
          "• Double-tap the first pin or hit 'Complete Boundary' — the app immediately computes total acreage and solar capacity potential in kW!",
      answerHi:
          "नमस्ते किसान साथी! सीमा रेखा को सही ढंग से खींचने से सोलर पैनल आपके खेत की वास्तविक संरचना में सटीक बैठते हैं:\n\n"
          "• 'खेत का स्थान' स्क्रीन खोलें और खेत की मेड़ें साफ देखने के लिए सैटेलाइट व्यू चुनें।\n"
          "• अपने खेत के कोनों पर क्रम से टैप करें (कम से कम 3 पिन आवश्यक हैं)।\n"
          "• किसी भी पिन को दबाकर मेड़ या पेड़ों के अनुसार आगे-पीछे खिसका सकते हैं।\n"
          "• पहले पिन पर टैप करें या 'सीमा पूरी करें' दबाएं — ऐप तुरंत आपका कुल रकबा और संभावित सौर क्षमता (kW) निकाल देगा!",
      persona: FaqPersona.vikram,
      actionLabelEn: 'Open Map Boundary Tool',
      actionLabelHi: 'मैप बाउंड्री टूल खोलें',
      actionRoute: '/farm-location',
      tags: ['boundary', 'draw', 'map', 'satellite', 'pins', 'polygon', 'border', 'area', 'सीमा', 'नक्शा', 'मैप'],
    ),

    FaqItem(
      id: 'crop_types_supported',
      category: 'Getting Started',
      questionEn: 'What crop types are supported?',
      questionHi: 'कौन-कौन सी फसलें समर्थित हैं?',
      answerEn:
          "Greetings! We have modeled 20+ major C3 and C4 crop cultivars calibrated with ICAR and global research institutes:\n\n"
          "🌱 Shade-Loving & High-Tolerance (0% to +15% yield gain under panels):\n"
          "• Tomatoes, Leafy Greens (Spinach, Lettuce), Broccoli, Potatoes, Garlic & Onions.\n\n"
          "🌾 Moderate Tolerance (Yield neutral with 6m+ pitch):\n"
          "• Wheat, Barley, Mustard, Soybeans, Chickpeas, and Strawberries.\n\n"
          "☀️ High-Light Cereals (Requires elevated tilt & wider 8-10m pitch):\n"
          "• Rice (Paddy), Maize (Corn), Sugarcane, and Cotton.\n\n"
          "Our system automatically runs Daily Light Integral (DLI) simulations to ensure your selected crop never receives sub-optimal photosynthetic light.",
      answerHi:
          "नमस्कार! हमने आईसीएआर (ICAR) और अंतरराष्ट्रीय शोध संस्थानों के डेटा के आधार पर 20+ प्रमुख फसलों का मॉडल तैयार किया है:\n\n"
          "🌱 छाया-सहिष्णु फसलें (पैनलों के नीचे 0% से +15% तक उपज वृद्धि):\n"
          "• टमाटर, पत्तेदार सब्जियां (पालक, मेथी), पत्तागोभी, आलू, लहसुन और प्याज।\n\n"
          "🌾 मध्यम सहनशील फसलें (6 मीटर दूरी पर उपज पर कोई नुकसान नहीं):\n"
          "• गेहूं, जौ, सरसों, सोयाबीन, चना और स्ट्रॉबेरी।\n\n"
          "☀️ अधिक धूप चाहने वाली फसलें (8-10 मीटर चौड़ी कतार आवश्यक):\n"
          "• धान (चावल), मक्का, गन्ना और कपास।\n\n"
          "हमारा सिस्टम स्वतः डीएलआई (DLI) प्रकाश गणना करता है ताकि आपकी फसल को प्रकाश संश्लेषण के लिए पर्याप्त धूप मिले।",
      persona: FaqPersona.aruna,
      actionLabelEn: 'Check Crop Suitability',
      actionLabelHi: 'फसल अनुकूलता जांचें',
      actionRoute: '/site-suitability',
      tags: ['crop', 'types', 'supported', 'wheat', 'rice', 'tomato', 'potato', 'mustard', 'shade', 'dli', 'फसल', 'उपज'],
    ),

    // ══════════════════════════════════════════════════════════════════════════
    // CATEGORY 2: USING THE APP
    // ══════════════════════════════════════════════════════════════════════════
    FaqItem(
      id: 'set_tilt_angle',
      category: 'Using the App',
      questionEn: 'How to set solar panel tilt angle?',
      questionHi: 'सोलर पैनल का झुकाव कोण (Tilt Angle) कैसे सेट करें?',
      answerEn:
          "Hello! Finding the sweet spot for panel tilt balances seasonal solar generation against crop canopy shadow:\n\n"
          "• Go to 'Agri-PV System Design' and locate the **Tilt Angle Slider** (ranges from 0° to 45°).\n"
          "• **Latitude Rule of Thumb**: For most Indian states, set tilt equal to your latitude minus 3° to 5° for Agri-PV (e.g. 18°–22° in Punjab/Haryana/UP, 12°–15° in Maharashtra/Telangana).\n"
          "• Lower tilt angles (15°–20°) allow more diffuse light penetration beneath panels for winter rabi crops, whereas steep tilts (>30°) increase row shading.\n"
          "• Check the live 'Annual Generation' and 'Crop PAR Light' meters update dynamically in real time as you adjust the slider!",
      answerHi:
          "नमस्ते! पैनल के झुकाव (टिल्ट एंगल) को सही रखना सौर ऊर्जा और फसल दोनों के लिए बेहद जरूरी है:\n\n"
          "• 'एग्री-पीवी सिस्टम डिजाइन' स्क्रीन पर जाएं और **टिल्ट एंगल स्लाइडर** (0° से 45°) देखें।\n"
          "• **अक्षांश का नियम**: भारत के अधिकांश हिस्सों में, अपने अक्षांश से 3°-5° कम रखें (उदा. पंजाब, हरियाणा, उत्तर प्रदेश में 18°–22°, महाराष्ट्र और दक्षिण भारत में 12°–15°)।\n"
          "• कम झुकाव (15°–20°) से रबी की फसलों को पैनल के नीचे बेहतर धूप मिलती है।\n"
          "• स्लाइडर हिलाते ही स्क्रीन पर वार्षिक बिजली उत्पादन और फसल की धूप का प्रतिशत तुरंत बदलता दिखाई देगा!",
      persona: FaqPersona.vikram,
      actionLabelEn: 'Adjust Tilt in Design Tool',
      actionLabelHi: 'डिजाइन टूल में टिल्ट सेट करें',
      actionRoute: '/agri-pv-design',
      tags: ['tilt', 'angle', 'slope', 'degrees', 'solar', 'panel', 'latitude', 'design', 'झुकाव', 'कोण', 'टिल्ट'],
    ),

    FaqItem(
      id: 'configure_row_spacing',
      category: 'Using the App',
      questionEn: 'How do I configure row spacing?',
      questionHi: 'कतारों के बीच की दूरी (Row Spacing) कैसे निर्धारित करें?',
      answerEn:
          "Hi! Inter-row pitch is the single most critical factor in Agri-PV engineering:\n\n"
          "• Open the System Design screen and adjust the **Row Spacing (Pitch)** slider (3.0m to 12.0m).\n"
          "• **Tractor & Machinery Clearance**: If you use standard 40–55 HP tractors, maintain a minimum inter-row distance of 5.5m to 6.5m.\n"
          "• **Combine Harvesters**: If large harvesters operate on your fields, select a 7.5m to 9.0m spacing.\n"
          "• **Sunlight Transmission**: Wider spacing increases ground irradiation by up to 40%, safeguarding crop photosynthesis while slightly reducing panel density.\n"
          "• You can toggle the 3D Shadow Simulation to see how shadows shift hour-by-hour across seasons!",
      answerHi:
          "नमस्ते! सोलर कतारों के बीच की दूरी (पिच) कृषि और बिजली दोनों के संतुलन की सबसे महत्वपूर्ण कुंजी है:\n\n"
          "• 'सिस्टम डिजाइन' स्क्रीन में जाएं और **रो स्पेसिंग स्लाइडर** (3.0 मीटर से 12.0 मीटर) को एडजस्ट करें।\n"
          "• **ट्रैक्टर एवं कृषि यंत्र**: यदि आप 40-55 HP के सामान्य ट्रैक्टर चलाते हैं, तो कम से कम 5.5 से 6.5 मीटर की दूरी रखें।\n"
          "• **कंबाइन हार्वेस्टर**: बड़े हार्वेस्टर चलाने के लिए 7.5 से 9.0 मीटर की दूरी सबसे उपयुक्त है।\n"
          "• **धूप का प्रसार**: अधिक दूरी रखने से जमीन पर 40% तक अधिक धूप पहुंचती है जिससे फसल का विकास भरपूर होता है।\n"
          "• 3D शैडो सिमुलेटर चलाकर आप दिन के हर घंटे में धूप और छांव की स्थिति देख सकते हैं!",
      persona: FaqPersona.vikram,
      actionLabelEn: 'Set Row Spacing Now',
      actionLabelHi: 'कतार दूरी सेट करें',
      actionRoute: '/agri-pv-design',
      tags: ['spacing', 'row', 'pitch', 'tractor', 'clearance', 'width', 'machinery', 'दूरी', 'कतार', 'स्पेसिंग'],
    ),

    FaqItem(
      id: 'what_is_bci_score',
      category: 'Using the App',
      questionEn: 'What is the BCI score?',
      questionHi: 'बीसीआई (BCI) स्कोर क्या है?',
      answerEn:
          "Hello! BCI stands for **Bifacial Co-location Index (or Benefit-Cost Indicator)**, our proprietary composite performance score rated from 0 to 100:\n\n"
          "It integrates four scientific metrics into a single health score:\n"
          "1. **Crop Photosynthesis Index (35%)**: Measures DLI light reaching the ground canopy.\n"
          "2. **Solar Capacity & Energy Yield (30%)**: Specific kWh generated per kWp installed.\n"
          "3. **Microclimate Water Conservation (20%)**: Evapotranspiration reduction and soil moisture retention.\n"
          "4. **Financial IRR & Payback (15%)**: Return on investment factoring capital expenditure and crop revenue.\n\n"
          "🎯 Score Interpretation: A BCI above 80 indicates an exceptional dual-use design where agriculture and renewable energy thrive together symbiotically!",
      answerHi:
          "नमस्कार! बीसीआई (BCI) का अर्थ है **बायफेशियल को-लोकेशन इंडेक्स (Benefit-Cost Indicator)**, जो 0 से 100 के बीच आंका जाने वाला वैज्ञानिक स्कोर है:\n\n"
          "यह चार प्रमुख पैमानों को मिलाकर बनता है:\n"
          "1. **फसल प्रकाश संश्लेषण सूचकांक (35%)**: फसल तक पहुंचने वाली वास्तविक धूप की मात्रा।\n"
          "2. **सौर ऊर्जा उत्पादन (30%)**: प्रति किलोवाट कितनी बिजली पैदा हो रही है।\n"
          "3. **जल संरक्षण एवं सूक्ष्म-जलवायु (20%)**: वाष्पीकरण में कमी और नमी का संरक्षण।\n"
          "4. **वित्तीय रिटर्न (IRR) और लागत वसूली (15%)**: कुल निवेश पर मिलने वाला शुद्ध लाभ।\n\n"
          "🎯 80 से ऊपर का स्कोर उत्कृष्ट माना जाता है, जिसका अर्थ है कि खेत से फसल और बिजली दोनों का अधिकतम लाभ मिल रहा है!",
      persona: FaqPersona.kavita,
      actionLabelEn: 'View Design Comparison',
      actionLabelHi: 'डिजाइन तुलना देखें',
      actionRoute: '/compare-designs',
      tags: ['bci', 'score', 'metric', 'index', 'bifacial', 'photosynthesis', 'irr', 'रेटिंग', 'स्कोर'],
    ),

    // ══════════════════════════════════════════════════════════════════════════
    // CATEGORY 3: TECHNICAL SUPPORT
    // ══════════════════════════════════════════════════════════════════════════
    FaqItem(
      id: '3d_view_rendering_trouble',
      category: 'Technical Support',
      questionEn: '3D view is not rendering correctly',
      questionHi: '3D व्यू सही से रेंडर (दिखाई) नहीं दे रहा है',
      answerEn:
          "Hi! If the 3D Agri-PV canvas appears blank, stutters, or shows black panels, here is how to resolve it immediately:\n\n"
          "1. **Reset Camera**: Tap the 'Reset View' icon at the top right of the 3D viewport to center your field coordinates.\n"
          "2. **Toggle Texture Quality**: If your device has limited GPU memory, open App Settings and toggle 'Reduce Motion / High Performance Canvas'.\n"
          "3. **Verify Boundary Pins**: Ensure your farm boundary does not have self-intersecting lines (like a figure-8), which can prevent the 3D ground mesh from tessellating.\n"
          "4. **Hardware Acceleration**: Make sure battery saver mode is disabled on your mobile device, as it restricts WebGL/OpenGL rendering.\n\n"
          "If the issue persists, our technical team is ready to inspect your farm layout!",
      answerHi:
          "नमस्ते! यदि 3D व्यू खाली दिख रहा है, अटक रहा है या पैनल काले दिख रहे हैं, तो इन आसान चरणों से तुरंत ठीक करें:\n\n"
          "1. **कैमरा रीसेट करें**: 3D स्क्रीन के ऊपरी दाएं कोने में 'Reset View' बटन दबाएं।\n"
          "2. **क्वालिटी सेटिंग**: यदि फोन की रैम कम है, तो सेटिंग्स में जाकर 'Reduce Motion' चालू करें।\n"
          "3. **सीमा रेखा की जांच**: ध्यान दें कि खेत की बाउंड्री लाइन एक-दूसरे को काट (Cross) न रही हो।\n"
          "4. **बैटरी सेवर बंद करें**: फोन का बैटरी सेवर मोड ग्राफिक्स (OpenGL) की क्षमता को धीमा कर देता है, इसे बंद कर दें।\n\n"
          "यदि समस्या फिर भी बनी रहती है, तो आप नीचे लाइव चैट में हमें मैसेज भेज सकते हैं!",
      persona: FaqPersona.aakash,
      actionLabelEn: 'Launch 3D View Tool',
      actionLabelHi: '3D व्यू टूल खोलें',
      actionRoute: '/ar-3d-view',
      tags: ['3d', 'rendering', 'canvas', 'glitch', 'black', 'stutter', 'gpu', 'reset', 'तकनीकी', 'समस्या', '3डी'],
    ),

    FaqItem(
      id: 'pdf_report_not_generating',
      category: 'Technical Support',
      questionEn: 'PDF report is not generating',
      questionHi: 'पीडीएफ (PDF) रिपोर्ट जनरेट नहीं हो रही है',
      answerEn:
          "Hello! Our comprehensive PDF feasibility report generates institutional-grade project dossiers with bankable financial and agronomic data. If generation stalls:\n\n"
          "• **Ensure Design is Configured**: The engine requires at least one saved farm boundary and system configuration (tilt, spacing, crop) to calculate yields.\n"
          "• **Storage Permissions**: Check that Agri-PV Navigator has permission to save files to your device downloads folder.\n"
          "• **Allow Calculation Time**: Comprehensive reports simulate 8,760 hourly solar angles and DLI calculations; on older phones this can take 4–6 seconds.\n"
          "• **Network Connection**: While base calculations run on-device, climate data and subsidy verification sync with our server.\n\n"
          "You can preview all data directly on the Proposal Report screen before exporting!",
      answerHi:
          "नमस्कार! हमारी पीडीएफ रिपोर्ट बैंकों और सरकारी योजनाओं में जमा करने योग्य संपूर्ण तकनीकी व वित्तीय विवरण तैयार करती है। यदि यह डाउनलोड नहीं हो रही:\n\n"
          "• **सिस्टम डिजाइन पूरा करें**: रिपोर्ट बनाने के लिए खेत का आकार, पैनल का झुकाव और फसल का चुनाव होना आवश्यक है।\n"
          "• **स्टोरेज परमिशन**: जांच लें कि ऐप को फाइल सेव करने की अनुमति (Storage Permission) मिली हुई है।\n"
          "• **कुछ सेकंड प्रतीक्षा करें**: रिपोर्ट पूरे साल के 8,760 घंटों की धूप और छाया का विश्लेषण करती है, इसमें 4-6 सेकंड लग सकते हैं।\n"
          "• **इंटरनेट जांचें**: मौसम डेटा और सब्सिडी सत्यापन के लिए सामान्य इंटरनेट कनेक्टिविटी जरूरी है।\n\n"
          "आप पीडीएफ बनाने से पहले 'प्रपोजल रिपोर्ट' स्क्रीन पर सारा डेटा देख सकते हैं!",
      persona: FaqPersona.aakash,
      actionLabelEn: 'Go to Reports Screen',
      actionLabelHi: 'रिपोर्ट्स स्क्रीन पर जाएं',
      actionRoute: '/reports',
      tags: ['pdf', 'report', 'generating', 'download', 'export', 'feasibility', 'bank', 'पीडीएफ', 'डाउनलोड', 'रिपोर्ट'],
    ),

    FaqItem(
      id: 'app_crashes_on_ar_mode',
      category: 'Technical Support',
      questionEn: 'The app crashes on AR mode',
      questionHi: 'एआर (AR) मोड चालू करने पर ऐप क्रैश हो जाता है',
      answerEn:
          "Hi! Augmented Reality (AR) mode projects a life-sized 3D solar racking structure directly over your live field camera feed. If it closes unexpectedly:\n\n"
          "1. **ARCore / ARKit Support**: Confirm your mobile device supports Google AR Services (ARCore on Android) or ARKit (on iOS). Older devices without ARCore will default to the 3D Interactive Canvas instead.\n"
          "2. **Camera Permission**: Go to your device Settings → Apps → Agri-PV Navigator → Permissions → Allow Camera access.\n"
          "3. **Adequate Ambient Lighting**: AR surface-tracking requires visible ground texture. Avoid launching AR in deep darkness or over featureless white concrete.\n"
          "4. **Fallback Option**: You can use our interactive **3D Orbit Canvas** at any time—it offers the exact same spatial measurements and shadow analysis without requiring AR hardware!",
      answerHi:
          "नमस्ते किसान मित्र! ऑगमेंटेड रियलिटी (AR) आपके फोन के कैमरे से खेत में असली आकार के सोलर पैनल खड़े करके दिखाती है। यदि यह बंद हो रही है:\n\n"
          "1. **ARCore सपोर्ट**: सुनिश्चित करें कि आपका फोन Google ARCore सपोर्ट करता है। यदि नहीं, तो ऐप स्वतः साधारण 3D मोड पर काम करेगा।\n"
          "2. **कैमरा परमिशन**: फोन सेटिंग्स → ऐप्स → Agri-PV Navigator में जाकर कैमरा परमिशन 'Allow' करें।\n"
          "3. **पर्याप्त रोशनी**: जमीन को डिटेक्ट करने के लिए खेत में अच्छी रोशनी होनी चाहिए, घने अंधेरे में यह काम नहीं करता।\n"
          "4. **3D विकल्प**: आप बिना कैमरे के भी हमारे **3D ऑर्बिट व्यू** का उपयोग कर सकते हैं, जिसमें धूप-छांव का पूरा विवरण दिखता है!",
      persona: FaqPersona.aakash,
      actionLabelEn: 'Open 3D Simulator Alternative',
      actionLabelHi: '3D सिमुलेटर विकल्प खोलें',
      actionRoute: '/ar-3d-view',
      tags: ['ar', 'augmented', 'reality', 'crash', 'camera', 'arcore', '3d', 'क्रैश', 'कैमरा', 'एआर'],
    ),

    // ══════════════════════════════════════════════════════════════════════════
    // CATEGORY 4: FAQS (SUBSIDIES & YIELDS)
    // ══════════════════════════════════════════════════════════════════════════
    FaqItem(
      id: 'subsidies_for_agri_pv',
      category: 'FAQs',
      questionEn: 'Are there government subsidies for Agri-PV?',
      questionHi: 'क्या एग्री-पीवी (Agri-PV) के लिए सरकारी सब्सिडी उपलब्ध है?',
      answerEn:
          "Hello! Absolutely. India and global governments offer substantial financial incentives for agricultural solar co-location:\n\n"
          "1. **PM-KUSUM Scheme (Component A & C)**:\n"
          "   • **Component A**: Set up 500 kW to 2 MW grid-connected solar plants on agricultural land. Discoms purchase generated electricity via long-term 25-year PPAs at guaranteed feed-in tariffs (₹2.90–₹3.30/kWh).\n"
          "   • **Component C**: Solarization of agricultural pumps with up to **30% Central Financial Assistance (CFA)** plus **30% State Subsidy** (farmers pay only 10%–40%).\n"
          "2. **Accelerated Depreciation & GST Benefits**: Agri-PV structural assets qualify for accelerated tax depreciation and concessional 12% GST brackets on solar devices.\n"
          "3. **NABARD & Priority Sector Lending**: Concessional interest loans are available through agricultural development banks.\n\n"
          "Our Techno-Economic module automatically factors these subsidies into your Net Present Value (NPV) and payback timeline!",
      answerHi:
          "नमस्कार! जी हां, केंद्र और राज्य सरकारें एग्री-पीवी और कृषि सौर ऊर्जा पर भारी सब्सिडी और वित्तीय सहायता देती हैं:\n\n"
          "1. **पीएम-कुसुम योजना (PM-KUSUM Component A एवं C)**:\n"
          "   • **घटक A**: किसान अपनी कृषि भूमि पर 500 kW से 2 MW तक का सोलर प्लांट लगा सकते हैं। बिजली वितरण कंपनियां (Discoms) 25 साल के एग्रीमेंट के तहत ₹2.90 से ₹3.30 प्रति यूनिट की दर से बिजली खरीदती हैं।\n"
          "   • **घटक C**: कृषि पंपों के सौरीकरण पर केंद्र से **30% और राज्य सरकार से 30%** तक सब्सिडी मिलती है (किसान को केवल 10% से 40% ही लगाना होता है)।\n"
          "2. **नाबार्ड एवं प्राथमिक क्षेत्र ऋण (Priority Lending)**: बैंकों से बहुत कम ब्याज दर पर आसान किस्तों में लोन मिल जाता है।\n"
          "3. **जीएसटी में छूट**: सोलर उपकरणों पर रियायती जीएसटी दरें लागू होती हैं।\n\n"
          "हमारा ऐप आपके जिले और राज्य के अनुसार मिलने वाली सब्सिडी को स्वतः हिसाब में जोड़कर शुद्ध मुनाफा दिखाता है!",
      persona: FaqPersona.kavita,
      actionLabelEn: 'Open Subsidy Calculator',
      actionLabelHi: 'सब्सिडी कैलकुलेटर देखें',
      actionRoute: '/techno-economic',
      tags: ['subsidy', 'kusum', 'pm-kusum', 'government', 'grant', 'incentive', 'loan', 'cost', 'सब्सिडी', 'कुसुम', 'सरकारी'],
    ),

    FaqItem(
      id: 'crop_yield_reduction_expectations',
      category: 'FAQs',
      questionEn: 'How much crop yield reduction to expect?',
      questionHi: 'फसल की उपज में कितनी कमी की उम्मीद करनी चाहिए?',
      answerEn:
          "Greetings! This is the core concern of every farmer. The reality observed across 100+ global field trials is very reassuring:\n\n"
          "• **Cool-Season & Shade-Tolerant Crops (Wheat, Potatoes, Tomatoes, Leafy Vegetables)**: Expect **0% to +12% yield improvement**! In hot semi-arid zones, midday solar panel shade lowers canopy temperature by 3°C–5°C, preventing heat stress and water transpiration.\n"
          "• **High-Sunlight Cereals (Rice, Corn, Sugarcane)**: With optimal 6m–8m row spacing and elevated 2.8m mounting, yield impact is minimal—typically between **-3% and -8%**, which is overwhelmingly offset by stable solar power revenue.\n"
          "• **Water Efficiency**: Soil retains moisture 20%–35% longer, saving substantial diesel/electricity pumping costs.\n\n"
          "Our system runs automated microclimate calculations to identify the exact layout that maximizes your combined farm + solar revenue.",
      answerHi:
          "नमस्ते! यह हर किसान का सबसे महत्वपूर्ण सवाल है। 100 से अधिक वैज्ञानिक परीक्षणों से मिले परिणाम बेहद उत्साहजनक हैं:\n\n"
          "• **छाया-सहिष्णु व ठंड की फसलें (गेहूं, आलू, टमाटर, सब्जियां)**: उपज में **0% से 12% तक की बढ़ोत्तरी** देखी गई है! तेज गर्मी में पैनलों की छाया से पौधों का तापमान 3°C-5°C कम रहता है, जिससे पौधे मुरझाते नहीं हैं।\n"
          "• **अधिक धूप चाहने वाली फसलें (धान, मक्का)**: यदि कतारों में 6 से 8 मीटर की दूरी रखी जाए, तो उपज में केवल **3% से 8%** का मामूली अंतर आ सकता है, जिसकी भरपाई लाखों रुपये की सोलर बिजली की बिक्री से कहीं ज्यादा हो जाती है।\n"
          "• **पानी की भारी बचत**: मिट्टी की नमी 25% से 35% ज्यादा दिनों तक टिकती है, जिससे सिंचाई का खर्च बहुत घट जाता है।\n\n"
          "कुल मिलाकर, किसान की सालाना आमदनी केवल खेती की तुलना में 2 से 3 गुना तक बढ़ जाती है!",
      persona: FaqPersona.aruna,
      actionLabelEn: 'Simulate Crop Yields',
      actionLabelHi: 'फसल उपज सिमुलेट करें',
      actionRoute: '/site-suitability',
      tags: ['yield', 'reduction', 'loss', 'crop', 'wheat', 'shade', 'water', 'saving', 'उपज', 'नुकसान', 'उत्पादन'],
    ),

    FaqItem(
      id: 'integrate_with_existing_solar',
      category: 'FAQs',
      questionEn: 'Can I integrate with existing solar systems?',
      questionHi: 'क्या मैं इसे अपने मौजूदा सोलर सिस्टम से जोड़ सकता हूँ?',
      answerEn:
          "Hello! Yes, Agri-PV Navigator is fully modular and supports retrofit co-location with existing solar infrastructure:\n\n"
          "1. **Existing Solar Water Pumps (PM-KUSUM Component B)**: You can expand existing rooftop or ground-mount DC pump arrays into dual-use elevated trackers with grid net-metering.\n"
          "2. **Inverter Compatibility**: Our system supports string inverters, central inverters, and micro-inverters. Existing high-capacity inverters can accommodate new bi-facial Agri-PV strings provided maximum DC input voltage (Voc) limits are respected.\n"
          "3. **Hybrid Microgrids & Battery Energy Storage (BESS)**: You can route surplus daytime Agri-PV generation into battery banks to run cold-storage units or farm processing mills overnight.\n\n"
          "In the System Design module, simply toggle 'Existing Grid Connection' to input your current transformer and inverter capacities!",
      answerHi:
          "नमस्कार! जी हां बिल्कुल, हमारा ऐप आपके मौजूदा सोलर पंप या सोलर सिस्टम के साथ तालमेल बिठाने में पूरी तरह सक्षम है:\n\n"
          "1. **सोलर पंप का विस्तार**: यदि आपके पास पहले से सोलर कृषि पंप लगा है, तो आप उसी कनेक्शन में एलिवेटेड स्ट्रक्चर जोड़कर अतिरिक्त बिजली ग्रिड को बेच सकते हैं।\n"
          "2. **इन्वर्टर और ट्रांसफार्मर**: मौजूदा इन्वर्टर की क्षमता अनुसार नए बायफेशियल पैनल्स जोड़े जा सकते हैं।\n"
          "3. **बैटरी और कोल्ड स्टोरेज**: दिन में बनने वाली अतिरिक्त बिजली को बैटरी में स्टोर करके रात में कोल्ड स्टोरेज या ट्यूबवेल चलाने में उपयोग किया जा सकता है।\n\n"
          "सिस्टम डिजाइन में जाकर आप 'Existing Solar Setup' विकल्प चुनकर अपनी वर्तमान क्षमता दर्ज कर सकते हैं!",
      persona: FaqPersona.vikram,
      actionLabelEn: 'Configure System Design',
      actionLabelHi: 'सिस्टम डिजाइन खोलें',
      actionRoute: '/agri-pv-design',
      tags: ['existing', 'solar', 'integrate', 'retrofit', 'pump', 'inverter', 'grid', 'मौजूदा', 'सोलर', 'कनेक्शन'],
    ),

    // ══════════════════════════════════════════════════════════════════════════
    // BONUS HIGH-VALUE AGRI-PV EXPERT TOPICS
    // ══════════════════════════════════════════════════════════════════════════
    FaqItem(
      id: 'machinery_clearance_height',
      category: 'Using the App',
      questionEn: 'What clearance height is needed for farm machinery & tractors?',
      questionHi: 'ट्रैक्टर और कृषि यंत्रों के लिए कितनी ऊंचाई (Clearance) जरूरी है?',
      answerEn:
          "Hello farmer! Equipment clearance is the foundation of farm productivity under solar arrays:\n\n"
          "• **Standard Tractors (Mahindra, Swaraj, John Deere 35–55 HP)**: Require a minimum lower panel edge clearance of **2.5m to 2.8m**.\n"
          "• **Combine Harvesters & Spray Booms**: Require **3.8m to 4.5m** elevated overhead clearance, with reinforced galvanized steel pillars.\n"
          "• **Inter-Row Driving Lanes**: Keep at least 1.2m of clear buffer between wheel tracks and structural foundation piers to prevent root compaction and accidental equipment impact.\n\n"
          "You can configure ground clearance directly in the Agri-PV System Design screen!",
      answerHi:
          "नमस्ते! खेत में बिना रुकावट ट्रैक्टर चलाने के लिए सही ऊंचाई रखना बेहद जरूरी है:\n\n"
          "• **सामान्य ट्रैक्टर (35 से 55 HP)**: जमीन से पैनल के निचले हिस्से की ऊंचाई कम से कम **2.5 से 2.8 मीटर** होनी चाहिए।\n"
          "• **कंबाइन हार्वेस्टर और बड़े स्प्रेयर**: इनके लिए **3.8 से 4.5 मीटर** तक की ऊंचाई की आवश्यकता होती है।\n"
          "• **सुरक्षित ड्राइविंग स्पेस**: पहियों और खंभों के बीच कम से कम 1.2 मीटर की खाली जगह रखें ताकि जड़ों को नुकसान न पहुंचे।\n"
          "आप 'सिस्टम डिजाइन' स्क्रीन में जाकर ग्राउंड क्लीयरेंस को अपनी जरूरत के अनुसार घटा-बढ़ा सकते हैं!",
      persona: FaqPersona.vikram,
      actionLabelEn: 'Adjust Clearance Height',
      actionLabelHi: 'ऊंचाई सेट करें',
      actionRoute: '/agri-pv-design',
      tags: ['clearance', 'height', 'tractor', 'machinery', 'harvester', 'elevation', 'ऊंचाई', 'ट्रैक्टर', 'यंत्र'],
    ),

    FaqItem(
      id: 'water_savings_and_soil_moisture',
      category: 'FAQs',
      questionEn: 'How does Agri-PV affect soil moisture and irrigation water savings?',
      questionHi: 'एग्री-पीवी से मिट्टी की नमी और पानी की बचत पर क्या असर पड़ता है?',
      answerEn:
          "Hi there! Water conservation is one of the biggest hidden superpowers of Agri-PV systems:\n\n"
          "• **Evaporation Reduction**: Overhead solar panels shield topsoil from harsh midday solar radiation, lowering soil evapotranspiration rates by **20% to 35%**.\n"
          "• **Irrigation Scheduling**: In arid regions of Rajasthan, Gujarat, and Maharashtra, farmers report saving 1 to 2 complete irrigation cycles per crop season.\n"
          "• **Rainwater Harvesting**: Rain runoff shedding from panel edges can be channeled directly into inter-row drip irrigation systems or recharge pits.\n\n"
          "Check the Techno-Economic screen to see estimated annual water volume and diesel pumping savings for your acreage!",
      answerHi:
          "नमस्कार! पानी की बचत एग्री-पीवी का सबसे बड़ा वरदान है:\n\n"
          "• **वाष्पीकरण में कमी**: दोपहर की चिलचिलाती धूप सीधे जमीन पर न पड़ने से मिट्टी में नमी **20% से 35%** अधिक समय तक बनी रहती है।\n"
          "• **सिंचाई की बचत**: राजस्थान, गुजरात और मध्य भारत में किसानों को हर सीजन में 1 से 2 बार कम पानी देना पड़ता है।\n"
          "• **वर्षा जल संचयन**: पैनलों से गिरने वाले बारिश के पानी को कतारों में ड्रिप सिंचाई या वाटर रिचार्ज गड्ढों में इकट्ठा किया जा सकता है।\n\n"
          "आप 'टेक्नो-इकोनॉमिक' स्क्रीन पर जाकर देख सकते हैं कि आपके खेत में सालाना कितने लाख लीटर पानी की बचत होगी!",
      persona: FaqPersona.aruna,
      actionLabelEn: 'View Water Savings Metrics',
      actionLabelHi: 'पानी बचत विश्लेषण देखें',
      actionRoute: '/techno-economic',
      tags: ['water', 'saving', 'moisture', 'irrigation', 'evaporation', 'drip', 'पानी', 'नमी', 'सिंचाई'],
    ),

    FaqItem(
      id: 'calculate_payback_irr_lcoe',
      category: 'FAQs',
      questionEn: 'How do I calculate Payback Period, IRR, and LCOE for my farm?',
      questionHi: 'लागत वसूली (Payback), IRR और LCOE की गणना कैसे करें?',
      answerEn:
          "Hello! Our institutional calculation engine computes bank-grade project metrics automatically:\n\n"
          "• **Payback Period**: Typically **4.2 to 5.8 years** with government subsidies (or 6.5–7.5 years without subsidies) on a 25-year plant lifespan.\n"
          "• **Internal Rate of Return (IRR)**: Consistently yields between **16% and 22%**, significantly outperforming traditional agricultural land leasing.\n"
          "• **Levelized Cost of Electricity (LCOE)**: Averages **₹2.10 to ₹2.65 per kWh**, generating strong profit margins when sold back to the grid at ₹3.15/kWh feed-in tariff.\n\n"
          "Visit the Techno-Economic screen to run sensitivity analyses with varying tariff rates, loan tenures, and crop prices!",
      answerHi:
          "नमस्कार! हमारा फाइनेंशियल इंजन बैंकों द्वारा मान्य वित्तीय विश्लेषण स्वतः करता है:\n\n"
          "• **लागत वसूली (Payback Period)**: सरकारी सब्सिडी के साथ **4.2 से 5.8 साल** में पूरा निवेश वापस आ जाता है (प्लांट की उम्र 25 साल होती है)।\n"
          "• **आंतरिक रिटर्न (IRR)**: सालाना **16% से 22%** का सुनिश्चित रिटर्न मिलता है, जो खेत को किराए पर देने से कहीं ज्यादा है।\n"
          "• **बिजली उत्पादन लागत (LCOE)**: लगभग **₹2.10 से ₹2.65 प्रति यूनिट** आती है, जबकि सरकार इसे ₹3.15/यूनिट तक खरीदती है।\n"
          "विस्तृत मुनाफा देखने के लिए 'टेक्नो-इकोनॉमिक' स्क्रीन पर जाएं और अपनी गणना देखें!",
      persona: FaqPersona.kavita,
      actionLabelEn: 'View Financial Model',
      actionLabelHi: 'वित्तीय मॉडल देखें',
      actionRoute: '/techno-economic',
      tags: ['payback', 'irr', 'lcoe', 'profit', 'economics', 'cost', 'roi', 'मुनाफा', 'लागत', 'रिटर्न'],
    ),
  ];

  /// Fuzzy search across questions, answers, and tags in both languages
  static List<FaqItem> search(String query, {bool isHindi = false}) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return items;

    final tokens = clean.split(RegExp(r'\s+'));

    return items.where((item) {
      final q = '${item.questionEn} ${item.questionHi}'.toLowerCase();
      final a = '${item.answerEn} ${item.answerHi}'.toLowerCase();
      final tags = item.tags.join(' ').toLowerCase();
      final fullText = '$q $a $tags';

      return tokens.every((token) => fullText.contains(token));
    }).toList();
  }

  /// Get items by category name
  static List<FaqItem> getByCategory(String category) {
    return items.where((item) => item.category.toLowerCase() == category.toLowerCase()).toList();
  }
}
