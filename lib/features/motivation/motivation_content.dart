// ============================================================================
// MotivationContent - Centralized motivational quotes by category
// ============================================================================
//
// This feature module encapsulates all motivational content used to inspire
// and encourage users during breaks and focus sessions.
//
// Structure:
// - motivationCategories: List of available quote categories (7 total)
// - quotesByCategory: Map of categories to quote lists
//
// Content Organization:
// 1. General - Universal productivity tips for all languages/cultures
// 2. General Malayalam - category metadata; Malayalam quote text is loaded from JSON
// 3. Focus - Maintaining concentration during work sessions
// 4. Discipline - Building habits and consistency
// 5. Calm - Mindfulness and stress reduction
// 6. Positivity - Encouragement and self-affirmation
// 7. Historic Figures - Inspiring quotes from notable people
//
// Usage:
// - Load via QuoteRotationService.nextQuoteFromMap(category)
// - Default category is 'General' (always available)
// - Falls back to 'General' if user-selected category not found
//
// Language data:
// - Malayalam quotes and stable audio IDs share one JSON catalog.
// - Audio clips are generated from that catalog by the quote generator script.
//
// Localization Strategy:
// - English quotes remain const in 'General'.
// - Malayalam content uses the dedicated catalog categories.

const List<String> motivationCategories = [
  'General',
  'General Malayalam',
  'Focus',
  'Discipline',
  'Calm',
  'Positivity',
  'Historic Figures',
];

