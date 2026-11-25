
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepository {
  AdminRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ============================================================
  // ORGANISATIONS MANAGED BY CURRENT ADMIN
  // ============================================================

  Future<List<Map<String, dynamic>>> managedOrganizations() async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('You must be logged in.');
    }

    final memberships = await _client
        .from('organization_memberships')
        .select('organization_id, role')
        .eq('user_id', userId)
        .inFilter('role', ['owner', 'admin']);

    final organizationIds = memberships
        .map((row) => row['organization_id'].toString())
        .toSet()
        .toList();

    if (organizationIds.isEmpty) return [];

    final organizations = await _client
        .from('organizations')
        .select('id, name, organization_type, is_active')
        .inFilter('id', organizationIds)
        .order('name');

    return List<Map<String, dynamic>>.from(organizations);
  }

  // ============================================================
  // ORGANISATION MEMBERS
  // ============================================================

  Future<List<Map<String, dynamic>>> organizationMembers(
    String organizationId,
  ) async {
    final rows = await _client
        .from('organization_memberships')
        .select('id, organization_id, user_id, role, joined_at')
        .eq('organization_id', organizationId)
        .order('joined_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  // ============================================================
  // ORGANISATION MEMBERSHIP IDS
  // ============================================================

  Future<List<String>> _membershipIds(
    String organizationId,
  ) async {
    final rows = await _client
        .from('organization_memberships')
        .select('id')
        .eq('organization_id', organizationId);

    return rows.map((row) => row['id'].toString()).toList();
  }

  // ============================================================
  // TUTOR DOCUMENTS
  // ============================================================

  Future<List<Map<String, dynamic>>> pendingDocuments(
    String organizationId,
  ) async {
    final membershipIds = await _membershipIds(organizationId);

    if (membershipIds.isEmpty) return [];

    final rows = await _client
        .from('tutor_documents')
        .select()
        .inFilter('membership_id', membershipIds)
        .eq('verification_status', 'pending')
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(rows);
  }

  // Review document using secure Supabase RPC.
  Future<void> reviewDocument({
    required String documentId,
    required String status,
    String? rejectionReason,
  }) async {
    if (!['approved', 'rejected'].contains(status)) {
      throw ArgumentError('Invalid document review status.');
    }

    if (status == 'rejected' &&
        (rejectionReason == null || rejectionReason.trim().isEmpty)) {
      throw ArgumentError('A rejection reason is required.');
    }

    await _client.rpc(
      'review_tutor_document',
      params: {
        'p_document_id': documentId,
        'p_status': status,
        'p_rejection_reason': rejectionReason,
      },
    );
  }

  Future<String> signedDocumentUrl(String path) {
    return _client.storage
        .from('tutor-qualifications')
        .createSignedUrl(path, 300);
  }

  // ============================================================
  // TUTOR APPROVALS
  // ============================================================

  Future<List<Map<String, dynamic>>> tutorApprovals(
    String organizationId,
  ) async {
    final membershipIds = await _membershipIds(organizationId);

    if (membershipIds.isEmpty) return [];

    final rows = await _client
        .from('organization_tutor_approvals')
        .select()
        .inFilter('membership_id', membershipIds)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  // Approval is blocked by Supabase until all four required
  // document types have approved records.
  Future<void> reviewTutor({
    required String approvalId,
    required String status,
    String? rejectionReason,
  }) async {
    if (!['approved', 'rejected'].contains(status)) {
      throw ArgumentError('Invalid tutor approval status.');
    }

    if (status == 'rejected' &&
        (rejectionReason == null || rejectionReason.trim().isEmpty)) {
      throw ArgumentError('A rejection reason is required.');
    }

    await _client.rpc(
      'review_organization_tutor',
      params: {
        'p_approval_id': approvalId,
        'p_status': status,
        'p_rejection_reason': rejectionReason,
      },
    );
  }

  // ============================================================
  // ORGANISATION JOIN REQUESTS
  // ============================================================

  Future<List<Map<String, dynamic>>> pendingJoinRequests(
    String organizationId,
  ) async {
    final rows = await _client
        .from('organization_join_requests')
        .select()
        .eq('organization_id', organizationId)
        .eq('status', 'pending')
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> approveJoinRequest(String requestId) async {
    await _client.rpc(
      'approve_organization_join_request',
      params: {'p_request_id': requestId},
    );
  }

  Future<void> rejectJoinRequest({
    required String requestId,
    required String rejectionReason,
  }) async {
    await _client.rpc(
      'reject_organization_join_request',
      params: {
        'p_request_id': requestId,
        'p_rejection_reason': rejectionReason,
      },
    );
  }

  // ============================================================
  // ORGANISATION INVITATIONS
  // ============================================================

  Future<Map<String, dynamic>> createInvitation({
    required String organizationId,
    required String email,
    String role = 'tutor',
  }) async {
    final result = await _client.rpc(
      'create_organization_invitation',
      params: {
        'p_organization_id': organizationId,
        'p_email': email.trim().toLowerCase(),
        'p_role': role,
      },
    );

    final rows = List<Map<String, dynamic>>.from(result as List);

    if (rows.isEmpty) {
      throw Exception('The invitation could not be created.');
    }

    return rows.first;
  }

  Future<List<Map<String, dynamic>>> invitations(
    String organizationId,
  ) async {
    final rows = await _client.rpc(
      'get_organization_invitations',
      params: {'p_organization_id': organizationId},
    );

    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<void> cancelInvitation(String invitationId) async {
    await _client.rpc(
      'cancel_organization_invitation',
      params: {'p_invitation_id': invitationId},
    );
  }
}
