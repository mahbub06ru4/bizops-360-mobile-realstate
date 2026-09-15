import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory [AuthRepository] for UI-first development (`Env.useFakeData`).
/// No network. Any password works; an email containing `bad` is rejected so the
/// error path stays exercisable. Shaped to match the real `auth/*` envelope.
class FakeAuthRepository implements AuthRepository {
  bool _signedIn = false;
  bool _asBuyer = false;

  static const _demoUser = AuthUser(
    id: 1,
    name: 'Nadia Haque',
    email: 'manager@greenland.test',
    roles: ['manager'],
    permissions: [
      'task.view',
      'task.create',
      'task.assign',
      'attendance.check_in',
      'attendance.view',
      'leave.request',
      'leave.approve',
      'customer.view',
      'customer.update',
      'follow_up.update',
      'expense.create',
      'expense.update',
      'employee_document.view',
      'real_estate_project.view',
      'real_estate_project.create',
      'real_estate_project.update',
      'real_estate_project.submit',
      'finance.view_reports',
    ],
    tenant: Tenant(
      id: 1,
      name: 'Greenland Properties',
      slug: 'greenland',
      industry: 'real_estate',
    ),
  );

  Future<T> _delayed<T>(T value) =>
      Future<T>.delayed(const Duration(milliseconds: 400), () => value);

  @override
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    if (email.toLowerCase().contains('bad')) {
      return _delayed(
        const Result.err(
          ValidationFailure('These credentials do not match our records.', {
            'email': ['These credentials do not match our records.'],
          }),
        ),
      );
    }
    _signedIn = true;
    _asBuyer = false;
    return _delayed(Result.ok(_demoUser.copyWithEmail(email)));
  }

  @override
  Future<Result<AuthUser>> currentUser() async {
    if (!_signedIn) return const Result.err(UnauthorizedFailure());
    return _delayed(Result.ok(_asBuyer ? _demoBuyer : _demoUser));
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
    _asBuyer = false;
  }

  @override
  Future<bool> hasStoredSession() async => _signedIn;

  static const _demoBuyer = AuthUser(
    id: 9001,
    name: 'Tanvir Ahmed',
    email: 'buyer.demo@bizops360.test',
    phone: '+8801912345678',
    roles: [],
    permissions: [],
    kind: UserKind.buyer,
  );

  @override
  Future<Result<AuthUser>> continueAsBuyer() async {
    _signedIn = true;
    _asBuyer = true;
    return _delayed(const Result.ok(_demoBuyer));
  }
}

extension _CopyEmail on AuthUser {
  AuthUser copyWithEmail(String email) => AuthUser(
    id: id,
    name: name,
    email: email,
    roles: roles,
    permissions: permissions,
    tenant: tenant,
  );
}
