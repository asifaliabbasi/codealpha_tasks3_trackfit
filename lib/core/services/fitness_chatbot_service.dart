import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';

class FitnessChatbotService {
  static final FitnessChatbotService _instance =
      FitnessChatbotService._internal();
  factory FitnessChatbotService() => _instance;
  FitnessChatbotService._internal();

  // Gemini AI Configuration
  static const String _apiKey = 'AIzaSyDIFr2ra6gxbFtqKyk64jXPIbi946jk3GY';
  late final GenerativeModel _model;
  bool _isInitialized = false;

  // Initialize the Gemini model
  void _initializeModel() {
    if (!_isInitialized) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(
              HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(
              HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );
      _isInitialized = true;
    }
  }

  // Fitness knowledge base
  final Map<String, List<String>> _fitnessKnowledge = {
    'workout_tips': [
      'Start with a proper warm-up to prevent injuries and improve performance.',
      'Focus on proper form over heavy weights to maximize results and prevent injury.',
      'Include both cardio and strength training for balanced fitness.',
      'Rest days are crucial for muscle recovery and growth.',
      'Stay hydrated during workouts to maintain peak performance.',
      'Listen to your body and don\'t push through pain.',
      'Progressive overload is key - gradually increase intensity over time.',
      'Consistency is more important than perfection.',
    ],
    'nutrition_advice': [
      'Eat a balanced diet with lean proteins, complex carbs, and healthy fats.',
      'Stay hydrated by drinking at least 8 glasses of water daily.',
      'Eat protein within 30 minutes after workouts for optimal recovery.',
      'Include plenty of fruits and vegetables for vitamins and minerals.',
      'Avoid processed foods and focus on whole, natural foods.',
      'Eat smaller, frequent meals to maintain stable blood sugar.',
      'Don\'t skip breakfast - it kickstarts your metabolism.',
      'Limit sugar and alcohol for better fitness results.',
    ],
    'motivation': [
      'Every expert was once a beginner. Keep going!',
      'Progress, not perfection, is the goal.',
      'Your only competition is who you were yesterday.',
      'Small steps lead to big changes over time.',
      'Remember why you started when motivation fades.',
      'Celebrate small victories along the way.',
      'Consistency beats intensity every time.',
      'You\'re stronger than you think you are.',
    ],
    'injury_prevention': [
      'Always warm up before exercising to prepare your muscles.',
      'Use proper form and technique for all exercises.',
      'Don\'t increase intensity too quickly - follow the 10% rule.',
      'Include flexibility and mobility work in your routine.',
      'Listen to your body and rest when needed.',
      'Use appropriate equipment and safety gear.',
      'Stay hydrated to keep muscles and joints lubricated.',
      'Get adequate sleep for proper recovery.',
    ],
    'goal_setting': [
      'Set SMART goals: Specific, Measurable, Achievable, Relevant, Time-bound.',
      'Break big goals into smaller, manageable milestones.',
      'Write down your goals and review them regularly.',
      'Track your progress to stay motivated.',
      'Be realistic about timelines and expectations.',
      'Adjust goals as you progress and learn more.',
      'Focus on process goals, not just outcome goals.',
      'Celebrate achievements along the way.',
    ],
  };

  final Map<String, List<String>> _exerciseAdvice = {
    'push-ups': [
      'Keep your core tight and body straight throughout the movement.',
      'Lower your chest until it nearly touches the floor.',
      'Push up explosively while maintaining control.',
      'Start with modified push-ups if standard ones are too difficult.',
      'Focus on quality over quantity - better form means better results.',
    ],
    'plank': [
      'Keep your body in a straight line from head to heels.',
      'Engage your core muscles throughout the hold.',
      'Breathe normally and avoid holding your breath.',
      'Start with shorter holds and gradually increase duration.',
      'Keep your hips level - don\'t let them sag or pike up.',
    ],
    'cardio': [
      'Start at a comfortable pace and gradually increase intensity.',
      'Monitor your heart rate to stay in the target zone.',
      'Include variety in your cardio routine to prevent boredom.',
      'Warm up and cool down properly to prevent injury.',
      'Stay hydrated and listen to your body during exercise.',
    ],
    'strength': [
      'Focus on compound movements that work multiple muscle groups.',
      'Progressive overload is key - gradually increase weight or reps.',
      'Maintain proper form throughout the entire range of motion.',
      'Allow adequate rest between sets for muscle recovery.',
      'Include both pushing and pulling movements for balance.',
    ],
  };

  final List<String> _greetings = [
    'Hello! I\'m your fitness AI assistant. How can I help you today?',
    'Hi there! Ready to crush your fitness goals? What do you need help with?',
    'Hey! I\'m here to support your fitness journey. What would you like to know?',
    'Welcome! I\'m your personal fitness coach. How can I assist you?',
  ];

