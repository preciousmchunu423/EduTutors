
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../repositories/admin_repository.dart';
import '../../../theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _repository = AdminRepository();

  int _tab = 0;
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _organizations = [];
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _approvals = [];
  List<Map<String, dynamic>> _joinRequests = [];
  List<Map<String, dynamic>> _invitations = [];
  List<Map<String, dynamic>> _members = [];

  String? _selectedOrganizationId;

  Map<String, dynamic>? get _selectedOrganization {
    for (final org in _organizations) {
      if (org['id'].toString() == _selectedOrganizationId) {
        return org;
      }
    }
    return null;
  }

  final List<String> _tabs = [
    'Overview',
    'Qualifications',
    'Tutor approvals',
    'Join requests',
    'Invitations',
    'Members',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ============================================================
  // LOAD DASHBOARD
  // ============================================================

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final organizations = await _repository.managedOrganizations();

      if (!mounted) return;

      if (organizations.isEmpty) {
        setState(() {
          _organizations = [];
          _selectedOrganizationId = null;
          _documents = [];
          _approvals = [];
          _joinRequests = [];
          _invitations = [];
          _members = [];
          _loading = false;
        });
        return;
      }

      String selectedId = _selectedOrganizationId ?? '';

      final stillAvailable = organizations.any(
        (org) => org['id'].toString() == selectedId,
      );

      if (!stillAvailable) {
        selectedId = organizations.first['id'].toString();
      }

      final documents = await _repository.pendingDocuments(selectedId);
      final approvals = await _repository.tutorApprovals(selectedId);
      final requests = await _repository.pendingJoinRequests(selectedId);
      final invitations = await _repository.invitations(selectedId);
      final members = await _repository.organizationMembers(selectedId);

      if (!mounted) return;

      setState(() {
        _organizations = organizations;
        _selectedOrganizationId = selectedId;
        _documents = documents;
        _approvals = approvals;
        _joinRequests = requests;
        _invitations = invitations;
        _members = members;
        _loading = false;
      });
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('ADMIN DATABASE ERROR: ${e.message}');
      debugPrint('ADMIN ERROR CODE: ${e.code}');
      debugPrint('ADMIN ERROR DETAILS: ${e.details}');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Database error: ${e.message}';
      });
    } catch (e, stackTrace) {
      debugPrint('ADMIN ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Error: $e';
      });
    }
  }

  Future<void> _changeOrganization(String? id) async {
    if (id == null || id == _selectedOrganizationId) return;

    setState(() {
      _selectedOrganizationId = id;
    });

    await _load();
  }

  // ============================================================
  // DOCUMENT REVIEW
  // ============================================================

  Future<void> _openDocument(Map<String, dynamic> row) async {
    final path = row['storage_path']?.toString();

    if (path == null || path.isEmpty) {
      _message('Document storage path is missing.', warning: true);
      return;
    }

    try {
      final url = await _repository.signedDocumentUrl(path);

      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _message('Could not open the document.', warning: true);
      }
    } catch (e) {
      debugPrint('DOCUMENT OPEN ERROR: $e');
      _message('Unable to access this document: $e', warning: true);
    }
  }

  Future<void> _reviewDocument(
    Map<String, dynamic> row,
    String status,
  ) async {
    final id = row['id']?.toString();
    if (id == null) return;

    String? reason;

    if (status == 'rejected') {
      reason = await _askReason('Reject qualification document');
      if (reason == null || reason.trim().isEmpty) return;
    }

    try {
      await _repository.reviewDocument(
        documentId: id,
        status: status,
        rejectionReason: reason,
      );

      _message(
        status == 'approved'
            ? 'Qualification document approved.'
            : 'Document rejected.',
      );

      await _load();
    } catch (e) {
      _message('Could not update document: $e', warning: true);
    }
  }

  // ============================================================
  // TUTOR APPROVALS
  // ============================================================

  Future<void> _reviewTutor(
    Map<String, dynamic> row,
    String status,
  ) async {
    final id = row['id']?.toString();
    if (id == null) return;

    String? reason;

    if (status == 'rejected') {
      reason = await _askReason('Reject tutor application');
      if (reason == null || reason.trim().isEmpty) return;
    }

    try {
      await _repository.reviewTutor(
        approvalId: id,
        status: status,
        rejectionReason: reason,
      );

      _message(
        status == 'approved'
            ? 'Tutor approved for this organisation.'
            : 'Tutor application rejected.',
      );

      await _load();
    } catch (e) {
      _message('Could not update tutor application: $e', warning: true);
    }
  }

  // ============================================================
  // JOIN REQUESTS
  // ============================================================

  Future<void> _reviewJoinRequest(
    Map<String, dynamic> row,
    bool approve,
  ) async {
    final id = row['id']?.toString();
    if (id == null) return;

    String? reason;

    if (!approve) {
      reason = await _askReason('Reject tutor join request');
      if (reason == null || reason.trim().isEmpty) return;
    }

    try {
      if (approve) {
        await _repository.approveJoinRequest(id);
        _message('Tutor has been added to the organisation.');
      } else {
        await _repository.rejectJoinRequest(
          requestId: id,
          rejectionReason: reason!,
        );
        _message('Join request rejected.');
      }

      await _load();
    } catch (e) {
      _message('Could not process join request: $e', warning: true);
    }
  }

  // ============================================================
  // INVITATIONS
  // ============================================================

  Future<void> _showCreateInvitationDialog() async {
    final emailController = TextEditingController();

    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Invite a tutor'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Tutor email address',
            hintText: 'tutor@example.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                emailController.text.trim(),
              );
            },
            child: const Text('Create invitation'),
          ),
        ],
      ),
    );

    emailController.dispose();

    if (email == null || email.trim().isEmpty) return;

    final organizationId = _selectedOrganizationId;
    if (organizationId == null) return;

    if (!email.contains('@')) {
      _message('Enter a valid email address.', warning: true);
      return;
    }

    try {
      final result = await _repository.createInvitation(
        organizationId: organizationId,
        email: email,
        role: 'tutor',
      );

      final token = result['invitation_token']?.toString();

      if (!mounted) return;

      await _load();

      if (token != null && token.isNotEmpty && mounted) {
        await _showInvitationToken(token, email);
      }
    } catch (e) {
      _message('Could not create invitation: $e', warning: true);
    }
  }

  Future<void> _showInvitationToken(String token, String email) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Invitation created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invitation created for $email.'),
            const SizedBox(height: 12),
            const Text(
              'Copy this invitation token and share it securely with the tutor.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            SelectableText(
              token,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: token));
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              _message('Invitation token copied.');
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy token'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelInvitation(Map<String, dynamic> row) async {
    final id = row['id']?.toString();
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel invitation?'),
        content: const Text(
          'The tutor will no longer be able to accept this invitation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep invitation'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel invitation'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _repository.cancelInvitation(id);
      _message('Invitation cancelled.');
      await _load();
    } catch (e) {
      _message('Could not cancel invitation: $e', warning: true);
    }
  }

  // ============================================================
  // DIALOGS AND MESSAGES
  // ============================================================

  Future<String?> _askReason(String title) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Explain what needs to be corrected',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  void _message(String text, {bool warning = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: warning ? Colors.deepOrange : AppColors.navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(child: Text('EduTutors Admin')),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _load)
                : _organizations.isEmpty
                    ? const _EmptyState(
                        message:
                            'You do not currently manage an organisation.',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          children: [
                            _organizationSelector(),
                            const SizedBox(height: 16),
                            _hero(),
                            const SizedBox(height: 18),
                            _metrics(),
                            const SizedBox(height: 22),
                            _tabSelector(),
                            const SizedBox(height: 18),
                            _tabContent(),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _organizationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MANAGING ORGANISATION',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedOrganizationId,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.business_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          items: _organizations.map((org) {
            return DropdownMenuItem<String>(
              value: org['id'].toString(),
              child: Text(
                org['name']?.toString() ?? 'Unnamed organisation',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: _changeOrganization,
        ),
      ],
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ADMIN WORKSPACE',
            style: TextStyle(
              color: Color(0xFFBFD2FF),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Good work starts with trusted tutors.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage ${_selectedOrganization?['name'] ?? 'your organisation'} and review tutor applications.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _metrics() {
    final pendingApprovals =
        _approvals.where((e) => e['status'] == 'pending').length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.65,
      children: [
        _MetricCard(
          label: 'Pending documents',
          value: '${_documents.length}',
          icon: Icons.description_outlined,
          tint: const Color(0xFFF0EBFF),
        ),
        _MetricCard(
          label: 'Tutor applications',
          value: '$pendingApprovals',
          icon: Icons.verified_user_outlined,
          tint: const Color(0xFFFFF4CC),
        ),
        _MetricCard(
          label: 'Join requests',
          value: '${_joinRequests.length}',
          icon: Icons.person_add_alt_1_rounded,
          tint: const Color(0xFFE7F7EF),
        ),
        _MetricCard(
          label: 'Organisation members',
          value: '${_members.length}',
          icon: Icons.groups_rounded,
          tint: const Color(0xFFE8F1FF),
        ),
      ],
    );
  }

  Widget _tabSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_tabs[index]),
              selected: _tab == index,
              onSelected: (_) => setState(() => _tab = index),
            ),
          );
        }),
      ),
    );
  }

  Widget _tabContent() {
    switch (_tab) {
      case 0:
        return _overviewTab();
      case 1:
        return _documentsTab();
      case 2:
        return _approvalsTab();
      case 3:
        return _joinRequestsTab();
      case 4:
        return _invitationsTab();
      case 5:
        return _membersTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _overviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          'Review queue',
          'Items that need your attention',
        ),
        const SizedBox(height: 12),
        _QueuePreview(
          title: 'Qualification documents',
          count: _documents.length,
          icon: Icons.file_present_rounded,
          onTap: () => setState(() => _tab = 1),
        ),
        _QueuePreview(
          title: 'Tutor applications',
          count: _approvals.where((e) => e['status'] == 'pending').length,
          icon: Icons.person_search_rounded,
          onTap: () => setState(() => _tab = 2),
        ),
        _QueuePreview(
          title: 'Join requests',
          count: _joinRequests.length,
          icon: Icons.person_add_alt_1_rounded,
          onTap: () => setState(() => _tab = 3),
        ),
        _QueuePreview(
          title: 'Invitations',
          count: _invitations.where((e) => e['status'] == 'pending').length,
          icon: Icons.mail_outline_rounded,
          onTap: () => setState(() => _tab = 4),
        ),
        const SizedBox(height: 18),
        const _SectionHeading(
          'Approval checklist',
          'Keep these safeguards in place',
        ),
        const SizedBox(height: 10),
        const _ChecklistTile('Review qualification certificates carefully'),
        const _ChecklistTile('Approve tutors only after document verification'),
        const _ChecklistTile('Give a clear reason when rejecting requests'),
        const _ChecklistTile('Monitor invitations and organisation membership'),
      ],
    );
  }

  Widget _documentsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          'Qualification documents',
          'Open each private upload before making a decision',
        ),
        const SizedBox(height: 12),
        if (_documents.isEmpty)
          const _EmptyState(
            message: 'No qualification documents are waiting for review.',
          ),
        for (final row in _documents)
          _DocumentCard(
            row: row,
            onOpen: () => _openDocument(row),
            onApprove: () => _reviewDocument(row, 'approved'),
            onReject: () => _reviewDocument(row, 'rejected'),
          ),
      ],
    );
  }

  Widget _approvalsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          'Tutor applications',
          'Approval is specific to this organisation',
        ),
        const SizedBox(height: 12),
        if (_approvals.isEmpty)
          const _EmptyState(message: 'No tutor applications found.'),
        for (final row in _approvals)
          _ApprovalCard(
            row: row,
            onApprove: () => _reviewTutor(row, 'approved'),
            onReject: () => _reviewTutor(row, 'rejected'),
          ),
      ],
    );
  }

  Widget _joinRequestsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          'Tutor join requests',
          'Review tutors who want to join this organisation',
        ),
        const SizedBox(height: 12),
        if (_joinRequests.isEmpty)
          const _EmptyState(message: 'No pending join requests.'),
        for (final row in _joinRequests)
          _JoinRequestCard(
            row: row,
            onApprove: () => _reviewJoinRequest(row, true),
            onReject: () => _reviewJoinRequest(row, false),
          ),
      ],
    );
  }

  Widget _invitationsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: _SectionHeading(
                'Tutor invitations',
                'Invite tutors to join your organisation',
              ),
            ),
            FilledButton.icon(
              onPressed: _showCreateInvitationDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Invite'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_invitations.isEmpty)
          const _EmptyState(message: 'No invitations have been created.'),
        for (final row in _invitations)
          _InvitationCard(
            row: row,
            onCancel: () => _cancelInvitation(row),
          ),
      ],
    );
  }

  Widget _membersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          'Organisation members',
          'People currently connected to this organisation',
        ),
        const SizedBox(height: 12),
        if (_members.isEmpty)
          const _EmptyState(message: 'No organisation members found.'),
        for (final row in _members)
          _MemberCard(row: row),
      ],
    );
  }
}

