import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession instance = AppSession._();

  bool _supabaseEnabled = false;
  String? _demoEmail;

  bool get supabaseEnabled => _supabaseEnabled;

  String? get currentEmail {
    if (_supabaseEnabled) {
      return Supabase.instance.client.auth.currentUser?.email;
    }
    return _demoEmail;
  }

  bool get isSignedIn => currentEmail != null;

  Future<void> bootstrap() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      _supabaseEnabled = false;
      notifyListeners();
      return;
    }

    final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
    final hasValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;

    if (url.isEmpty || anonKey.isEmpty || !hasValidUrl) {
      _supabaseEnabled = false;
      notifyListeners();
      return;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _supabaseEnabled = true;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    if (_supabaseEnabled) {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } else {
      _demoEmail = email;
    }
    notifyListeners();
  }

  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    if (_supabaseEnabled) {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      notifyListeners();
      if (response.session == null) {
        return const SignUpResult(
          signedIn: false,
          message: 'Check your email to confirm your account, then log in.',
        );
      }
      return const SignUpResult(signedIn: true);
    }

    _demoEmail = email;
    notifyListeners();
    return const SignUpResult(signedIn: true);
  }

  Future<void> sendPasswordReset(String email) async {
    if (_supabaseEnabled) {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      return;
    }
  }

  Future<void> signOut() async {
    if (_supabaseEnabled) {
      await Supabase.instance.client.auth.signOut();
    } else {
      _demoEmail = null;
    }
    notifyListeners();
  }
}

class SignUpResult {
  const SignUpResult({required this.signedIn, this.message});

  final bool signedIn;
  final String? message;
}

class DemoStore extends ChangeNotifier {
  DemoStore._();

  static final DemoStore instance = DemoStore._();

  final List<CommunityMember> _communityMembers = [
    const CommunityMember(
      id: 'topo',
      name: 'Topo R.',
      avatarUrl: 'https://i.pravatar.cc/150?img=53',
      subtitle: 'Gaborone-FNB',
      score: 89,
      scoreColor: Color(0xFF00BFA5),
      scoreLabel: 'Trusted',
      about:
          'Final-year student buying textbooks for exams. Has repaid every request on time.',
      requestDescription:
          'Need P1,500 for university textbooks, paying back end of month, 30% interest',
      targetAmount: 1500,
      fundedAmount: 450,
      returnAmount: 1950,
      dueIn: '30 days',
      isContact: true,
      isHighTrust: true,
      isQuickReturn: false,
    ),
    const CommunityMember(
      id: 'lefika',
      name: 'Lefika L.',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      subtitle: 'Gaborone-Orange Money',
      score: 69,
      scoreColor: Color(0xFFFF8F00),
      scoreLabel: 'Fair',
      about: 'Teacher at a primary school. Has a clean repayment history.',
      requestDescription:
          'Need P500 for car repair — paying back in 3 weeks with 5% interest',
      targetAmount: 500,
      fundedAmount: 0,
      returnAmount: 525,
      dueIn: '21 days',
      isContact: false,
      isHighTrust: false,
      isQuickReturn: true,
    ),
    const CommunityMember(
      id: 'alex',
      name: 'Alex W.',
      avatarUrl: 'https://i.pravatar.cc/150?img=68',
      subtitle: 'Gaborone-FNB',
      score: 55,
      scoreColor: Color(0xFFE53935),
      scoreLabel: 'Needs review',
      about:
          'Runs a small delivery business and wants to bridge fuel costs for the week.',
      requestDescription:
          'Need P1,300 to restock fuel and mobile data, paying back in 3 weeks with 19% interest',
      targetAmount: 1300,
      fundedAmount: 0,
      returnAmount: 1550,
      dueIn: '3 weeks',
      isContact: false,
      isHighTrust: false,
      isQuickReturn: true,
    ),
  ];