  Future<String> generateResponse(String userMessage,
      {Map<String, dynamic>? userData}) async {
    final message = userMessage.toLowerCase().trim();

    // Initialize the model if not already done
    _initializeModel();

    try {
      // Create a fitness-focused prompt
      final prompt = _createFitnessPrompt(message, userData);

      // Generate response using Gemini AI
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        // Fallback to local responses if AI fails
        return _getFallbackResponse(message);
      }
    } catch (e) {
      print('Error calling Gemini AI: $e');
      // Fallback to local responses on error
      return _getFallbackResponse(message);
    }
  }

  // Create a fitness-focused prompt for Gemini AI
  String _createFitnessPrompt(
      String userMessage, Map<String, dynamic>? userData) {
    final userContext = userData != null ? _buildUserContext(userData) : '';

    return '''
You are FitBot, an expert AI fitness coach and personal trainer. You specialize in providing personalized, motivational, and scientifically-backed fitness advice.

User Context: $userContext

User Question: "$userMessage"

Please provide a helpful, encouraging, and personalized response that:
1. Addresses the user's specific question or concern
2. Provides actionable, safe fitness advice
3. Maintains a positive, motivational tone
4. Considers the user's fitness level and goals if provided
5. Keeps responses concise but informative (2-3 sentences)
6. Uses emojis sparingly but effectively
7. Encourages consistency and proper form

Remember: Always prioritize safety, proper form, and gradual progression. If the user asks about medical concerns, recommend consulting a healthcare professional.
''';
  }

  // Build user context string from user data
  String _buildUserContext(Map<String, dynamic> userData) {
    final buffer = StringBuffer();

    if (userData['profile'] != null) {
      final profile = userData['profile'];
      buffer.write('Profile: ${profile['name'] ?? 'User'}, ');
      buffer.write('Age: ${profile['age'] ?? 'Unknown'}, ');
      buffer
          .write('Fitness Level: ${profile['fitness_level'] ?? 'beginner'}, ');
    }

    if (userData['totalWorkouts'] != null) {
      buffer.write('Total Workouts: ${userData['totalWorkouts']}, ');
    }

    if (userData['streak'] != null) {
      buffer.write('Current Streak: ${userData['streak']} days, ');
    }

    return buffer.toString();
  }

  // Fallback response when AI fails
  String _getFallbackResponse(String message) {
    // Handle greetings
    if (_isGreeting(message)) {
      return _getRandomResponse(_greetings);
    }

    // Handle workout-related questions
    if (_containsKeywords(
        message, ['workout', 'exercise', 'training', 'gym'])) {
      return _getWorkoutAdvice(message);
    }

    // Handle nutrition questions
    if (_containsKeywords(
        message, ['food', 'diet', 'nutrition', 'eat', 'meal'])) {
      return _getRandomResponse(_fitnessKnowledge['nutrition_advice']!);
    }

    // Handle motivation requests
    if (_containsKeywords(
        message, ['motivation', 'motivate', 'encourage', 'inspire'])) {
      return _getRandomResponse(_fitnessKnowledge['motivation']!);
    }

    // Handle injury prevention
    if (_containsKeywords(
        message, ['injury', 'hurt', 'pain', 'prevent', 'safe'])) {
      return _getRandomResponse(_fitnessKnowledge['injury_prevention']!);
    }

    // Handle goal setting
    if (_containsKeywords(message, ['goal', 'target', 'plan', 'achieve'])) {
      return _getRandomResponse(_fitnessKnowledge['goal_setting']!);
    }

    // Handle specific exercise questions
    for (String exercise in _exerciseAdvice.keys) {
      if (message.contains(exercise)) {
        return _getRandomResponse(_exerciseAdvice[exercise]!);
      }
    }

    // Handle progress tracking
    if (_containsKeywords(
        message, ['progress', 'track', 'improve', 'better'])) {
      return 'Track your workouts consistently to see progress! Monitor improvements in strength, endurance, and form. Set specific, measurable goals and celebrate milestones! 🎯';
    }

    // Handle rest and recovery
    if (_containsKeywords(message, ['rest', 'recovery', 'sleep', 'tired'])) {
      return _getRestAdvice();
    }

    // Handle general fitness questions
    if (_containsKeywords(
        message, ['fitness', 'health', 'healthy', 'strong'])) {
      return _getRandomResponse(_fitnessKnowledge['workout_tips']!);
    }

    // Default response for unrecognized queries
    return _getDefaultResponse(message);
  }

  bool _isGreeting(String message) {
    final greetings = [
      'hello',
      'hi',
      'hey',
      'good morning',
      'good afternoon',
      'good evening'
    ];
    return greetings.any((greeting) => message.contains(greeting));
  }

  bool _containsKeywords(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }

  String _getRandomResponse(List<String> responses) {
    final random = Random();
    return responses[random.nextInt(responses.length)];
  }

  String _getWorkoutAdvice(String message) {
    if (_containsKeywords(message, ['beginner', 'start', 'new'])) {
      return 'For beginners, start with bodyweight exercises like push-ups, squats, and planks. Focus on proper form and gradually increase intensity. Remember to warm up and cool down properly!';
    }

    if (_containsKeywords(message, ['advanced', 'harder', 'challenge'])) {
      return 'For advanced workouts, try circuit training, HIIT, or compound movements. Increase weight, reps, or duration gradually. Always maintain proper form even with higher intensity!';
    }

    return _getRandomResponse(_fitnessKnowledge['workout_tips']!);
  }

  String _getRestAdvice() {
    return 'Rest and recovery are essential for fitness progress. Aim for 7-9 hours of sleep, take rest days between intense workouts, and listen to your body. Recovery allows muscles to repair and grow stronger!';
  }

  String _getDefaultResponse(String message) {
    final responses = [
      'I\'m here to help with your fitness journey! Try asking about workouts, nutrition, motivation, or specific exercises.',
      'That\'s an interesting question! I can help with workout tips, nutrition advice, motivation, or exercise techniques.',
      'I\'m your fitness AI assistant! I can provide advice on workouts, nutrition, goal setting, and exercise form.',
      'Let me help you with your fitness goals! Ask me about workouts, nutrition, motivation, or any exercise questions.',
    ];

    return _getRandomResponse(responses);
  }

  // Generate personalized workout recommendations
  String generateWorkoutRecommendation(Map<String, dynamic> userProfile) {
    final fitnessLevel = userProfile['fitness_level'] ?? 'beginner';

    String recommendation =
        'Based on your profile, here\'s a personalized recommendation:\n\n';

    if (fitnessLevel == 'beginner') {
      recommendation +=
          'Start with 3-4 workouts per week, 20-30 minutes each. Focus on:\n';
      recommendation += '• Bodyweight exercises (push-ups, squats, planks)\n';
      recommendation += '• Light cardio (walking, jogging)\n';
      recommendation += '• Proper form and technique\n';
    } else if (fitnessLevel == 'intermediate') {
      recommendation +=
          'Aim for 4-5 workouts per week, 30-45 minutes each. Include:\n';
      recommendation += '• Strength training with weights\n';
      recommendation += '• HIIT cardio sessions\n';
      recommendation += '• Flexibility and mobility work\n';
    } else {
      recommendation +=
          'Advanced routine: 5-6 workouts per week, 45-60 minutes each:\n';
      recommendation += '• Heavy strength training\n';
      recommendation += '• Complex movement patterns\n';
      recommendation += '• Sport-specific training\n';
    }

    recommendation +=
        '\nRemember to warm up, cool down, and listen to your body!';

    return recommendation;
  }

  // Generate nutrition advice based on goals
  String generateNutritionAdvice(List<String> goals) {
    String advice = 'Nutrition tips for your goals:\n\n';

    if (goals.contains('weight_loss')) {
      advice += 'For weight loss:\n';
      advice += '• Create a moderate calorie deficit\n';
      advice += '• Focus on lean proteins and vegetables\n';
      advice += '• Limit processed foods and sugar\n';
    }

    if (goals.contains('muscle_gain')) {
      advice += 'For muscle building:\n';
      advice += '• Eat protein with every meal\n';
      advice += '• Include complex carbohydrates\n';
      advice += '• Don\'t skip post-workout nutrition\n';
    }

    if (goals.contains('endurance')) {
      advice += 'For endurance:\n';
      advice += '• Fuel with carbohydrates before workouts\n';
      advice += '• Stay hydrated throughout the day\n';
      advice += '• Include healthy fats for sustained energy\n';
    }

    advice += '\nAlways consult with a nutritionist for personalized advice!';

    return advice;
  }

  // Get motivational quote based on user's current state
  String getMotivationalQuote(Map<String, dynamic>? userData) {
    if (userData != null) {
      final streak = userData['streak'] ?? 0;

      if (streak == 0) {
        return 'Every journey begins with a single step. Start your fitness journey today!';
      } else if (streak < 7) {
        return 'You\'re building momentum! Keep going - consistency is key to success.';
      } else if (streak < 30) {
        return 'Amazing progress! You\'re developing a powerful habit. Keep pushing forward!';
      } else {
        return 'You\'re a fitness champion! Your dedication is inspiring others.';
      }
    }

    return _getRandomResponse(_fitnessKnowledge['motivation']!);
  }
}