const Map<String, List<String>> quotesByCategory = {
  'General': [
    "Use this moment well — it won't come back.",
    "Small steps every hour build the life you want.",
    "Time is the only resource you cannot earn back.",
    "Progress, not perfection, is what time rewards.",
    "Your work right now is compounding silently.",
    'Choose one useful action and give it your full attention.',
    'A small finished task is better than a perfect task postponed.',
    'Use the hour you have, not the hour you wish you had.',
    'Start where you are; the next step becomes clearer in motion.',
    'Protect your attention and your time will follow.',
    'Make today easier for tomorrow by beginning now.',
    'Steady progress is still progress, even when it is quiet.',
    'Give this moment a purpose, then do the next thing well.',
    'The work you complete matters more than the work you merely plan.',
    'A thoughtful pause can make the next hour more intentional.',
    'Turn a large goal into one action you can finish today.',
    'Spend your attention on what moves you forward.',
    'Consistency makes ordinary minutes add up to remarkable change.',
    'Finish one thing before inviting another distraction in.',
    'Make the next choice a little better than the last.',
    'Your pace can be calm and your progress can still be strong.',
    'Begin with the task in front of you; momentum will follow.',
    'A clear priority gives the hour direction.',
    'Do the useful thing now; leave perfection for later.',
    'Let your next action reflect what matters most.',
    'Small commitments kept daily build lasting confidence.',
    'You do not need more time to take the first useful step.',
    'Use your energy deliberately, and the results will accumulate.',
    'A focused beginning can change the shape of the whole day.',
    'Make this minute count by choosing one thing and doing it.',
  ],
  'Focus': [
    'Your attention is your most valuable currency.',
    'An hour of deep work is worth a day of distraction.',
    'One focused hour can change a whole day.',
    'Clarity comes to those who use their time with intention.',
    'Focused effort now creates freedom later.',
    'Choose one priority and let the rest wait for this hour.',
    'Attention grows stronger each time you return to the task.',
    'A quiet hour of focus can outperform a noisy day of rushing.',
    'Put the next distraction aside and finish one meaningful step.',
    'The work deserves your attention, not your anxiety.',
    'Focus is a decision you can renew one moment at a time.',
    'Make the task smaller until the first step feels possible.',
    'Clarity often arrives after you begin, not before.',
    'Protect the beginning of your work from interruptions.',
    'Give one problem your full attention before collecting more.',
    'A short stretch of deep focus can move a stubborn task forward.',
    'Return gently to the work whenever your attention wanders.',
    'Choose progress over checking whether progress is happening.',
    'Let the important task set the pace for this hour.',
    'Close one open loop and free your mind for the next.',
    'Work on what matters before the urgent takes over.',
    'One clear intention can simplify a crowded hour.',
    'Focus on the next action, not the whole mountain.',
    'Your attention is limited; spend it where it can do good.',
    'Keep showing up to the task, especially when it feels ordinary.',
    'A deliberate hour is more valuable than a distracted stretch.',
    'Make room for concentration by removing one source of noise.',
    'Start with the part you understand; momentum can solve the rest.',
    'Deep work begins when you give yourself permission to stay.',
    'Choose a finish line for this session and work toward it.',
  ],
  'Discipline': [
    'Discipline is choosing what you want most over what you want now.',
    'Greatness is built minute by minute.',
    'The best time to start was yesterday. The second best is now.',
    'Consistency over time is unstoppable.',
    'Stay the course. The results are coming.',
    'Discipline is a promise you keep to your future self.',
    'Repeat the small action until it becomes part of your rhythm.',
    'A reliable routine carries you when motivation is quiet.',
    'Keep the commitment modest enough to honor it again tomorrow.',
    'Progress compounds when effort becomes a habit.',
    'Do the planned work before negotiating with your distractions.',
    'Consistency turns intention into evidence.',
    'The next repetition matters, even when nobody sees it.',
    'Build a routine that supports your values, not your mood.',
    'A missed step is a reason to resume, not to abandon the path.',
    'Make the right action easier to repeat.',
    'A clear standard helps you act when enthusiasm fades.',
    'Keep your word to yourself in small, practical ways.',
    'Patience gives discipline time to show its results.',
    'Start again without drama; steady effort is the point.',
    'Choose the habit you can sustain, then practice it today.',
    'A little structure can protect a lot of good intention.',
    'Do not wait to feel ready; let the routine carry you.',
    'One completed promise strengthens the next one.',
    'End this session knowing you did the work you chose.',
    'Make consistency your measure, not intensity.',
    'The ordinary days are where lasting habits are built.',
    'Keep going at a pace you can return to.',
    'Discipline is easier when the next step is already decided.',
    'Show up, do the next useful thing, and repeat.',
  ],
  'Calm': [
    'Be present. This hour is a gift.',
    'Breathe, focus, and make this moment count.',
    'Each hour is a fresh canvas. Paint it well.',
    'You have enough time for what truly matters.',
    'Let this hour be better than the last.',
    'Let your breathing slow before you decide what comes next.',
    'You can move steadily without carrying every worry at once.',
    'Give yourself permission to do one thing at a time.',
    'A gentle pace can still take you somewhere meaningful.',
    'Release what is outside this hour and care for what is here.',
    'Pause your shoulders, soften your breath, and begin again.',
    'There is strength in working calmly instead of rushing.',
    'Let this moment be simple: breathe, choose, continue.',
    'Rest is part of a sustainable effort, not a failure of it.',
    'A quiet mind can make room for a clearer next step.',
    'You do not have to solve everything in this hour.',
    'Take a measured breath and return to what matters now.',
    'Calm attention is still powerful attention.',
    'Leave space between the demand and your response.',
    'Move through the task with patience rather than pressure.',
    'The next moment is a fresh chance to begin gently.',
    'Be kind to yourself while staying present with the work.',
    'A short pause can restore more than another rushed effort.',
    'Let urgency settle before choosing your direction.',
    'Give yourself the same patience you would offer a friend.',
    'Breathe out the rush; keep the purpose.',
    'You may slow down and still keep moving forward.',
    'Calm is something you can practice in small moments.',
    'Set down one worry and return to one useful action.',
    'Let this hour be steady, clear, and enough.',
  ],
  'Positivity': [
    'What you do right now shapes who you become.',
    'Your future self will thank you for the work you do now.',
    'Do something today that your future self will be proud of.',
    'Momentum is built one intentional moment at a time.',
    "A year from now you'll wish you had started today.",
    'Your effort today is a gift to the person you are becoming.',
    'There is room to improve, and you have already begun.',
    'Notice how much easier the next step feels after starting.',
    'You can make a meaningful change with one good decision.',
    'A difficult beginning does not decide how the story ends.',
    'Give yourself credit for returning to the work.',
    'Every skill you admire was once practiced imperfectly.',
    'Let hope be practical: take the next step.',
    'Your progress counts even when it is not visible yet.',
    'The future is shaped by the choices you make repeatedly.',
    'You are allowed to begin again with what you know now.',
    'One encouraging thought can help you take one useful action.',
    'Small wins are real wins; let them build your momentum.',
    'Keep going; the effort you make today has a place in tomorrow.',
    'You can be proud of steady effort, not only finished results.',
    'A better day can begin with the next choice.',
    'Your potential grows when you give it consistent practice.',
    'Let your actions be evidence that change is possible.',
    'You have handled hard moments before; meet this one step by step.',
    'Progress is still happening while you are learning.',
    'The work you do now can make future work easier.',
    'Choose encouragement that helps you act, then act.',
    'Give your goals time to grow and yourself room to learn.',
    'You are closer than you were before you began.',
    'A hopeful mind and a practical next step work well together.',
  ],
  'Historic Figures': [
    'Aristotle said: We are what we repeatedly do. Excellence, then, is a habit.',
    'Leonardo da Vinci said: Time stays long enough for anyone who will use it.',
    'Benjamin Franklin said: Lost time is never found again.',
    'Maya Angelou said: Nothing will work unless you do.',
    'Bruce Lee said: The successful warrior is the average person, with laser-like focus.',
    'Benjamin Franklin wrote, “Well done is better than well said.”',
    'Benjamin Franklin advised, “Never leave that till tomorrow which you can do today.”',
    'Benjamin Franklin observed, “Time is money.”',
    'Laozi taught, “A journey of a thousand miles begins with a single step.”',
    'Seneca wrote, “While we are postponing, life speeds by.”',
    'Seneca advised, “Begin at once to live, and count each separate day as a separate life.”',
    'Marcus Aurelius wrote, “The happiness of your life depends upon the quality of your thoughts.”',
  ],
};