// ================================================================
// REUSABLE WIDGETS
// ================================================================

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.blue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _QueuePreview extends StatelessWidget {
  const _QueuePreview({
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final int count;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.blueSoft,
          child: Icon(icon, color: AppColors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text('View and manage'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.yellowSoft,
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 19,
            color: AppColors.blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 36,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.row,
    required this.onOpen,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> row;
  final VoidCallback onOpen;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf_outlined, color: AppColors.blue),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  (row['document_type'] ?? 'Qualification document')
                      .toString()
                      .replaceAll('_', ' '),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              _StatusPill(
                (row['verification_status'] ?? 'pending').toString(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Membership: ${row['membership_id'] ?? 'Not specified'}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open qualification document'),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onApprove,
                  child: const Text('Approve document'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.row,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> row;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? 'pending').toString();

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: AppColors.blue),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tutor application',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              _StatusPill(status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Membership: ${row['membership_id'] ?? 'Not specified'}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          if (row['rejection_reason'] != null)
            Text(
              'Reason: ${row['rejection_reason']}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onApprove,
                    child: const Text('Approve tutor'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  const _JoinRequestCard({
    required this.row,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> row;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add_alt_1, color: AppColors.blue),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tutor join request',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const _StatusPill('pending'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tutor user ID: ${row['user_id'] ?? 'Not specified'}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          if (row['message'] != null &&
              row['message'].toString().trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Message: ${row['message']}'),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onApprove,
                  child: const Text('Approve request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.row,
    required this.onCancel,
  });

  final Map<String, dynamic> row;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? 'unknown').toString();

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline_rounded, color: AppColors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  row['email']?.toString() ?? 'Unknown email',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              _StatusPill(status),
            ],
          ),
          const SizedBox(height: 8),
          Text('Role: ${row['role'] ?? 'Not specified'}'),
          Text(
            'Expires: ${row['expires_at'] ?? 'Not specified'}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          if (status == 'pending')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                label: const Text(
                  'Cancel invitation',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.row});

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final role = (row['role'] ?? 'member').toString();

    return _Panel(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.blueSoft,
            child: Icon(
              role == 'owner' || role == 'admin'
                  ? Icons.admin_panel_settings_outlined
                  : Icons.person_outline_rounded,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  'User ID: ${row['user_id'] ?? 'Not specified'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'Joined: ${row['joined_at'] ?? 'Not specified'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    final approved = status == 'approved';
    final rejected = status == 'rejected';

    final color = approved
        ? const Color(0xFF168653)
        : rejected
            ? Colors.red
            : const Color(0xFF9A6B00);

    final bg = approved
        ? const Color(0xFFE7F7EF)
        : rejected
            ? const Color(0xFFFFEEEE)
            : AppColors.yellowSoft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .4,
        ),
      ),
    );
  }
}
