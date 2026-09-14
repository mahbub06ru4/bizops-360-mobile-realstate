/// String keys for GetX translations. Reference these, never a raw literal, so
/// every screen is bilingual from the start. `key.tr` resolves against the
/// active locale, falling back to English.
abstract final class Tr {
  static const appName = 'app_name';

  // Common
  static const retry = 'common.retry';
  static const cancel = 'common.cancel';
  static const save = 'common.save';
  static const ok = 'common.ok';
  static const somethingWrong = 'common.something_wrong';
  static const english = 'common.english';
  static const bengali = 'common.bengali';
  static const today = 'common.today';
  static const earlier = 'common.earlier';
  static const overdue = 'common.overdue';
  static const upcoming = 'common.upcoming';

  // Notifications
  static const notificationsTitle = 'notifications.title';
  static const markAllRead = 'notifications.mark_all_read';
  static const notificationsEmpty = 'notifications.empty';

  // Attendance
  static const attTitle = 'att.title';
  static const attCheckIn = 'att.check_in';
  static const attCheckOut = 'att.check_out';
  static const attCheckedInAt = 'att.checked_in_at';
  static const attWorked = 'att.worked';
  static const attThisWeek = 'att.this_week';
  static const attHistory = 'att.history';
  static const attDone = 'att.done';
  static const attNotIn = 'att.not_in';
  static const attStatusPresent = 'att.status_present';
  static const attStatusLate = 'att.status_late';
  static const attStatusEarly = 'att.status_early';
  static const attStatusAbsent = 'att.status_absent';
  static const attStatusLeave = 'att.status_leave';
  static const attStatusHoliday = 'att.status_holiday';
  static const attZoneOffice = 'att.zone_office';
  static const attZoneOutside = 'att.zone_outside';

  static const officeLocTitle = 'office_loc.title';
  static const officeLocLabel = 'office_loc.label';
  static const officeLocLat = 'office_loc.lat';
  static const officeLocLng = 'office_loc.lng';
  static const officeLocUseCurrent = 'office_loc.use_current';
  static const officeLocRadius = 'office_loc.radius';
  static const officeLocStart = 'office_loc.start';
  static const officeLocEnd = 'office_loc.end';
  static const officeLocInvalid = 'office_loc.invalid';
  static const officeLocSaved = 'office_loc.saved';

  // Leave
  static const leaveTitle = 'leave.title';
  static const leaveBalance = 'leave.balance';
  static const leaveRemaining = 'leave.remaining';
  static const leaveMyRequests = 'leave.my_requests';
  static const leaveNew = 'leave.new';
  static const leaveType = 'leave.type';
  static const leaveTypeCasual = 'leave.type_casual';
  static const leaveTypeSick = 'leave.type_sick';
  static const leaveTypeAnnual = 'leave.type_annual';
  static const leaveTypeUnpaid = 'leave.type_unpaid';
  static const leaveFrom = 'leave.from';
  static const leaveTo = 'leave.to';
  static const leaveReason = 'leave.reason';
  static const leaveSubmit = 'leave.submit';
  static const leaveDaysN = 'leave.days_n';
  static const leaveStatusPending = 'leave.status_pending';
  static const leaveStatusApproved = 'leave.status_approved';
  static const leaveStatusRejected = 'leave.status_rejected';
  static const leaveStatusCancelled = 'leave.status_cancelled';
  static const leaveSubmitted = 'leave.submitted';

  // Approvals
  static const approvalsTitle = 'approvals.title';
  static const approvalsEmpty = 'approvals.empty';
  static const approve = 'approvals.approve';
  static const reject = 'approvals.reject';

