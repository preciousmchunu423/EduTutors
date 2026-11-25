# EduTutors Supabase authentication and admin review update

## Included in this update
- Replaced local SharedPreferences password/session handling with Supabase Auth.
- Registration sends `full_name` and lowercase `role` metadata. The `handle_new_edututors_user` trigger creates the profile and role-specific profile row.
- Login restores the authenticated user from Supabase and loads the profile.
- Learner grade is saved to `learner_profiles` after registration.
- Organisation owner/admin membership is detected from `organization_memberships`; those users are routed to the new Admin Dashboard.
- Added an Admin Dashboard with qualification-document review and organisation tutor-approval queues. The approval queue uses the existing `membership_id` relationship.
- Added a tutor Qualifications screen to upload PDF, DOC, DOCX, JPEG or PNG files (maximum 10 MB) to the private `tutor-qualifications` bucket using the existing `membership_id/file-name` folder convention.
- Qualification documents are opened through short-lived signed URLs from the private `tutor-qualifications` bucket.
- Admin decisions update the existing `tutor_documents` and `organization_tutor_approvals` records. Database RLS and triggers remain authoritative; an approval that violates the qualification requirement should be rejected by the database.
- Registration UI explains that tutor qualifications are mandatory and that parent-child linking requires an accepted link request.

## Before running
1. Run `flutter pub get` to install `url_launcher`.
2. Confirm Supabase Auth email confirmation is disabled for development, as configured in the project dashboard.
3. Confirm the SQL trigger `on_edututors_user_created` exists and is enabled.
4. Confirm the signed-in organisation admin can SELECT and UPDATE the relevant rows under the existing RLS policies.
5. Run `flutter analyze`, then `flutter run -d edge`.

## Important schema alignment note
The implementation follows the previously created schema: `tutor_documents` uses `membership_id`, `document_type`, `file_name`, `storage_path`, and `verification_status`; `organization_tutor_approvals` uses `membership_id` and `status`. The approval screen intentionally relies on the database trigger to block tutor approval until the qualification certificate has been approved.

The app does not grant global admin access. Admin access is detected from an `owner` or `admin` row in `organization_memberships`, and the database RLS policies must still restrict each administrator to their own organisation.

## Remaining integration work
- Implement parent-child invitation acceptance against `parent_children`.
- Continue replacing placeholder/local data in bookings, tutor discovery, materials, payments, progress, and messaging with Supabase queries.
- Turn email confirmation back ON and configure production redirect/deep-link handling before public launch.