  final List<AppTransaction> _transactions = [
    AppTransaction(
      title: 'Lent to Topo',
      subtitle: 'Today, 9:14am',
      amount: 300,
      isCredit: false,
      icon: HugeIcons.strokeRoundedArrowUpRight01,
      category: TransactionCategory.funding,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppTransaction(
      title: 'Repayment from Tau',
      subtitle: 'Mar 12',
      amount: 420,
      isCredit: true,
      icon: HugeIcons.strokeRoundedArrowDownLeft01,
      category: TransactionCategory.repayment,
      createdAt: DateTime(2026, 3, 12, 11, 30),
    ),
  ];

  final List<AppNotificationItem> _notifications = [
    AppNotificationItem(
      title: 'Repayment received',
      message: 'Tau paid back P420 on March 12, 2026.',
      createdAt: DateTime(2026, 3, 12, 11, 30),
    ),
    AppNotificationItem(
      title: 'Welcome back',
      message: 'Your wallet and community activity are ready.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  double _walletBalance = 500;
  double _extraFunding = 0;

  List<CommunityMember> get communityMembers =>
      List<CommunityMember>.unmodifiable(_communityMembers);

  List<AppTransaction> get transactions =>
      List<AppTransaction>.unmodifiable(_transactions);

  List<AppNotificationItem> get notifications =>
      List<AppNotificationItem>.unmodifiable(_notifications);

  double get walletBalance => _walletBalance;

  String get walletBalanceText => formatPula(_walletBalance);

  String get totalLentText => formatPula(1348 + _extraFunding);

  String get interestEarnedText => formatPula(538 + (_extraFunding * 0.08));

  CommunityMember memberById(String? id) {
    if (id == null) return _communityMembers[1];
    return _communityMembers.firstWhere(
      (member) => member.id == id,
      orElse: () => _communityMembers[1],
    );
  }

  FundingResult fundMember({required String memberId, required double amount}) {
    if (amount <= 0) {
      return const FundingResult(
        success: false,
        message: 'Enter a valid amount.',
      );
    }

    final index = _communityMembers.indexWhere(
      (member) => member.id == memberId,
    );
    if (index == -1) {
      return const FundingResult(
        success: false,
        message: 'Borrower not found.',
      );
    }

    final member = _communityMembers[index];
    final remaining = member.remainingAmount;

    if (remaining <= 0) {
      return const FundingResult(
        success: false,
        message: 'This request is already fully funded.',
      );
    }

    if (amount > _walletBalance) {
      return FundingResult(
        success: false,
        message: 'You only have ${formatPula(_walletBalance)} available.',
      );
    }

    final fundedAmount = amount > remaining ? remaining : amount;
    _communityMembers[index] = member.copyWith(
      fundedAmount: member.fundedAmount + fundedAmount,
    );
    _walletBalance -= fundedAmount;
    _extraFunding += fundedAmount;

    final timestamp = DateTime.now();
    _transactions.insert(
      0,
      AppTransaction(
        title: 'Funded ${member.name}',
        subtitle: formatActivityTime(timestamp),
        amount: fundedAmount,
        isCredit: false,
        icon: HugeIcons.strokeRoundedArrowUpRight01,
        category: TransactionCategory.funding,
        createdAt: timestamp,
      ),
    );
    _notifications.insert(
      0,
      AppNotificationItem(
        title: 'Funding sent',
        message: 'You funded ${member.name} with ${formatPula(fundedAmount)}.',
        createdAt: timestamp,
      ),
    );

    notifyListeners();
    return FundingResult(
      success: true,
      message: 'You funded ${member.name} with ${formatPula(fundedAmount)}.',
    );
  }

  FundingResult topUpWallet(double amount) {
    if (amount <= 0) {
      return const FundingResult(
        success: false,
        message: 'Enter a valid amount.',
      );
    }

    _walletBalance += amount;
    final timestamp = DateTime.now();
    _transactions.insert(
      0,
      AppTransaction(
        title: 'Wallet top up',
        subtitle: formatActivityTime(timestamp),
        amount: amount,
        isCredit: true,
        icon: HugeIcons.strokeRoundedPlusSign,
        category: TransactionCategory.wallet,
        createdAt: timestamp,
      ),
    );
    _notifications.insert(
      0,
      AppNotificationItem(
        title: 'Wallet updated',
        message: 'You topped up ${formatPula(amount)}.',
        createdAt: timestamp,
      ),
    );
    notifyListeners();
    return FundingResult(
      success: true,
      message: 'Wallet topped up by ${formatPula(amount)}.',
    );
  }

  FundingResult transferFromWallet({
    required double amount,
    required String recipient,
  }) {
    if (amount <= 0) {
      return const FundingResult(
        success: false,
        message: 'Enter a valid amount.',
      );
    }
    if (recipient.trim().isEmpty) {
      return const FundingResult(success: false, message: 'Enter a recipient.');
    }
    if (amount > _walletBalance) {
      return FundingResult(
        success: false,
        message: 'You only have ${formatPula(_walletBalance)} available.',
      );
    }

    _walletBalance -= amount;
    final timestamp = DateTime.now();
    _transactions.insert(
      0,
      AppTransaction(
        title: 'Transfer to ${recipient.trim()}',
        subtitle: formatActivityTime(timestamp),
        amount: amount,
        isCredit: false,
        icon: HugeIcons.strokeRoundedArrowLeftRight,
        category: TransactionCategory.wallet,
        createdAt: timestamp,
      ),
    );
    _notifications.insert(
      0,
      AppNotificationItem(
        title: 'Transfer complete',
        message: 'You sent ${formatPula(amount)} to ${recipient.trim()}.',
        createdAt: timestamp,
      ),
    );
    notifyListeners();
    return FundingResult(
      success: true,
      message: 'Transferred ${formatPula(amount)} to ${recipient.trim()}.',
    );
  }

  FundingResult submitRequest({required double amount, required String note}) {
    if (amount <= 0) {
      return const FundingResult(
        success: false,
        message: 'Enter a valid amount.',
      );
    }

    final timestamp = DateTime.now();
    final summary = note.trim().isEmpty ? 'No note added.' : note.trim();
    _notifications.insert(
      0,
      AppNotificationItem(
        title: 'Request submitted',
        message: 'Your request for ${formatPula(amount)} is live. $summary',
        createdAt: timestamp,
      ),
    );
    notifyListeners();
    return FundingResult(
      success: true,
      message: 'Request submitted for ${formatPula(amount)}.',
    );
  }

  String buildKutloReply(String question) {
    final lower = question.toLowerCase();
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(lower);
    final amount = double.tryParse(match?.group(1) ?? '');

    if (lower.contains('lend') && amount != null) {
      final conservative = amount * 0.25;
      return 'If you want to stay liquid, cap this loan near '
          '${formatPula(conservative)} and keep the rest for wallet transfers and emergencies.';
    }

    if (lower.contains('borrow') || lower.contains('request')) {
      return 'Keep your request specific, short, and tied to a repayment date. '
          'People fund faster when they can see what the money solves and when it returns.';
    }

    if (lower.contains('wallet') || lower.contains('balance')) {
      return 'Your wallet works best as a buffer. Keep enough to cover one transfer and one new funding opportunity.';
    }

    return 'Start with your goal, amount, and repayment timing. I can help you size the request, compare returns, or decide whether to lend now.';
  }
}

enum TransactionCategory { funding, repayment, wallet }

class FundingResult {
  const FundingResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class CommunityMember {
  const CommunityMember({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.subtitle,
    required this.score,
    required this.scoreColor,
    required this.scoreLabel,
    required this.about,
    required this.requestDescription,
    required this.targetAmount,
    required this.fundedAmount,
    required this.returnAmount,
    required this.dueIn,
    required this.isContact,
    required this.isHighTrust,
    required this.isQuickReturn,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String subtitle;
  final int score;
  final Color scoreColor;
  final String scoreLabel;
  final String about;
  final String requestDescription;
  final double targetAmount;
  final double fundedAmount;
  final double returnAmount;
  final String dueIn;
  final bool isContact;
  final bool isHighTrust;
  final bool isQuickReturn;

  double get progress => targetAmount == 0 ? 0 : fundedAmount / targetAmount;

  double get remainingAmount {
    final remaining = targetAmount - fundedAmount;
    return remaining < 0 ? 0 : remaining;
  }

  String get progressText => '${(progress * 100).round()}%';

  CommunityMember copyWith({double? fundedAmount}) {
    return CommunityMember(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      subtitle: subtitle,
      score: score,
      scoreColor: scoreColor,
      scoreLabel: scoreLabel,
      about: about,
      requestDescription: requestDescription,
      targetAmount: targetAmount,
      fundedAmount: fundedAmount ?? this.fundedAmount,
      returnAmount: returnAmount,
      dueIn: dueIn,
      isContact: isContact,
      isHighTrust: isHighTrust,
      isQuickReturn: isQuickReturn,
    );
  }
}

class AppTransaction {
  const AppTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.icon,
    required this.category,
    required this.createdAt,
  });

  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final List<List<dynamic>> icon;
  final TransactionCategory category;
  final DateTime createdAt;

  String get amountText => '${isCredit ? '+' : '-'}${formatPula(amount)}';

  Color get amountColor =>
      isCredit ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
}

class AppNotificationItem {
  const AppNotificationItem({
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final String title;
  final String message;
  final DateTime createdAt;
}

String displayNameFromEmail(String? email) {
  if (email == null || email.trim().isEmpty) return 'there';
  final name = email.split('@').first.trim();
  if (name.isEmpty) return 'there';
  return '${name[0].toUpperCase()}${name.substring(1)}';
}

String formatPula(double amount) {
  final value = amount.abs();
  final whole = value.truncate();
  final fraction = ((value - whole) * 100).round();
  final wholeText = _formatGroupedNumber(whole);
  if (fraction == 0) {
    return 'P$wholeText';
  }
  return 'P$wholeText.${fraction.toString().padLeft(2, '0')}';
}

String formatActivityTime(DateTime value) {
  final now = DateTime.now();
  if (_isSameDay(now, value)) {
    return 'Today, ${_formatClock(value)}';
  }
  return '${_monthName(value.month)} ${value.day}';
}

String formatNotificationTime(DateTime value) {
  final now = DateTime.now();
  final difference = now.difference(value);

  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes <= 0 ? 1 : difference.inMinutes;
    return '$minutes min ago';
  }
  if (difference.inHours < 24 && _isSameDay(now, value)) {
    return '${difference.inHours}h ago';
  }
  return '${_monthName(value.month)} ${value.day}, ${value.year}';
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _formatClock(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  final suffix = value.hour >= 12 ? 'pm' : 'am';
  return '$hour:${value.minute.toString().padLeft(2, '0')}$suffix';
}

String _formatGroupedNumber(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);
    final remaining = digits.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(' ');
    }
  }

  return buffer.toString();
}

String _monthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}
