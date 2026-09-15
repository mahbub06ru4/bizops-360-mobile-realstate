abstract final class Routes {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const shell = '/shell';

  // Buyer persona (Phase 2 — platform-level, no tenant/roles). Browse/Saved/
  // My Properties/Profile are also embedded as widgets inside the buyer
  // shell's `IndexedStack` (mirroring how the staff shell embeds Projects
  // etc.) — these routes exist for deep-linking straight to one tab.
  static const buyerShell = '/buyer/shell';
  static const buyerBrowse = '/buyer/browse';
  static const buyerSaved = '/buyer/saved';
  static const buyerCompare = '/buyer/compare';
  static const buyerMyProperties = '/buyer/my-properties';
  static const buyerProfile = '/buyer/profile';

  static const notifications = '/notifications';
  static const taskDetail = '/task';
  static const attendance = '/attendance';
  static const officeLocation = '/attendance/office-location';
  static const leave = '/leave';
  static const leaveRequest = '/leave/request';
  static const approvals = '/approvals';
  static const customerDetail = '/customer';
  static const followUps = '/follow-ups';
  static const expenses = '/expenses';
  static const expenseNew = '/expenses/new';
  static const documents = '/documents';
  static const projects = '/projects';
  static const postProject = '/projects/post';
  static const projectDetail = '/project';
  static const requirementForm = '/requirements/capture';
  static const propertyMatches = '/requirements/matches';
  static const siteVisits = '/site-visits';
  static const offers = '/offers';
  static const offerThread = '/offer';
  static const newOffer = '/offers/new';
  static const reBookings = '/re-bookings';
  static const reBookingDetail = '/re-booking';
  static const reports = '/reports';
  static const invoices = '/invoices';
  static const invoiceDetail = '/invoice';
  static const team = '/team';
  static const holidays = '/holidays';

  // Workspace destinations
  static const settings = '/settings';
  static const profile = '/profile';

  /// Generic "not built yet" screen — pass the title via `Get.toNamed(...,
  /// arguments: '<title>')`.
  static const comingSoon = '/coming-soon';
}
