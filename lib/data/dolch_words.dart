/// Dolch sight word lists, grouped by level.
///
/// Public domain word lists compiled by Edward Dolch. The player picks a
/// level before playing, and games only pull words from the chosen level.
library;

class DolchLevel {
  final String id;
  final String label;
  final List<String> words;

  const DolchLevel({required this.id, required this.label, required this.words});
}

const List<String> prePrimerWords = [
  'a', 'and', 'away', 'big', 'blue', 'can', 'come', 'down', 'find', 'for',
  'funny', 'go', 'help', 'here', 'I', 'in', 'is', 'it', 'jump', 'little',
  'look', 'make', 'me', 'my', 'not', 'one', 'play', 'red', 'run', 'said',
  'see', 'the', 'three', 'to', 'two', 'up', 'we', 'where', 'yellow', 'you',
];

const List<String> primerWords = [
  'all', 'am', 'are', 'at', 'ate', 'be', 'black', 'brown', 'but', 'came',
  'did', 'do', 'eat', 'four', 'get', 'good', 'have', 'he', 'into', 'like',
  'must', 'new', 'no', 'now', 'on', 'our', 'out', 'please', 'pretty', 'ran',
  'ride', 'saw', 'say', 'she', 'so', 'soon', 'that', 'there', 'they', 'this',
  'too', 'under', 'want', 'was', 'well', 'went', 'what', 'white', 'who',
  'will', 'with', 'yes',
];

const List<String> firstGradeWords = [
  'after', 'again', 'an', 'any', 'as', 'ask', 'by', 'could', 'every', 'fly',
  'from', 'give', 'going', 'had', 'has', 'her', 'him', 'his', 'how', 'just',
  'know', 'let', 'live', 'may', 'of', 'old', 'once', 'open', 'over', 'put',
  'round', 'some', 'stop', 'take', 'thank', 'them', 'then', 'think', 'walk',
  'were', 'when',
];

const List<String> secondGradeWords = [
  'always', 'around', 'because', 'been', 'before', 'best', 'both', 'buy',
  'call', 'cold', 'does', "don't", 'fast', 'first', 'five', 'found', 'gave',
  'goes', 'green', 'its', 'made', 'many', 'off', 'or', 'pull', 'read',
  'right', 'sing', 'sit', 'sleep', 'tell', 'their', 'these', 'those', 'upon',
  'us', 'use', 'very', 'wash', 'which', 'why', 'wish', 'work', 'would',
  'write', 'your',
];

const List<String> thirdGradeWords = [
  'about', 'better', 'bring', 'carry', 'clean', 'cut', 'done', 'draw',
  'drink', 'eight', 'fall', 'far', 'full', 'got', 'grow', 'hold', 'hot',
  'hurt', 'if', 'keep', 'kind', 'laugh', 'light', 'long', 'much', 'myself',
  'never', 'only', 'own', 'pick', 'seven', 'shall', 'show', 'six', 'small',
  'start', 'ten', 'today', 'together', 'try', 'warm',
];

/// Optional extra content — nouns are not part of the core five levels.
const List<String> dolchNouns = [
  'apple', 'baby', 'back', 'ball', 'bear', 'bed', 'bell', 'bird', 'birthday',
  'boat', 'box', 'boy', 'bread', 'brother', 'cake', 'car', 'cat', 'chair',
  'chicken', 'children', 'Christmas', 'coat', 'corn', 'cow', 'day', 'dog',
  'doll', 'door', 'duck', 'egg', 'eye', 'farm', 'farmer', 'father', 'feet',
  'fire', 'fish', 'floor', 'flower', 'game', 'garden', 'girl', 'goodbye',
  'grass', 'ground', 'hand', 'head', 'hill', 'home', 'horse', 'house',
  'kitty', 'leg', 'letter', 'man', 'men', 'milk', 'money', 'morning',
  'mother', 'name', 'nest', 'night', 'paper', 'party', 'picture', 'pig',
  'rabbit', 'rain', 'ring', 'robin', 'Santa Claus', 'school', 'seed',
  'sheep', 'shoe', 'sister', 'snow', 'song', 'squirrel', 'stick', 'street',
  'sun', 'table', 'thing', 'time', 'top', 'toy', 'tree', 'watch', 'water',
  'way', 'wind', 'window', 'wood',
];

/// Ordered list of playable Dolch levels, including the optional noun set.
const List<DolchLevel> dolchLevels = [
  DolchLevel(id: 'pre_primer', label: 'Pre-Primer', words: prePrimerWords),
  DolchLevel(id: 'primer', label: 'Primer', words: primerWords),
  DolchLevel(id: 'first_grade', label: 'First Grade', words: firstGradeWords),
  DolchLevel(id: 'second_grade', label: 'Second Grade', words: secondGradeWords),
  DolchLevel(id: 'third_grade', label: 'Third Grade', words: thirdGradeWords),
  DolchLevel(id: 'nouns', label: 'Nouns', words: dolchNouns),
];
