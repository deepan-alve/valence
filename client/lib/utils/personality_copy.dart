import 'dart:math';

/// Centralizes all personality-toggle-aware copy for the Group screen.
///
/// When personality is ON (default): WhatsApp group chat energy —
/// witty, supportive, the kind of messages a college friend would send.
/// When personality is OFF: clean, informational, zero fluff.
///
/// NEVER shaming. NEVER punitive. Even "miss" events are supportive.
class PersonalityCopy {
  final bool personalityOn;

  const PersonalityCopy({required this.personalityOn});

  static final _random = Random();

  // ---------------------------------------------------------------------------
  // Feed messages
  // ---------------------------------------------------------------------------

  /// Completion event in the feed.
  String completionMessage(String name, String habitName, {String? plugin}) {
    if (!personalityOn) {
      final suffix = plugin != null ? ' (verified via $plugin)' : '';
      return '$name completed $habitName$suffix';
    }

    final templates = [
      '$name just crushed $habitName. Respect. 🫡',
      '$name knocked out $habitName like it was nothing',
      '$name is LOCKED IN — $habitName done ✅',
      'Another one. $name x $habitName. You already know. 🔥',
      '$name said "$habitName? Easy." and meant it',
      '$name checked off $habitName before most people check their phone',
      '$habitName? Handled. $name doesn\'t miss. 💪',
      '$name just did $habitName. That\'s called showing up.',
    ];
    final msg = templates[_random.nextInt(templates.length)];
    if (plugin != null) {
      return '$msg  ·  verified via $plugin';
    }
    return msg;
  }

