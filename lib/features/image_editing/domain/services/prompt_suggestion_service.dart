import 'dart:math';

class PromptSuggestionService {
  final List<String> _prompts = const [
    'A futuristic city at sunset, cyberpunk style',
    'A serene forest with a hidden waterfall, fantasy art',
    'An astronaut floating in space, looking at Earth, realistic',
    'A cozy cafe interior with warm lighting, impressionistic',
    'A majestic dragon flying over a snowy mountain, digital painting',
    'A vintage car driving on a desert road, cinematic',
    'A whimsical treehouse village, cartoon style',
    'An underwater city with bioluminescent creatures, sci-fi',
    'A bustling marketplace in a medieval town, detailed illustration',
    'A lone wolf howling at the moon, minimalist',
    'A robot playing chess with a human, futuristic concept',
    'A field of sunflowers under a clear blue sky, vibrant colors',
    'An ancient ruin overgrown with vines, mysterious atmosphere',
    'A spaceship landing on an alien planet, epic scene',
    'A cup of coffee with steam rising, macro photography',
    'A cat wearing a tiny crown, regal portrait',
    'A bookshelf filled with old books, warm and inviting',
    'A samurai warrior in a bamboo forest, traditional Japanese art',
    'A vibrant coral reef with colorful fish, underwater photography',
    'A wizard casting a spell in a dark cave, magical realism',
  ];

  String getRandomPrompt() {
    final random = Random();
    return _prompts[random.nextInt(_prompts.length)];
  }
}