/// The permission-name catalogue. These strings mirror the abilities the
/// backend attaches to `user.permissions`; reference `Perm.*`, never a literal,
/// so a rename is one edit and the set is discoverable.
///
/// Backend authorization stays the security authority — these only decide what
/// the app *shows*.
abstract final class Perm {
  // Organisation / people
  static const employeeView = 'employee.view';
  static const employeeManage = 'employee.update';

  // Tasks & operations
  static const taskView = 'task.view';
  static const taskCreate = 'task.create';
  static const taskAssign = 'task.assign';

  // Attendance & leave
  static const attendanceSelf = 'attendance.check_in';
  static const attendanceView = 'attendance.view';
  static const attendanceManage = 'attendance.manage';
  static const leaveRequest = 'leave.request';
  static const leaveApprove = 'leave.approve';

  // Documents
  static const documentView = 'employee_document.view';
  static const documentManage = 'employee_document.upload';

  // CRM
  static const customerView = 'customer.view';
  static const customerManage = 'customer.update';
  static const followUpManage = 'follow_up.update';

  // Finance
  static const expenseSubmit = 'expense.create';
  static const expenseApprove = 'expense.update';
  static const invoiceView = 'invoice.view';
  static const invoiceManage = 'invoice.update';
  static const paymentRecord = 'invoice.record_payment';

  // Travel (industry:travel)
  static const travellerView = 'traveller.view';
  static const travellerCreate = 'traveller.create';
  static const travellerManage = 'traveller.update';
  static const visaView = 'visa_application.view';
  static const visaManage = 'visa_application.update';
  static const bookingView = 'booking.view';
  static const bookingManage = 'booking.update';

  // Reports / dashboards
  static const reportsView = 'finance.view_reports';
}

/// Named feature flags carried by `/me/bootstrap` `enabled_features`. A feature
/// can be off for a tenant even when the user holds the permission.
abstract final class Feature {
  static const attendance = 'attendance';
  static const leave = 'leave';
  static const tasks = 'tasks';
  static const crm = 'crm';
  static const expenses = 'expenses';
  static const documents = 'documents';
  static const travelVisa = 'travel_visa';
  static const travelBookings = 'travel_bookings';
  static const reports = 'reports';
}