  /// Miss event in the feed. ALWAYS supportive, NEVER shaming.
  String missMessage(String name, String habitName) {
    if (!personalityOn) {
      return '$name missed $habitName today. Send some support?';
    }

    final templates = [
      '$name had a rough one with $habitName. We all have those days — drop a kudos? 💛',
      'Off day for $name on $habitName. Rest is part of the process. Send love?',
      '$name took an L on $habitName today but we don\'t judge here. Support?',
      '$habitName didn\'t happen for $name today. Tomorrow is a reset. 🤍',
      '$name missed $habitName but honestly? Consistency > perfection. Send a vibe?',
      'No $habitName from $name today. It happens. They\'ll bounce back. 💪',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  /// Nudge event in the feed. The actual LLM message is private —
  /// the feed only reveals that a nudge happened.
  String nudgeFeedMessage(String senderName, String receiverName) {
    if (!personalityOn) {
      return '$senderName nudged $receiverName';
    }

    final templates = [
      '$senderName just gave $receiverName the look 👀💪',
      '$senderName nudged $receiverName. Accountability hits different.',
      '$senderName said "yo $receiverName, we need you" 💬',
      '$senderName → $receiverName: gentle push incoming 🫳',
      '$receiverName just got the friendliest nudge from $senderName 🤝',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  /// Kudos event in the feed.
  String kudosFeedMessage(String senderName, String receiverName) {
    if (!personalityOn) {
      return '$senderName sent kudos to $receiverName';
    }

    final templates = [
      '$senderName is hyping up $receiverName rn 🔥',
      '$senderName → $receiverName: absolute legend status confirmed',
      '$senderName gave $receiverName their flowers 💐',
      '$receiverName is getting the recognition they deserve from $senderName',
      '$senderName said "$receiverName, you\'re different." 👏',
      '$senderName just threw $receiverName some major props 🙌',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  /// Status+Norm message (streak milestone + group comparison).
  String statusNormMessage(String name, int streakDays) {
    if (!personalityOn) {
      return '$name reached a $streakDays-day streak. Most of the group is staying consistent this week.';
    }

    final templates = [
      '$name is COOKING 🔥 $streakDays-day streak! Most of y\'all are keeping up too. Squad goals.',
      '$streakDays days straight for $name. That\'s not luck, that\'s discipline. The rest of the group is vibing too 📈',
      'Yo $name is on a $streakDays-day tear and honestly the whole group is eating rn 🍽️',
      '$name: $streakDays days. No breaks. The group energy is immaculate this week.',
      '$streakDays-day streak from $name! And the group? Also crushing it. We love to see it. 🫶',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  /// Chain link result at end of day.
  String chainLinkMessage(String linkType, int completed, int total) {
    if (!personalityOn) {
      switch (linkType.toLowerCase()) {
        case 'gold':
          return 'Today\'s link: Gold. All $total members completed.';
        case 'silver':
          return 'Today\'s link: Silver. $completed/$total completed.';
        case 'broken':
          return 'Chain broken today. $completed/$total completed.';
        default:
          return 'Chain link update: $completed/$total completed.';
      }
    }

    switch (linkType.toLowerCase()) {
      case 'gold':
        return 'Today\'s link: 🥇 GOLD! Every single person showed up. $total/$total. We are HIM. 🔥';
      case 'silver':
        final silverTemplates = [
          'Silver link today — $completed/$total pulled through. So close to gold. Tomorrow? 💪',
          '$completed/$total ain\'t bad. Silver link earned. Gold is RIGHT THERE though. 🥈',
        ];
        return silverTemplates[_random.nextInt(silverTemplates.length)];
      case 'broken':
        final brokenTemplates = [
          'Chain broke today. $completed/$total. It stings but we reset tomorrow. Together. 🤝',
          'Broken link. $completed/$total. We\'ve bounced back before and we will again. 💪',
        ];
        return brokenTemplates[_random.nextInt(brokenTemplates.length)];
      default:
        return 'Chain update: $completed/$total completed.';
    }
  }

  /// Milestone: a habit reached a goal graduation stage.
  String milestoneMessage(String name, String habitName, String stage, int days) {
    if (!personalityOn) {
      return '$name\'s $habitName reached $stage ($days days).';
    }

    final templates = {
      'Ignition': [
        '$name just lit the fuse on $habitName — $days days in! Ignition unlocked 🚀',
        '$habitName is officially a thing for $name. $days days. Ignition. 🔥',
      ],
      'Foundation': [
        '$name hit Foundation on $habitName. $days days. This is where it gets real. 🧱',
        '$days days of $habitName from $name. Foundation locked in. Building something fr. 💪',
      ],
      'Momentum': [
        '$days DAYS. $name\'s $habitName hit Momentum. Unstoppable energy. 🌊',
        '$name x $habitName = $days days of Momentum. This is not a drill. 📈',
      ],
      'Formed': [
        '$name GRADUATED $habitName at $days days. That\'s a whole identity shift. 🎓🔥',
        'SIXTY-SIX DAYS. $name\'s $habitName is now part of their DNA. Formed. 🏆',
      ],
    };

    final stageTemplates = templates[stage] ?? [
      '$name\'s $habitName reached $stage at $days days!',
    ];
    return stageTemplates[_random.nextInt(stageTemplates.length)];
  }

  /// Streak freeze used.
  String streakFreezeMessage(String name) {
    if (!personalityOn) {
      return '$name used a streak freeze to protect the chain.';
    }

    final templates = [
      '$name activated the streak freeze. Chain protected. Smart move ❄️🛡️',
      '$name pulled out the freeze card. The streak lives another day. ❄️',
      'Streak freeze deployed by $name. Crisis averted. The chain is safe. 🧊',
      '$name said "not today, broken chain" and used a streak freeze ❄️💪',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  // ---------------------------------------------------------------------------
  // Toasts
  // ---------------------------------------------------------------------------

  /// Toast shown when user completes a habit on the Group screen.
  String completionToast() {
    if (!personalityOn) return 'Habit completed';

    final templates = [
      'Beast mode activated 🔥',
      'One more in the bag 💰',
      'That\'s how it\'s done 💪',
      'You\'re different. Fr. 🫡',
      'No days off mentality 📈',
      'Stack those W\'s 🏆',
      'Built different ✅',
      'Another one 🔑',
      'Lock in era continues 🔒',
      'Main character energy 🎬',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  /// Toast shown after sending a perfect day notification.
  String perfectDayToast() {
    if (!personalityOn) return 'All habits completed today';

    final templates = [
      'All habits?? ALL of them?? You\'re actually insane (compliment) 🤯',
      'Perfect day unlocked. You are built different. 🏆',
      'Clean sweep. Every. Single. Habit. You ate today. 🍽️',
      'Full send. Perfect day. This is what legends look like. 🔥',
      'Not one missed. Not one skipped. Goated behavior fr. 👑',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  // ---------------------------------------------------------------------------
  // Empty states
  // ---------------------------------------------------------------------------

  /// Solo mode empty state: title.
  String get emptyStateGroupTitle {
    if (!personalityOn) return 'No group yet';
    return 'Your habits are lonely. Give them friends.';
  }

  /// Solo mode empty state: body.
  String get emptyStateGroupBody {
    if (!personalityOn) {
      return 'Create or join a group of 2–6 friends to track habits together.';
    }
    return 'Habits hit different when your whole squad is grinding together. Create a crew or jump into one.';
  }

  /// Solo mode social proof line.
  String get emptyStateSocialProof {
    if (!personalityOn) {
      return 'Groups with 4+ members have 3x better retention.';
    }
    return 'Groups with 4+ people are literally 3x more likely to stick with it. Just saying. 📊';
  }

  // ---------------------------------------------------------------------------
  // Nudge sheet
  // ---------------------------------------------------------------------------

  /// Nudge confirmation title.
  String nudgeSheetTitle(String receiverName) {
    if (!personalityOn) return 'Nudge $receiverName?';
    return 'Give $receiverName a friendly push? 🫳';
  }

  /// Nudge confirmation body.
  String nudgeSheetBody(String receiverName) {
    if (!personalityOn) {
      return 'An AI-generated motivational message will be sent privately to $receiverName.';
    }
    return 'We\'ll craft a personalized message for $receiverName. They\'ll only see it in their notifications — no one else will know what it says. 🤫';
  }

  /// Toast after sending a nudge.
  String nudgeSentToast(String receiverName) {
    if (!personalityOn) return 'Nudge sent to $receiverName';
    return 'Nudge deployed to $receiverName 💪 you\'re a real one';
  }

  /// Already nudged today.
  String get nudgeAlreadySent {
    if (!personalityOn) return 'Already nudged today';
    return 'Easy tiger — you already nudged them today 😂';
  }

  /// Nudge disabled (user hasn't completed their own habits).
  String get nudgeDisabledReason {
    if (!personalityOn) return 'Complete your habits first';
    return 'Finish your own habits first, then you can nudge 😏';
  }

  // ---------------------------------------------------------------------------
  // Streak freeze sheet
  // ---------------------------------------------------------------------------

  /// Streak freeze title.
  String get freezeSheetTitle {
    if (!personalityOn) return 'Use a Streak Freeze?';
    return 'Deploy the freeze? ❄️🛡️';
  }

  /// Streak freeze body.
  String freezeSheetBody(int cost) {
    if (!personalityOn) {
      return 'This will protect today\'s group chain if the group falls below 75%. Cost: $cost consistency points.';
    }
    return 'This bad boy protects the chain even if the group doesn\'t hit 75% today. It\'ll cost you $cost consistency points though. Worth it? 🤔';
  }

  /// Streak freeze success toast.
  String get freezeActivatedToast {
    if (!personalityOn) return 'Streak freeze activated. Chain protected today.';
    return 'Freeze activated! The streak is safe. You\'re the group MVP today. ❄️🏆';
  }

  /// Insufficient points for freeze.
  String freezeInsufficientPoints(int needed) {
    if (!personalityOn) return 'You need $needed more consistency points.';
    return 'You\'re $needed points short. Keep completing habits to stack those points! 💰';
  }

  // ---------------------------------------------------------------------------
  // Leaderboard
  // ---------------------------------------------------------------------------

  /// Last week's MVP card.
  String lastWeekMvp(String name) {
    if (!personalityOn) return 'Last week\'s #1: $name';
    return 'Last week\'s MVP: $name 👑 show them some love';
  }

  /// Leaderboard baseline caption.
  String get leaderboardCaption {
    if (!personalityOn) return 'Based on each member\'s personal baseline';
    return 'Based on YOUR baseline — every point is earned, not given 📈';
  }
}
