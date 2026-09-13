import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/core/authorization/raeed_role.dart';
import 'package:raeed/core/router/app_routes.dart';
import 'package:raeed/core/router/route_guard.dart';
import 'package:raeed/core/session/app_session.dart';

/// Guards decide whether a screen holding children's data is reachable, so
/// every branch is tested directly rather than through the UI.
void main() {
  AppSession sessionWith({
    required SessionStatus status,
    Set<RaeedRole> roles = const {RaeedRole.parent},
    Set<String> children = const {'child-1'},
    Set<String> groups = const {},
  }) => AppSession(
    status: status,
    user: status == SessionStatus.signedOut || status == SessionStatus.unknown
        ? null
        : SessionUser(
            id: 'user-1',
            roles: roles,
            displayName: 'Test User',
            reachableChildIds: children,
            reachableGroupIds: groups,
          ),
  );

  group('unknown session', () {
    test(
      'never redirects, so a cold start does not flash the login screen',
      () {
        const session = AppSession.unknown();

        for (final location in [
          AppRoutes.home,
          AppRoutes.login,
          AppRoutes.consent,
          AppRoutes.dashboard,
          AppRoutes.memories,
        ]) {
          expect(
            resolveRedirect(session: session, location: location),
            isNull,
            reason: '$location must not redirect while the session is unknown',
          );
        }
      },
    );
  });

  group('signed out', () {
    const session = AppSession.signedOut();

    test('allows the login screen', () {
      expect(
        resolveRedirect(session: session, location: AppRoutes.login),
        isNull,
      );
    });

    test('allows the OTP screen when a request is pending', () {
      expect(
        resolveRedirect(
          session: session,
          location: AppRoutes.otp,
          hasPendingOtpRequest: true,
        ),
        isNull,
      );
    });

    test('sends the OTP screen back to login with no pending request', () {
      // Without a pending request there is no phone number to verify against,
      // so the screen would be a dead end.
      expect(
        resolveRedirect(session: session, location: AppRoutes.otp),
        AppRoutes.login,
      );
    });

    test('redirects every authenticated route to login', () {
      for (final location in [
        AppRoutes.home,
        AppRoutes.consent,
        AppRoutes.memories,
        AppRoutes.dashboard,
        AppRoutes.memoriesCompose,
        AppRoutes.childPath('child-1'),
        AppRoutes.attendancePath('group-1', 'session-1'),
        AppRoutes.conversationPath('conversation-1'),
      ]) {
        expect(
          resolveRedirect(session: session, location: location),
          AppRoutes.login,
          reason: '$location must require authentication',
        );
      }
    });
  });

  group('awaiting consent (ACC-06)', () {
    final session = sessionWith(status: SessionStatus.awaitingConsent);

    test('allows the consent screen', () {
      expect(
        resolveRedirect(session: session, location: AppRoutes.consent),
        isNull,
      );
    });

    test('blocks every screen that could show a child\'s data', () {
      // This is the gate that stops a guardian reaching children's records
      // before agreeing to the privacy policy and setting image rights.
      for (final location in [
        AppRoutes.home,
        AppRoutes.memories,
        AppRoutes.dashboard,
        AppRoutes.childPath('child-1'),
        AppRoutes.childTabPath('child-1', AppRoutes.childAttendance),
        AppRoutes.groupPath('group-1'),
        AppRoutes.attendancePath('group-1', 'session-1'),
        AppRoutes.conversationPath('conversation-1'),
      ]) {
        expect(
          resolveRedirect(session: session, location: location),
          AppRoutes.consent,
          reason: '$location must be behind the consent gate',
        );
      }
    });

    test('sends the login screens to consent, not home', () {
      expect(
        resolveRedirect(session: session, location: AppRoutes.login),
        AppRoutes.consent,
      );
    });
  });

  group('active session', () {
    test('allows ordinary screens', () {
      final session = sessionWith(status: SessionStatus.active);

      for (final location in [
        AppRoutes.home,
        AppRoutes.memories,
        AppRoutes.childPath('child-1'),
        AppRoutes.conversationPath('conversation-1'),
      ]) {
        expect(
          resolveRedirect(session: session, location: location),
          isNull,
          reason: '$location should be reachable',
        );
      }
    });

    test('sends the login screens home', () {
      final session = sessionWith(status: SessionStatus.active);
      expect(
        resolveRedirect(session: session, location: AppRoutes.login),
        AppRoutes.home,
      );
      expect(
        resolveRedirect(
          session: session,
          location: AppRoutes.otp,
          hasPendingOtpRequest: true,
        ),
        AppRoutes.home,
      );
    });

    test('sends the consent screen home once consent is recorded', () {
      final session = sessionWith(status: SessionStatus.active);
      expect(
        resolveRedirect(session: session, location: AppRoutes.consent),
        AppRoutes.home,
      );
    });
  });

  group('ability-gated routes', () {
    test('a parent cannot reach the dashboard', () {
      final session = sessionWith(
        status: SessionStatus.active,
        roles: {RaeedRole.parent},
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.dashboard),
        AppRoutes.home,
      );
    });

    test('an educator cannot reach the dashboard', () {
      final session = sessionWith(
        status: SessionStatus.active,
        roles: {RaeedRole.educator},
        groups: {'group-1'},
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.dashboard),
        AppRoutes.home,
      );
    });

    test('an executive can reach the dashboard', () {
      final session = sessionWith(
        status: SessionStatus.active,
        roles: {RaeedRole.executive},
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.dashboard),
        isNull,
      );
    });

    test('a parent cannot reach the Memories composer', () {
      final session = sessionWith(
        status: SessionStatus.active,
        roles: {RaeedRole.parent},
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.memoriesCompose),
        AppRoutes.home,
      );
    });

    test('an educator with a group can reach the Memories composer', () {
      final session = sessionWith(
        status: SessionStatus.active,
        roles: {RaeedRole.educator},
        groups: {'group-1'},
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.memoriesCompose),
        isNull,
      );
    });

    test('a parent cannot reach the announcement composer', () {
      final session = sessionWith(
        status: SessionStatus.active,
        roles: {RaeedRole.parent},
      );
      expect(
        resolveRedirect(
          session: session,
          location: AppRoutes.announcementCompose,
        ),
        AppRoutes.home,
      );
    });

    test('the Memories Wall itself is open to any authenticated user', () {
      final session = sessionWith(
        status: SessionStatus.active,
        roles: {RaeedRole.parent},
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.memories),
        isNull,
        reason: 'viewing is not composing',
      );
    });
  });

  group('path normalisation', () {
    test('ignores a query string', () {
      const session = AppSession.signedOut();
      expect(
        resolveRedirect(
          session: session,
          location: '${AppRoutes.login}?next=/home',
        ),
        isNull,
      );
    });

    test('ignores a trailing slash', () {
      final session = sessionWith(status: SessionStatus.active);
      expect(
        resolveRedirect(session: session, location: '${AppRoutes.consent}/'),
        AppRoutes.home,
      );
    });

    test('does not strip the root path to an empty string', () {
      const session = AppSession.signedOut();
      expect(resolveRedirect(session: session, location: '/'), AppRoutes.login);
    });
  });
}
