
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app_routes.dart';
import '../../../../data/repositories/home_repository.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../ui/app_theme.dart';

class HomeSearchSheet extends StatefulWidget {
  const HomeSearchSheet({
    super.key,
    required this.repository,
  });

  final HomeRepository repository;

  static void show(
    BuildContext context, {
    required HomeRepository repository,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) =>
          HomeSearchSheet(repository: repository),
    );
  }

  @override
  State<HomeSearchSheet> createState() =>
      _HomeSearchSheetState();
}

class _HomeSearchSheetState
    extends State<HomeSearchSheet> {
  final _controller = TextEditingController();
  String _query = '';
  List<Map<String, dynamic>> _borrowerResults = [];

  // HugeIcons values are List<List<dynamic>>
  static final _quickLinks = [
    _SearchItem(
      title: 'Community',
      subtitle: 'Browse borrowers',
      icon: HugeIcons.strokeRoundedUserGroup,
      route: AppRoutes.community,
    ),
    _SearchItem(
      title: 'Ask Kutlo AI',
      subtitle: 'Get advice on lending',
      icon: HugeIcons.strokeRoundedAiMagic,
      route: AppRoutes.askKutlo,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onQueryChanged(String value) async {
    final q = value.trim();
    setState(() => _query = q);
    if (q.isEmpty) {
      setState(() => _borrowerResults = []);
      return;
    }
    final results =
        await widget.repository.searchBorrowers(q);
    if (mounted) setState(() => _borrowerResults = results);
  }

  @override
  Widget build(BuildContext context) {
    final filteredLinks = _quickLinks
        .where((item) =>
            _query.isEmpty ||
            item.title
                .toLowerCase()
                .contains(_query.toLowerCase()) ||
            item.subtitle
                .toLowerCase()
                .contains(_query.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: _onQueryChanged,
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(Icons.search, size: 20),
              hintText:
                  'Search borrowers or features...',
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16)),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          size: 18),
                      onPressed: () {
                        _controller.clear();
                        _onQueryChanged('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                if (filteredLinks.isNotEmpty) ...[
                  const SectionTitle(
                      title: 'Quick links'),
                  const SizedBox(height: 10),
                  ...filteredLinks.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFFF7F8FA),
                        child: HugeIcon(
                          icon: item.icon,
                          color: AppTheme.iconColor,
                          size: 20,
                        ),
                      ),
                      title: Text(item.title),
                      subtitle: Text(item.subtitle),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushReplacementNamed(
                                item.route);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (_query.isNotEmpty) ...[
                  const SectionTitle(
                      title: 'Matching borrowers'),
                  const SizedBox(height: 10),
                  if (_borrowerResults.isEmpty)
                    const Text(
                        'No borrowers found matching query.')
                  else
                    ..._borrowerResults.map((row) {
                      final profile =
                          row['profiles']
                              as Map<String, dynamic>?;
                      final name =
                          profile?['full_name']
                                  as String? ??
                              'Borrower';
                      final rep =
                          (profile?['reputation_score']
                                      as num?)
                                  ?.toInt() ??
                              0;
                      final id = row['id'] as String;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(
                              name.isNotEmpty
                                  ? name[0]
                                      .toUpperCase()
                                  : '?'),
                        ),
                        title: Text(name),
                        subtitle: Text(
                            row['purpose'] as String? ??
                                'Community loan'),
                        trailing: Text(
                          'Rep $rep',
                          style: const TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(
                            AppRoutes.communityFund,
                            arguments: id,
                          );
                        },
                      );
                    }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchItem {
  const _SearchItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final List<List<dynamic>> icon; // HugeIcons type
  final String route;
}