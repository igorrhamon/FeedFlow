import 'package:flutter/material.dart';

import '../domain/repositories/work_item_event_repository.dart';
import '../domain/rule.dart';
import '../domain/triage_status.dart';
import '../domain/work_item.dart';
import '../infrastructure/db/database_provider.dart';
import '../providers/feed_provider.dart';
import 'rule_editor_page.dart';

const _accent = Color(0xFF7C5CFF);
const _textPrimary = Color(0xFFF2F2F7);
const _textSecondary = Color(0xFF8E8E93);
const _surface = Color(0xFF1C1C1E);
const _surfaceHigh = Color(0xFF2C2C2E);

/// Tela "Início": painel com visão geral das fontes, métricas do dia,
/// automações ativas e itens recentes. Só mostra números que vêm de
/// repositórios reais — sem mocks.
class DashboardPage extends StatelessWidget {
  final FeedProvider provider;
  const DashboardPage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final repo = DatabaseProvider.repository;
    final ruleRepo = DatabaseProvider.ruleRepository;
    final eventRepo = DatabaseProvider.workItemEventRepository;

    if (repo == null) {
      return const Center(
        child: Text(
          'Painel indisponível nesta plataforma.',
          style: TextStyle(color: _textSecondary),
        ),
      );
    }

    final startOfToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return RefreshIndicator(
      color: _accent,
      backgroundColor: _surface,
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text('Fontes', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          StreamBuilder<Map<String, int>>(
            stream: repo.watchUnreadCountsByFeed(),
            builder: (context, snapshot) {
              final totalUnread = (snapshot.data ?? const {}).values.fold<int>(0, (a, b) => a + b);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.4,
                children: [
                  _sourceCard(icon: Icons.rss_feed_rounded, label: 'RSS', value: '$totalUnread', hint: 'não lidos', enabled: true),
                  _sourceCard(icon: Icons.mail_outline_rounded, label: 'Email', value: '—', hint: 'em breve', enabled: false),
                  _sourceCard(icon: Icons.chat_bubble_outline_rounded, label: 'WhatsApp', value: '—', hint: 'em breve', enabled: false),
                  _sourceCard(icon: Icons.webhook_rounded, label: 'Webhooks', value: '—', hint: 'em breve', enabled: false),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Visão geral', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<List<WorkItem>>(
                  stream: repo.watchByStatus(TriageStatus.values),
                  builder: (context, snapshot) {
                    final capturedToday = (snapshot.data ?? const [])
                        .where((item) => item.ingestedAt.isAfter(startOfToday))
                        .length;
                    return _metricCard('Itens capturados', '$capturedToday', Icons.inbox_rounded);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: eventRepo == null
                    ? _metricCard('Ações executadas', '—', Icons.bolt_rounded)
                    : FutureBuilder<List<WorkItemEventLog>>(
                        future: eventRepo.findSince(startOfToday, type: 'actionExecuted'),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.length;
                          return _metricCard('Ações executadas', count == null ? '—' : '$count', Icons.bolt_rounded);
                        },
                      ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fluxos ativos', style: Theme.of(context).textTheme.titleSmall),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RuleEditorPage()),
                ),
                child: const Text('Ver todos', style: TextStyle(color: _accent)),
              ),
            ],
          ),
          if (ruleRepo == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Indisponível nesta plataforma.', style: TextStyle(color: _textSecondary)),
            )
          else
            StreamBuilder<List<Rule>>(
              stream: ruleRepo.watchEnabled(),
              builder: (context, snapshot) {
                final rules = snapshot.data ?? const [];
                if (rules.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nenhum fluxo ativo ainda.', style: TextStyle(color: _textSecondary)),
                  );
                }
                return Column(
                  children: rules.take(4).map((rule) => _ruleTile(context, rule)).toList(),
                );
              },
            ),
          const SizedBox(height: 24),
          Text('Recentes', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          StreamBuilder<List<WorkItem>>(
            stream: repo.watchByStatus(TriageStatus.values),
            builder: (context, snapshot) {
              final items = List<WorkItem>.from(snapshot.data ?? const [])
                ..sort((a, b) => b.ingestedAt.compareTo(a.ingestedAt));
              final recent = items.take(6).toList();
              if (recent.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Nenhum item ainda.', style: TextStyle(color: _textSecondary)),
                );
              }
              return Column(children: recent.map(_recentTile).toList());
            },
          ),
        ],
      ),
    );
  }

  Widget _sourceCard({
    required IconData icon,
    required String label,
    required String value,
    required String hint,
    required bool enabled,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: enabled ? _accent : _textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: _textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            Text(hint, style: const TextStyle(color: _textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _accent, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: _textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _ruleTile(BuildContext context, Rule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RuleEditorPage()),
        ),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: _surfaceHigh, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.auto_awesome_rounded, color: _accent, size: 16),
        ),
        title: Text(rule.name, style: const TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text('${rule.actions.length} ação(ões)', style: const TextStyle(color: _textSecondary, fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: rule.enabled ? const Color(0x2234C759) : const Color(0x22FF453A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            rule.enabled ? 'Ativo' : 'Inativo',
            style: TextStyle(color: rule.enabled ? const Color(0xFF34C759) : const Color(0xFFFF453A), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _recentTile(WorkItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.article_outlined, color: _textSecondary, size: 18),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _textPrimary, fontSize: 14),
        ),
        subtitle: Text(_relativeTime(item.ingestedAt), style: const TextStyle(color: _textSecondary, fontSize: 12)),
        trailing: Icon(
          item.isStarred ? Icons.star_rounded : Icons.star_border_rounded,
          color: item.isStarred ? _accent : _textSecondary,
          size: 18,
        ),
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min atrás';
    if (diff.inHours < 24) return '${diff.inHours} h atrás';
    return '${diff.inDays} d atrás';
  }
}