  // CRM
  static const navFollowUps = 'crm.nav_follow_ups';
  static const crmSearch = 'crm.search';
  static const crmValue = 'crm.value';
  static const crmSource = 'crm.source';
  static const crmHistory = 'crm.history';
  static const crmMoveStage = 'crm.move_stage';
  static const crmEmpty = 'crm.empty';
  static const crmCall = 'crm.call';
  static const crmMessage = 'crm.message';
  static const followUpsTitle = 'crm.follow_ups_title';
  static const followUpLogOutcome = 'crm.log_outcome';
  static const stageNewLead = 'crm.stage_new_lead';
  static const stageContacted = 'crm.stage_contacted';
  static const stageInterested = 'crm.stage_interested';
  static const stageFollowUp = 'crm.stage_follow_up';
  static const stageNegotiation = 'crm.stage_negotiation';
  static const stageConverted = 'crm.stage_converted';
  static const stageLost = 'crm.stage_lost';
  static const outcomeReached = 'crm.outcome_reached';
  static const outcomeNoAnswer = 'crm.outcome_no_answer';
  static const outcomeRescheduled = 'crm.outcome_rescheduled';
  static const outcomeNotInterested = 'crm.outcome_not_interested';
  static const outcomeWon = 'crm.outcome_won';

  // Reports
  static const reportsTitle = 'reports.title';
  static const repConverted = 'reports.converted';
  static const repPipeline = 'reports.pipeline';
  static const repRevenue = 'reports.revenue';
  static const repOutstanding = 'reports.outstanding';
  static const repDues = 'reports.dues';
  static const repVisaApproved = 'reports.visa_approved';
  static const repVisaInProgress = 'reports.visa_in_progress';
  static const repMonthlyRevenue = 'reports.monthly_revenue';

  // Documents
  static const docExpiring = 'doc.expiring';
  static const docExpired = 'doc.expired';
  static const docExpires = 'doc.expires';
  static const docCatPassport = 'doc.cat_passport';
  static const docCatVisa = 'doc.cat_visa';
  static const docCatTicket = 'doc.cat_ticket';
  static const docCatContract = 'doc.cat_contract';
  static const docCatInvoice = 'doc.cat_invoice';
  static const docCatAgreement = 'doc.cat_agreement';
  static const docCatCertificate = 'doc.cat_certificate';
  static const docCatNid = 'doc.cat_nid';
  static const docCatOther = 'doc.cat_other';

  // Travel — travellers
  static const travellersTitle = 'trav.title';
  static const travSearch = 'trav.search';
  static const travPassport = 'trav.passport';
  static const travPassportNo = 'trav.passport_no';
  static const travExpiry = 'trav.expiry';
  static const travNationality = 'trav.nationality';
  static const travDob = 'trav.dob';
  static const travTrips = 'trav.trips';
  static const travHistory = 'trav.history';
  static const travPassportExpired = 'trav.passport_expired';
  static const travPassportSoon = 'trav.passport_soon';
  static const travNew = 'trav.new';
  static const travFullName = 'trav.full_name';
  static const travPhone = 'trav.phone';
  static const travCreated = 'trav.created';

  // Travel — bookings
  static const bookingsTitle = 'bk.title';
  static const departuresTitle = 'bk.departures_title';
  static const bkRef = 'bk.ref';
  static const bkIssue = 'bk.issue';
  static const bkCancel = 'bk.cancel';
  static const bkSegments = 'bk.segments';
  static const bkHotel = 'bk.hotel';
  static const bkItinerary = 'bk.itinerary';
  static const bkNew = 'bk.new';
  static const bkTraveller = 'bk.traveller';
  static const bkAmount = 'bk.amount';
  static const bkDate = 'bk.date';
  static const bkCreated = 'bk.created';
  static const bkKindFlight = 'bk.kind_flight';
  static const bkKindHotel = 'bk.kind_hotel';
  static const bkKindPackage = 'bk.kind_package';
  static const bkStatusHeld = 'bk.status_held';
  static const bkStatusTicketed = 'bk.status_ticketed';
  static const bkStatusCancelled = 'bk.status_cancelled';
  static const bkStatusCompleted = 'bk.status_completed';

