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

  // Real estate — projects (seller "my projects" list + shared detail)
  static const projTitle = 'proj.title';
  static const projNew = 'proj.new';
  static const projEmpty = 'proj.empty';
  static const projStatusDraft = 'proj.status_draft';
  static const projStatusSubmitted = 'proj.status_submitted';
  static const projStatusVerified = 'proj.status_verified';
  static const projStatusRejected = 'proj.status_rejected';
  static const projTypeLandShare = 'proj.type_land_share';
  static const projTypeApartment = 'proj.type_apartment';
  static const projTypeCommercial = 'proj.type_commercial';
  static const projLocation = 'proj.location';
  static const projUnits = 'proj.units';
  static const projSubmit = 'proj.submit';
  static const projSubmitted = 'proj.submitted';
  static const projPricing = 'proj.pricing';
  static const projLandCost = 'proj.land_cost';
  static const projConstructionCost = 'proj.construction_cost';
  static const projConsultancyCost = 'proj.consultancy_cost';
  static const projEstimatedTotal = 'proj.estimated_total';
  static const projPaymentPlan = 'proj.payment_plan';
  static const projAmenities = 'proj.amenities';
  static const projBuildings = 'proj.buildings';
  static const projContact = 'proj.contact';
  static const projDescription = 'proj.description';
  static const unitStatusAvailable = 'proj.unit_status_available';
  static const unitStatusReserved = 'proj.unit_status_reserved';
  static const unitStatusSold = 'proj.unit_status_sold';

  static const unitFacingNorth = 'proj.unit_facing_north';
  static const unitFacingSouth = 'proj.unit_facing_south';
  static const unitFacingEast = 'proj.unit_facing_east';
  static const unitFacingWest = 'proj.unit_facing_west';
  static const unitFacingNortheast = 'proj.unit_facing_northeast';
  static const unitFacingNorthwest = 'proj.unit_facing_northwest';
  static const unitFacingSoutheast = 'proj.unit_facing_southeast';
  static const unitFacingSouthwest = 'proj.unit_facing_southwest';

  // Real estate — Phase 1 requirement capture + matching
  static const reqTitle = 'req.title';
  static const reqCapture = 'req.capture';
  static const reqType = 'req.type';
  static const reqMinBudget = 'req.min_budget';
  static const reqMaxBudget = 'req.max_budget';
  static const reqPreferredLocations = 'req.preferred_locations';
  static const reqBedroomsMin = 'req.bedrooms_min';
  static const reqPurpose = 'req.purpose';
  static const reqPurposeBuy = 'req.purpose_buy';
  static const reqPurposeInvest = 'req.purpose_invest';
  static const reqNotes = 'req.notes';
  static const reqSaveAndMatch = 'req.save_and_match';
  static const reqSaved = 'req.saved';
  static const reqMatchesTitle = 'req.matches_title';
  static const reqMatchesEmpty = 'req.matches_empty';
  static const reqRematch = 'req.rematch';
  static const matchStatusSuggested = 'match.status_suggested';
  static const matchStatusViewed = 'match.status_viewed';
  static const matchStatusInterested = 'match.status_interested';
  static const matchStatusRejected = 'match.status_rejected';

  // Real estate — site visits
  static const svTitle = 'sv.title';
  static const svEmpty = 'sv.empty';
  static const svSchedule = 'sv.schedule';
  static const svScheduledAt = 'sv.scheduled_at';
  static const svLead = 'sv.lead';
  static const svProject = 'sv.project';
  static const svUnit = 'sv.unit';
  static const svComplete = 'sv.complete';
  static const svCancel = 'sv.cancel';
  static const svStatusScheduled = 'sv.status_scheduled';
  static const svStatusCompleted = 'sv.status_completed';
  static const svStatusCancelled = 'sv.status_cancelled';
  static const svStatusNoShow = 'sv.status_no_show';
  static const svScheduled = 'sv.scheduled_snackbar';
  static const svCompleted = 'sv.completed_snackbar';
  static const svCancelled = 'sv.cancelled_snackbar';

  // Real estate — offers / negotiation
  static const offerTitle = 'offer.title';
  static const offerEmpty = 'offer.empty';
  static const offerNew = 'offer.new';
  static const offerAmount = 'offer.amount';
  static const offerNote = 'offer.note';
  static const offerMake = 'offer.make';
  static const offerCounter = 'offer.counter';
  static const offerAccept = 'offer.accept';
  static const offerReject = 'offer.reject';
  static const offerAccepted = 'offer.accepted_snackbar';
  static const offerRejected = 'offer.rejected_snackbar';
  static const offerCountered = 'offer.countered_snackbar';
  static const offerMadeSnackbar = 'offer.made_snackbar';
  static const offerStatusPending = 'offer.status_pending';
  static const offerStatusCountered = 'offer.status_countered';
  static const offerStatusAccepted = 'offer.status_accepted';
  static const offerStatusRejected = 'offer.status_rejected';
  static const offerStatusExpired = 'offer.status_expired';
  static const offerByBuyer = 'offer.by_buyer';
  static const offerBySeller = 'offer.by_seller';
  static const offerReserveBooking = 'offer.reserve_booking';
  static const offerBookingReserved = 'offer.booking_reserved_snackbar';

  // Real estate — bookings & installments
  static const bookTitle = 'book.title';
  static const bookEmpty = 'book.empty';
  static const bookPrice = 'book.price';
  static const bookConfirm = 'book.confirm';
  static const bookCancel = 'book.cancel';
  static const bookStatusReserved = 'book.status_reserved';
  static const bookStatusBooked = 'book.status_booked';
  static const bookStatusCancelled = 'book.status_cancelled';
  static const bookStatusCompleted = 'book.status_completed';
  static const bookInstallmentPlan = 'book.installment_plan';
  static const bookCreatePlan = 'book.create_plan';
  static const bookDownPayment = 'book.down_payment';
  static const bookInstallmentCount = 'book.installment_count';
  static const bookNoPlan = 'book.no_plan';
  static const instDue = 'inst.due';
  static const instGenerateInvoice = 'inst.generate_invoice';
  static const instViewInvoice = 'inst.view_invoice';
  static const instMarkPaid = 'inst.mark_paid';
  static const instStatusPending = 'inst.status_pending';
  static const instStatusInvoiced = 'inst.status_invoiced';
  static const instStatusPaid = 'inst.status_paid';
  static const instStatusOverdue = 'inst.status_overdue';
  static const instInvoiceGenerated = 'inst.invoice_generated_snackbar';
  static const instMarkedPaid = 'inst.marked_paid_snackbar';

  // Real estate — Post Project wizard
  static const ppStepType = 'pp.step_type';
  static const ppStepLocation = 'pp.step_location';
  static const ppStepLand = 'pp.step_land';
  static const ppStepBuilding = 'pp.step_building';
  static const ppStepAmenities = 'pp.step_amenities';
  static const ppStepMedia = 'pp.step_media';
  static const ppStepContact = 'pp.step_contact';
  static const ppProjectTitle = 'pp.project_title';
  static const ppProjectDescription = 'pp.project_description';
  static const ppDivision = 'pp.division';
  static const ppDistrict = 'pp.district';
  static const ppArea = 'pp.area';
  static const ppSector = 'pp.sector';
  static const ppRoad = 'pp.road';
  static const ppLandmarks = 'pp.landmarks';
  static const ppLandSize = 'pp.land_size';
  static const ppLandCost = 'pp.land_cost';
  static const ppBuildingName = 'pp.building_name';
  static const ppFloors = 'pp.floors';
  static const ppUnitsPerFloor = 'pp.units_per_floor';
  static const ppConstructionCost = 'pp.construction_cost';
  static const ppUnitNumber = 'pp.unit_number';
  static const ppUnitSize = 'pp.unit_size';
  static const ppUnitPrice = 'pp.unit_price';
  static const ppUnitBedrooms = 'pp.unit_bedrooms';
  static const ppUnitBathrooms = 'pp.unit_bathrooms';
  static const ppUnitParkingSpaces = 'pp.unit_parking_spaces';
  static const ppUnitFacing = 'pp.unit_facing';
  static const ppCustomAmenity = 'pp.custom_amenity';
  static const ppAddPhotos = 'pp.add_photos';
  static const ppContactName = 'pp.contact_name';
  static const ppContactPhone = 'pp.contact_phone';
  static const ppNext = 'pp.next';
  static const ppBack = 'pp.back';
  static const ppFinish = 'pp.finish';
  static const ppCreated = 'pp.created';
  static const ppIncomplete = 'pp.incomplete';

  // Real estate — buyer persona (Phase 2)
  static const buyerContinueAsBuyer = 'buyer.continue_as_buyer';
  static const buyerNavBrowse = 'buyer.nav_browse';
  static const buyerNavSaved = 'buyer.nav_saved';
  static const buyerNavMyProperties = 'buyer.nav_my_properties';
  static const buyerNavProfile = 'buyer.nav_profile';
  static const buyerBrowseTitle = 'buyer.browse_title';
  static const buyerSearchHint = 'buyer.search_hint';
  static const buyerBrowseEmpty = 'buyer.browse_empty';
  static const buyerNoResults = 'buyer.no_results';
  static const buyerSave = 'buyer.save';
  static const buyerSaved = 'buyer.saved';
  static const buyerUnsave = 'buyer.unsave';
  static const buyerSavedTitle = 'buyer.saved_title';
  static const buyerSavedEmpty = 'buyer.saved_empty';
  static const buyerCompare = 'buyer.compare';
  static const buyerCompareTitle = 'buyer.compare_title';
  static const buyerCompareMax = 'buyer.compare_max';
  static const buyerCompareMinTwo = 'buyer.compare_min_two';
  static const buyerCompareNow = 'buyer.compare_now';
  static const buyerComparePrice = 'buyer.compare_price';
  static const buyerCompareDeveloper = 'buyer.compare_developer';
  static const buyerCompareLocation = 'buyer.compare_location';
  static const buyerCompareUnitTypes = 'buyer.compare_unit_types';
  static const buyerCompareAmenities = 'buyer.compare_amenities';
  static const buyerCompareVerification = 'buyer.compare_verification';
  static const buyerMyPropertiesTitle = 'buyer.my_properties_title';
  static const buyerMyPropertiesEmpty = 'buyer.my_properties_empty';
  static const buyerPaid = 'buyer.paid';
  static const buyerRemaining = 'buyer.remaining';
  static const buyerNextDue = 'buyer.next_due';
  static const buyerInstallmentTimeline = 'buyer.installment_timeline';
  static const buyerProfileTitle = 'buyer.profile_title';
  static const buyerSignOut = 'buyer.sign_out';

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
  static const empStatusProbation = 'team.status_probation';
  static const empStatusOnLeave = 'team.status_on_leave';
  static const empStatusTerminated = 'team.status_terminated';

  // Employee detail / form
  static const empDetailTitle = 'emp.detail_title';
  static const empCreateTitle = 'emp.create_title';
  static const empEditTitle = 'emp.edit_title';
  static const empCode = 'emp.code';
  static const empFirstName = 'emp.first_name';
  static const empLastName = 'emp.last_name';
  static const empEmail = 'emp.email';
  static const empPhone = 'emp.phone';
  static const empHireDate = 'emp.hire_date';
  static const empBranch = 'emp.branch';
  static const empDepartment = 'emp.department';
  static const empDesignation = 'emp.designation';
  static const empCreated = 'emp.created';
  static const empUpdated = 'emp.updated';
  static const empTerminate = 'emp.terminate';
  static const empTerminated = 'emp.terminated';
  static const empTerminateConfirmTitle = 'emp.terminate_confirm_title';
  static const empTerminateConfirmBody = 'emp.terminate_confirm_body';
  static const formRequiredFields = 'form.required_fields';

  // Common actions
  static const edit = 'common.edit';
  static const delete = 'common.delete';

  // Organization (branches / departments / designations / teams / users)
  static const orgBranches = 'org.branches';
  static const orgDepartments = 'org.departments';
  static const orgDesignations = 'org.designations';
  static const orgTeams = 'org.teams';
  static const orgUsers = 'org.users';
  static const orgTeamMembers = 'org.team_members';
  static const orgAddBranch = 'org.add_branch';
  static const orgEditBranch = 'org.edit_branch';
  static const orgAddDepartment = 'org.add_department';
  static const orgEditDepartment = 'org.edit_department';
  static const orgAddDesignation = 'org.add_designation';
  static const orgEditDesignation = 'org.edit_designation';
  static const orgAddTeam = 'org.add_team';
  static const orgEditTeam = 'org.edit_team';
  static const orgName = 'org.name';
  static const orgCode = 'org.code';
  static const orgAddress = 'org.address';
  static const orgDescription = 'org.description';
  static const orgTitle = 'org.title_field';
  static const orgRank = 'org.rank';
  static const orgHeadOffice = 'org.head_office';
  static const orgSaved = 'org.saved';
  static const orgDeleted = 'org.deleted';
  static const orgDeleteConfirmTitle = 'org.delete_confirm_title';
  static const orgDeleteConfirmBody = 'org.delete_confirm_body';
  static const orgMembersCount = 'org.members_count';
  static const orgAssignRoles = 'org.assign_roles';

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
  static const navProjects = 'nav.projects';
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
  static const wsBranches = 'workspace.branches';
  static const wsDepartments = 'workspace.departments';
  static const wsDesignations = 'workspace.designations';
  static const wsOrgTeams = 'workspace.org_teams';
  static const wsUsers = 'workspace.users';
  static const wsCrm = 'workspace.crm';
  static const wsReports = 'workspace.reports';
  static const wsApprovals = 'workspace.approvals';
  static const wsOfficeLocation = 'workspace.office_location';
  static const wsSettings = 'workspace.settings';
  static const wsHelp = 'workspace.help';
  static const wsProjects = 'workspace.projects';
  static const wsSiteVisits = 'workspace.site_visits';
  static const wsOffers = 'workspace.offers';
  static const wsBookings = 'workspace.bookings';
  static const wsInvoices = 'workspace.invoices';
  static const wsHolidays = 'workspace.holidays';
  static const wsSectionRealEstate = 'workspace.section_real_estate';
  static const wsSectionWork = 'workspace.section_work';
  static const wsSectionManage = 'workspace.section_manage';
  static const wsSectionAccount = 'workspace.section_account';

  // Home dashboard
  static const greetingMorning = 'home.greeting_morning';
  static const greetingAfternoon = 'home.greeting_afternoon';
  static const greetingEvening = 'home.greeting_evening';
  static const homeProjectsSummary = 'home.projects_summary';
  static const homeFollowUps = 'home.follow_ups';
  static const homeMyTasks = 'home.my_tasks';
  static const homeQuickActions = 'home.quick_actions';
  static const homeQaNewCustomer = 'home.qa_new_customer';
  static const homeQaNewTask = 'home.qa_new_task';
  static const homeQaCheckIn = 'home.qa_check_in';
  static const homeQaNewProject = 'home.qa_new_project';
  static const homeNothingToday = 'home.nothing_today';
  static const homeSalesOverview = 'home.sales_overview';
  static const homeSalesBookings = 'home.sales_bookings';
  static const homeSalesCollected = 'home.sales_collected';
  static const homeSalesPending = 'home.sales_pending';
  static const homeInventoryAvailable = 'home.inventory_available';
  static const homeInventoryReserved = 'home.inventory_reserved';
  static const homeInventorySold = 'home.inventory_sold';

  // Settings
  static const settingsTitle = 'settings.title';
  static const settingsAppearance = 'settings.appearance';
  static const settingsThemeSystem = 'settings.theme_system';
  static const settingsThemeLight = 'settings.theme_light';
  static const settingsThemeDark = 'settings.theme_dark';
  static const settingsLanguage = 'settings.language';

  // Self-serve tenant registration + plan selection (roadmap §7 Phase 3)
  static const registerCta = 'register.cta';
  static const registerTitle = 'register.title';
  static const registerSubtitle = 'register.subtitle';
  static const registerCompanyName = 'register.company_name';
  static const registerIndustry = 'register.industry';
  static const registerOwnerName = 'register.owner_name';
  static const registerOwnerEmail = 'register.owner_email';
  static const registerPassword = 'register.password';
  static const registerPasswordConfirm = 'register.password_confirm';
  static const registerSubmit = 'register.submit';
  static const registerRequired = 'register.required';
  static const registerPasswordTooShort = 'register.password_too_short';
  static const registerPasswordMismatch = 'register.password_mismatch';
  static const industryRealEstate = 'industry.real_estate';
  static const industryTravel = 'industry.travel';
  static const industryConsultancy = 'industry.consultancy';
  static const planTitle = 'plan.title';
  static const planSubtitle = 'plan.subtitle';
  static const planEmpty = 'plan.empty';
  static const planContinue = 'plan.continue';

  // Placeholder copy
  static const comingSoon = 'home.coming_soon';
}
