
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';

class TutorDocumentsScreen extends StatefulWidget {
  const TutorDocumentsScreen({super.key});

  @override
  State<TutorDocumentsScreen> createState() =>
      _TutorDocumentsScreenState();
}

class _TutorDocumentsScreenState extends State<TutorDocumentsScreen> {
  final SupabaseClient _client = Supabase.instance.client;

  List<Map<String, dynamic>> _memberships = [];
  List<Map<String, dynamic>> _documents = [];

  String? _membershipId;
  String _documentType = 'qualification_certificate';

  bool _loading = true;
  bool _uploading = false;

  String? _error;

  static const String _bucket = 'tutor-qualifications';

  static const Map<String, String> _types = {
    'qualification_certificate': 'Qualification certificate',
    'academic_transcript': 'Academic transcript',
    'cv': 'Curriculum Vitae (CV)',
    'id_copy': 'ID copy',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ============================================================
  // LOAD MEMBERSHIPS AND DOCUMENTS
  // ============================================================

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = _client.auth.currentUser;

      if (user == null) {
        throw Exception('Your session has expired. Please log in again.');
      }

      final membershipResponse = await _client
          .from('organization_memberships')
          .select('id, organization_id, role, organizations(name)')
          .eq('user_id', user.id)
          .eq('role', 'tutor');

      final memberships =
          List<Map<String, dynamic>>.from(membershipResponse);

      String? selectedMembership;

      if (_membershipId != null &&
          memberships.any(
            (m) => m['id'].toString() == _membershipId,
          )) {
        selectedMembership = _membershipId;
      } else if (memberships.isNotEmpty) {
        selectedMembership = memberships.first['id'].toString();
      }

      List<Map<String, dynamic>> documents = [];

      if (memberships.isNotEmpty) {
        final membershipIds = memberships
            .map((m) => m['id'].toString())
            .toList();

        final documentResponse = await _client
            .from('tutor_documents')
            .select()
            .inFilter('membership_id', membershipIds)
            .order('created_at', ascending: false);

        documents =
            List<Map<String, dynamic>>.from(documentResponse);
      }

      if (!mounted) return;

      setState(() {
        _memberships = memberships;
        _membershipId = selectedMembership;
        _documents = documents;
        _loading = false;
      });
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('DATABASE ERROR: ${e.message}');
      debugPrint('Code: ${e.code}');
      debugPrint('Details: ${e.details}');
      debugPrint('Hint: ${e.hint}');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Database error: ${e.message}';
      });
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Authentication error: ${e.message}';
      });
    } catch (e, stackTrace) {
      debugPrint('DOCUMENT LOAD ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not load your documents: $e';
      });
    }
  }

  // ============================================================
  // DOCUMENT HELPERS
  // ============================================================

  List<Map<String, dynamic>> get _selectedDocuments {
    if (_membershipId == null) return [];

    return _documents.where((document) {
      return document['membership_id'].toString() == _membershipId;
    }).toList();
  }

  // Documents are ordered newest first.
  // Return the newest uploaded version of a document type.
  Map<String, dynamic>? _latestDocument(String type) {
    for (final document in _selectedDocuments) {
      if (document['document_type'] == type) {
        return document;
      }
    }

    return null;
  }

  String _statusFor(String type) {
    return (_latestDocument(type)?['verification_status'] ?? 'missing')
        .toString();
  }

  int get _approvedCount {
    return _types.keys.where((type) {
      return _statusFor(type) == 'approved';
    }).length;
  }

  bool get _allDocumentsApproved => _approvedCount == _types.length;

  // ============================================================
  // CHECK WHETHER DOCUMENT CAN BE UPLOADED
  // ============================================================

  bool _canUploadType(String type) {
    final status = _statusFor(type);

    // Pending documents must first be reviewed.
    if (status == 'pending') return false;

    // Approved documents cannot be replaced through this screen.
    if (status == 'approved') return false;

    // Missing or rejected documents can be uploaded.
    return status == 'missing' || status == 'rejected';
  }

  // ============================================================
  // UPLOAD DOCUMENT FROM COMPUTER
  // ============================================================

  Future<void> _upload() async {
    final selectedMembership = _membershipId;
    final selectedType = _documentType;

    if (selectedMembership == null) {
      _message(
        'Join an organisation as a tutor before uploading documents.',
        warning: true,
      );
      return;
    }

    if (_uploading) return;

    if (!_canUploadType(selectedType)) {
      _message(
        'This document is already approved or is waiting for review.',
        warning: true,
      );
      return;
    }

    try {
      // Opens the laptop/computer file picker.
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
        ],
        withData: true,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes == null) {
        _message(
          'The selected file could not be read. Please try again.',
          warning: true,
        );
        return;
      }

      if (file.size == 0) {
        _message('The selected file is empty.', warning: true);
        return;
      }

      if (file.size > 10 * 1024 * 1024) {
        _message(
          'The file is too large. Maximum file size is 10 MB.',
          warning: true,
        );
        return;
      }

      final extension = file.extension?.toLowerCase() ?? '';

      const allowedExtensions = [
        'pdf',
        'doc',
        'docx',
        'jpg',
        'jpeg',
        'png',
      ];

      if (!allowedExtensions.contains(extension)) {
        _message(
          'Please select a PDF, DOC, DOCX, JPG or PNG file.',
          warning: true,
        );
        return;
      }

      // Check again after the file picker has closed.
      if (!_canUploadType(selectedType)) {
        _message(
          'This document can no longer be uploaded. Refresh the screen.',
          warning: true,
        );
        await _load();
        return;
      }

      if (!mounted) return;

      setState(() => _uploading = true);

      final safeName = file.name.replaceAll(
        RegExp(r'[^A-Za-z0-9._-]'),
        '_',
      );

      final path =
          '$selectedMembership/${DateTime.now().microsecondsSinceEpoch}_$safeName';

      final mimeType = switch (extension) {
        'pdf' => 'application/pdf',
        'doc' => 'application/msword',
        'docx' =>
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        _ => 'application/octet-stream',
      };

      debugPrint('Uploading document: $path');

      // Upload file to private Supabase Storage bucket.
      await _client.storage.from(_bucket).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: mimeType,
          upsert: false,
        ),
      );

      try {
        // Create a new database record.
        // Rejected records are retained as document history.
        await _client.from('tutor_documents').insert({
          'membership_id': selectedMembership,
          'document_type': selectedType,
          'file_name': file.name,
          'storage_path': path,
          'verification_status': 'pending',
          'rejection_reason': null,
          'reviewed_by': null,
          'reviewed_at': null,
        });
      } catch (databaseError) {
        // Remove uploaded file if database insertion fails.
        try {
          await _client.storage.from(_bucket).remove([path]);
        } catch (cleanupError) {
          debugPrint('FILE CLEANUP ERROR: $cleanupError');
        }

        rethrow;
      }

      if (!mounted) return;

      _message(
        '${_types[selectedType]} uploaded successfully. '
        'It is now waiting for administrator review.',
      );

      await _load();
    } on StorageException catch (e, stackTrace) {
      debugPrint('STORAGE ERROR: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _message(
          'Storage upload failed: ${e.message}',
          warning: true,
        );
      }
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('DATABASE INSERT ERROR: ${e.message}');
      debugPrint('Code: ${e.code}');
      debugPrint('Details: ${e.details}');
      debugPrint('Hint: ${e.hint}');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _message(
          'Could not save document information: ${e.message}',
          warning: true,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('UPLOAD ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _message('Upload failed: $e', warning: true);
      }
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  // ============================================================
  // OPEN DOCUMENT
  // ============================================================

  Future<void> _open(Map<String, dynamic> row) async {
    try {
      final storagePath = row['storage_path']?.toString();

      if (storagePath == null || storagePath.isEmpty) {
        throw Exception('Document storage path is missing.');
      }

      final url = await _client.storage
          .from(_bucket)
          .createSignedUrl(storagePath, 300);

      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not open the document.');
      }
    } catch (e, stackTrace) {
      debugPrint('OPEN DOCUMENT ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      _message(
        'Could not open the document: $e',
        warning: true,
      );
    }
  }

  // ============================================================
  // SNACKBAR MESSAGE
  // ============================================================

  void _message(String text, {bool warning = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor:
            warning ? Colors.deepOrange : AppColors.navy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: const Text('My qualifications'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading || _uploading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 55,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load your documents',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SelectableText(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildBanner(),

          const SizedBox(height: 20),

          if (_memberships.isEmpty)
            const _InfoPanel(
              text: 'You are not yet a tutor member of an organisation. '
                  'Join an organisation first before uploading your documents.',
            ),

          if (_memberships.isNotEmpty) ...[
            const Text(
              'Organisation',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _membershipId,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.groups_outlined),
                border: OutlineInputBorder(),
              ),
              items: _memberships.map((membership) {
                final id = membership['id'].toString();
                final organization = membership['organizations'];

                final name = organization is Map
                    ? organization['name']?.toString()
                    : null;

                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(
                    name?.isNotEmpty == true
                        ? name!
                        : 'Organisation ${id.substring(0, id.length > 8 ? 8 : id.length)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: _uploading
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        _membershipId = value;
                      });
                    },
            ),

            const SizedBox(height: 22),

            _buildProgress(),

            const SizedBox(height: 22),

            const Text(
              'Required documents',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'All four documents must be uploaded and approved '
              'before your organisation can approve your tutor application.',
              style: TextStyle(
                color: AppColors.textMuted,
                height: 1.5,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 14),

            // Four compulsory document cards.
            for (final entry in _types.entries)
              _buildRequiredDocumentCard(
                type: entry.key,
                title: entry.value,
              ),

            const SizedBox(height: 24),

            _buildUploadPanel(),

            const SizedBox(height: 24),

            const Text(
              'Upload history',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            if (_selectedDocuments.isEmpty)
              const _InfoPanel(
                text: 'No documents have been uploaded yet.',
              ),

            for (final document in _selectedDocuments)
              _buildHistoryTile(document),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // VERIFICATION BANNER
  // ============================================================

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.navy,
            AppColors.blue,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: Colors.white,
            size: 34,
          ),
          SizedBox(height: 12),
          Text(
            'Get verified to start tutoring',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Submit your qualification certificate, academic transcript, '
            'CV and ID copy. Your organisation administrator will '
            'review each document before approving your tutor application.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress() {
    final progress = _approvedCount / _types.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Verification progress',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$_approvedCount / ${_types.length} approved',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.grey.shade200,
              color: _allDocumentsApproved
                  ? Colors.green
                  : AppColors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _allDocumentsApproved
                ? 'All compulsory documents are approved. Your tutor application can now be reviewed.'
                : 'You still need to get ${_types.length - _approvedCount} document(s) approved.',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REQUIRED DOCUMENT CARD
  // ============================================================

  Widget _buildRequiredDocumentCard({
    required String type,
    required String title,
  }) {
    final document = _latestDocument(type);
    final status = _statusFor(type);

    final statusColor = switch (status) {
      'approved' => Colors.green,
      'rejected' => Colors.red,
      'pending' => const Color(0xFFB77900),
      _ => Colors.grey,
    };

    final statusLabel = switch (status) {
      'approved' => 'APPROVED',
      'rejected' => 'REJECTED',
      'pending' => 'PENDING REVIEW',
      _ => 'NOT UPLOADED',
    };

    final canUpload = _canUploadType(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 'rejected'
              ? Colors.red.shade200
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.10),
                child: Icon(
                  status == 'approved'
                      ? Icons.check_circle_outline
                      : status == 'rejected'
                          ? Icons.error_outline
                          : status == 'pending'
                              ? Icons.hourglass_top_rounded
                              : Icons.description_outlined,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (document != null)
                IconButton(
                  tooltip: 'Open document',
                  onPressed: () => _open(document),
                  icon: const Icon(Icons.open_in_new_rounded),
                ),
            ],
          ),

          if (document != null) ...[
            const SizedBox(height: 9),
            Text(
              document['file_name']?.toString() ?? '',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],

          if (status == 'rejected' &&
              document?['rejection_reason'] != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Admin feedback: ${document!['rejection_reason']}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],

          if (status == 'rejected') ...[
            const SizedBox(height: 10),
            const Text(
              'Please upload a corrected document for another review.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],

          if (status == 'pending') ...[
            const SizedBox(height: 10),
            const Text(
              'Your document is waiting for the administrator to review it.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],

          if (canUpload) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _uploading
                    ? null
                    : () {
                        setState(() {
                          _documentType = type;
                        });
                        _upload();
                      },
                icon: Icon(
                  status == 'rejected'
                      ? Icons.refresh_rounded
                      : Icons.upload_file_rounded,
                ),
                label: Text(
                  status == 'rejected'
                      ? 'Replace rejected document'
                      : 'Upload document',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // UPLOAD PANEL
  // ============================================================

  Widget _buildUploadPanel() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.folder_open_rounded,
            size: 43,
            color: AppColors.blue,
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload a document from your computer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Choose the document type below, then browse your laptop '
            'to select the file.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _documentType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Choose document type',
              prefixIcon: Icon(Icons.description_outlined),
              border: OutlineInputBorder(),
            ),
            items: _types.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: _uploading
                ? null
                : (value) {
                    if (value != null) {
                      setState(() {
                        _documentType = value;
                      });
                    }
                  },
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton.icon(
              onPressed: _uploading ||
                      _membershipId == null ||
                      !_canUploadType(_documentType)
                  ? null
                  : _upload,
              icon: _uploading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.folder_open_rounded),
              label: Text(
                _uploading
                    ? 'Uploading document...'
                    : 'Browse files on my computer',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'PDF, DOC, DOCX, JPG or PNG • Maximum 10 MB',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),

          if (!_canUploadType(_documentType)) ...[
            const SizedBox(height: 10),
            Text(
              _statusFor(_documentType) == 'approved'
                  ? 'This document has already been approved.'
                  : 'This document is waiting for administrator review.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // UPLOAD HISTORY
  // ============================================================

  Widget _buildHistoryTile(Map<String, dynamic> document) {
    final status =
        (document['verification_status'] ?? 'pending').toString();

    final color = switch (status) {
      'approved' => Colors.green,
      'rejected' => Colors.red,
      _ => const Color(0xFFB77900),
    };

    final type = document['document_type']?.toString() ?? '';
    final title = _types[type] ?? type.replaceAll('_', ' ');

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 7,
        ),
        leading: const CircleAvatar(
          backgroundColor: AppColors.blueSoft,
          child: Icon(
            Icons.description_outlined,
            color: AppColors.blue,
          ),
        ),
        title: Text(
          document['file_name']?.toString() ?? title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 4),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (status == 'rejected' &&
                document['rejection_reason'] != null)
              Text(
                'Reason: ${document['rejection_reason']}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          tooltip: 'Open document',
          onPressed: () => _open(document),
          icon: const Icon(Icons.open_in_new_rounded),
        ),
      ),
    );
  }
}

// ============================================================
// INFORMATION PANEL
// ============================================================

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textMuted,
          height: 1.5,
        ),
      ),
    );
  }
}