  // Travel — visa
  static const visaStageCase = 'visa.stage_case';
  static const visaStageDocsRequired = 'visa.stage_docs_required';
  static const visaStageDocsCollected = 'visa.stage_docs_collected';
  static const visaStageSubmitted = 'visa.stage_submitted';
  static const visaStageProcessing = 'visa.stage_processing';
  static const visaStageApproved = 'visa.stage_approved';
  static const visaStageRejected = 'visa.stage_rejected';
  static const visaDocsChecklist = 'visa.docs_checklist';
  static const visaSubmit = 'visa.submit';
  static const visaSubmitBlocked = 'visa.submit_blocked';
  static const visaSubmittedOn = 'visa.submitted_on';
  static const visaDecidedOn = 'visa.decided_on';
  static const visaDecision = 'visa.decision';
  static const visaApprove = 'visa.approve';
  static const visaReject = 'visa.reject';
  static const visaStartProcessing = 'visa.start_processing';

  // Expenses
  static const expensesTitle = 'exp.title';
  static const expenseNew = 'exp.new';
  static const expenseAmount = 'exp.amount';
  static const expenseCategory = 'exp.category';
  static const expenseDate = 'exp.date';
  static const expenseNote = 'exp.note';
  static const expenseReceipt = 'exp.receipt';
  static const expenseSubmit = 'exp.submit';
  static const expenseSubmitted = 'exp.submitted';
  static const expenseEmpty = 'exp.empty';
  static const expCatTravel = 'exp.cat_travel';
  static const expCatMeals = 'exp.cat_meals';
  static const expCatOffice = 'exp.cat_office';
  static const expCatSupplier = 'exp.cat_supplier';
  static const expCatOther = 'exp.cat_other';
  static const expStatusPending = 'exp.status_pending';
  static const expStatusApproved = 'exp.status_approved';
  static const expStatusRejected = 'exp.status_rejected';
  static const expStatusReimbursed = 'exp.status_reimbursed';

  // Invoices / payments
  static const invoicesTitle = 'inv.title';
  static const invRef = 'inv.ref';
  static const invCustomer = 'inv.customer';
  static const invAmount = 'inv.amount';
  static const invPaid = 'inv.paid';
  static const invDue = 'inv.due';
  static const invDueDate = 'inv.due_date';
  static const invBooking = 'inv.booking';
  static const invOutstanding = 'inv.outstanding';
  static const invPayments = 'inv.payments';
  static const invNoPayments = 'inv.no_payments';
  static const invRecordPayment = 'inv.record_payment';
  static const invPaymentAmount = 'inv.payment_amount';
  static const invPaymentMethod = 'inv.payment_method';
  static const invPaymentNote = 'inv.payment_note';
  static const invPaymentRecorded = 'inv.payment_recorded';
  static const invCreateFromBooking = 'inv.create_from_booking';
  static const invCreated = 'inv.created';
  static const invStatusUnpaid = 'inv.status_unpaid';
  static const invStatusPartial = 'inv.status_partial';
  static const invStatusPaid = 'inv.status_paid';
  static const invStatusOverdue = 'inv.status_overdue';
  static const invStatusCancelled = 'inv.status_cancelled';

  // Team directory
  static const teamTitle = 'team.title';
  static const teamSearch = 'team.search';
  static const empStatusActive = 'team.status_active';
  static const empStatusOnLeave = 'team.status_on_leave';
  static const empStatusInactive = 'team.status_inactive';

  // Holidays
  static const holidaysTitle = 'hol.title';
  static const holidaysUpcoming = 'hol.upcoming';
  static const holidaysPast = 'hol.past';
  static const holidaysEmpty = 'hol.empty';

  // Task comments
  static const taskNoComments = 'tasks.no_comments';

  // Tasks
  static const tasksEmpty = 'tasks.empty';
  static const taskStatusOpen = 'tasks.status_open';
  static const taskStatusInProgress = 'tasks.status_in_progress';
  static const taskStatusBlocked = 'tasks.status_blocked';
  static const taskStatusDone = 'tasks.status_done';
  static const taskPriorityLow = 'tasks.priority_low';
  static const taskPriorityNormal = 'tasks.priority_normal';
  static const taskPriorityHigh = 'tasks.priority_high';
  static const taskPriorityUrgent = 'tasks.priority_urgent';
  static const taskSubtasks = 'tasks.subtasks';
  static const taskComments = 'tasks.comments';
  static const taskAddComment = 'tasks.add_comment';
  static const taskDue = 'tasks.due';
  static const taskMarkDone = 'tasks.mark_done';
  static const taskReopen = 'tasks.reopen';
  static const taskNew = 'tasks.new';
  static const taskTitle = 'tasks.title_field';
  static const taskPriority = 'tasks.priority';
  static const taskAssignee = 'tasks.assignee';
  static const taskDueDate = 'tasks.due_date';
  static const taskCreated = 'tasks.created';
  static const viewAll = 'common.view_all';
  static const seeAll = 'common.see_all';

  // Common — state views
  static const emptyTitle = 'common.empty_title';
  static const errorTitle = 'common.error_title';
  static const offlineTitle = 'common.offline_title';
  static const offlineBody = 'common.offline_body';
  static const loading = 'common.loading';

  // Auth
  static const signInTitle = 'auth.sign_in_title';
  static const email = 'auth.email';
  static const password = 'auth.password';
  static const signIn = 'auth.sign_in';
  static const forgotPassword = 'auth.forgot_password';
  static const activationHint = 'auth.activation_hint';
  static const signOut = 'auth.sign_out';
  static const sessionEnded = 'auth.session_ended';

  // Shell / nav
  static const navHome = 'nav.home';
  static const navCustomers = 'nav.customers';
  static const navVisa = 'nav.visa';
  static const navTasks = 'nav.tasks';
  static const navMore = 'nav.more';

  // Workspace (the "More" tab)
  static const workspaceTitle = 'workspace.title';
  static const wsProfile = 'workspace.profile';
  static const wsAttendance = 'workspace.attendance';
  static const wsLeave = 'workspace.leave';
  static const wsExpenses = 'workspace.expenses';
  static const wsDocuments = 'workspace.documents';
  static const wsTeam = 'workspace.team';
  static const wsCrm = 'workspace.crm';
  static const wsReports = 'workspace.reports';
  static const wsApprovals = 'workspace.approvals';
  static const wsOfficeLocation = 'workspace.office_location';
  static const wsSettings = 'workspace.settings';
  static const wsHelp = 'workspace.help';
  static const wsTravellers = 'workspace.travellers';
  static const wsBookings = 'workspace.bookings';
  static const wsDepartures = 'workspace.departures';
  static const wsInvoices = 'workspace.invoices';
  static const wsHolidays = 'workspace.holidays';
  static const wsSectionTravel = 'workspace.section_travel';
  static const wsSectionWork = 'workspace.section_work';
  static const wsSectionManage = 'workspace.section_manage';
  static const wsSectionAccount = 'workspace.section_account';

  // Home dashboard
  static const greetingMorning = 'home.greeting_morning';
  static const greetingAfternoon = 'home.greeting_afternoon';
  static const greetingEvening = 'home.greeting_evening';
  static const homeVisaSummary = 'home.visa_summary';
  static const homeVisaDocs = 'home.visa_docs';
  static const homeFollowUps = 'home.follow_ups';
  static const homeTicketTasks = 'home.ticket_tasks';
  static const homeMyTasks = 'home.my_tasks';
  static const homeQuickActions = 'home.quick_actions';
  static const homeQaNewCustomer = 'home.qa_new_customer';
  static const homeQaNewTask = 'home.qa_new_task';
  static const homeQaCheckIn = 'home.qa_check_in';
  static const homeQaNewBooking = 'home.qa_new_booking';
  static const homeNothingToday = 'home.nothing_today';
  static const homeVisaInProgress = 'home.visa_in_progress';
  static const homeVisaAwaitingDocs = 'home.visa_awaiting_docs';
  static const homeVisaDecisionDue = 'home.visa_decision_due';

  // Settings
  static const settingsTitle = 'settings.title';
  static const settingsAppearance = 'settings.appearance';
  static const settingsThemeSystem = 'settings.theme_system';
  static const settingsThemeLight = 'settings.theme_light';
  static const settingsThemeDark = 'settings.theme_dark';
  static const settingsLanguage = 'settings.language';

  // Placeholder copy
  static const comingSoon = 'home.coming_soon';
}
