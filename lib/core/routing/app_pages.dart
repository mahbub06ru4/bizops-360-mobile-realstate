import 'package:get/get.dart';

import '../../modules/real_estate/buyer/browse/screens/browse_screen.dart';
import '../../modules/real_estate/buyer/buyer_bindings.dart';
import '../../modules/real_estate/buyer/compare/screens/compare_screen.dart';
import '../../modules/real_estate/buyer/my_properties/screens/my_properties_screen.dart';
import '../../modules/real_estate/buyer/profile/screens/buyer_profile_screen.dart';
import '../../modules/real_estate/buyer/saved/screens/saved_screen.dart';
import '../../modules/real_estate/buyer/shell/buyer_shell_screen.dart';
import '../../modules/real_estate/offers/bindings/offers_binding.dart';
import '../../modules/real_estate/offers/screens/new_offer_screen.dart';
import '../../modules/real_estate/offers/screens/offer_thread_screen.dart';
import '../../modules/real_estate/offers/screens/offers_screen.dart';
import '../../modules/real_estate/projects/bindings/real_estate_bindings.dart';
import '../../modules/real_estate/projects/screens/post_project_screen.dart';
import '../../modules/real_estate/projects/screens/project_detail_screen.dart';
import '../../modules/real_estate/projects/screens/projects_screen.dart';
import '../../modules/real_estate/re_bookings/bindings/re_bookings_binding.dart';
import '../../modules/real_estate/re_bookings/screens/re_booking_detail_screen.dart';
import '../../modules/real_estate/re_bookings/screens/re_bookings_screen.dart';
import '../../modules/real_estate/requirements/bindings/requirements_binding.dart';
import '../../modules/real_estate/requirements/screens/matches_screen.dart';
import '../../modules/real_estate/requirements/screens/requirement_form_screen.dart';
import '../../modules/real_estate/site_visits/bindings/site_visits_binding.dart';
import '../../modules/real_estate/site_visits/screens/site_visits_screen.dart';
import '../../presentation/auth/bindings/plan_selection_binding.dart';
import '../../presentation/auth/bindings/register_binding.dart';
import '../../presentation/auth/bindings/sign_in_binding.dart';
import '../../presentation/auth/screens/plan_selection_screen.dart';
import '../../presentation/auth/screens/register_screen.dart';
import '../../presentation/auth/screens/sign_in_screen.dart';
import '../../presentation/common/coming_soon_screen.dart';
import '../../presentation/crm/bindings/crm_bindings.dart';
import '../../presentation/crm/screens/customer_detail_screen.dart';
import '../../presentation/crm/screens/follow_ups_screen.dart';
import '../../presentation/documents/bindings/documents_binding.dart';
import '../../presentation/documents/screens/documents_screen.dart';
import '../../presentation/expenses/bindings/expenses_binding.dart';
import '../../presentation/expenses/screens/expense_new_screen.dart';
import '../../presentation/expenses/screens/expenses_screen.dart';
import '../../presentation/finance/bindings/finance_bindings.dart';
import '../../presentation/finance/screens/invoice_detail_screen.dart';
import '../../presentation/finance/screens/invoices_screen.dart';
import '../../presentation/hr/bindings/hr_bindings.dart';
import '../../presentation/hr/screens/approvals_screen.dart';
import '../../presentation/hr/screens/attendance_screen.dart';
import '../../presentation/hr/screens/holidays_screen.dart';
import '../../presentation/hr/screens/leave_request_screen.dart';
import '../../presentation/hr/screens/leave_screen.dart';
import '../../presentation/hr/screens/office_location_screen.dart';
import '../../presentation/notifications/bindings/notifications_binding.dart';
import '../../presentation/notifications/screens/notifications_screen.dart';
import '../../presentation/profile/screens/profile_screen.dart';
import '../../presentation/reports/bindings/reports_binding.dart';
import '../../presentation/reports/screens/reports_screen.dart';
import '../../presentation/settings/screens/settings_screen.dart';
import '../../presentation/shell/bindings/shell_binding.dart';
import '../../presentation/shell/screens/shell_screen.dart';
import '../../presentation/splash/splash_binding.dart';
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/tasks/bindings/task_detail_binding.dart';
import '../../presentation/tasks/screens/task_detail_screen.dart';
import '../../presentation/team/bindings/team_binding.dart';
import '../../presentation/team/screens/team_screen.dart';
import 'app_routes.dart';
import 'route_guard.dart';

abstract final class AppPages {
  static const initial = Routes.splash;

  static GetPage<dynamic> _guarded(
    String name,
    GetPageBuilder page, {
    Bindings? binding,
  }) => GetPage(
    name: name,
    page: page,
    binding: binding,
    middlewares: [AuthGuard()],
  );

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.signIn,
      page: () => const SignInScreen(),
      binding: SignInBinding(),
      middlewares: [AuthGuard()],
    ),
    // No AuthGuard — reachable by a signed-out visitor from the sign-in
    // screen's "Create your business" link (roadmap §7 Phase 3 self-serve
    // onboarding).
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    _guarded(
      Routes.planSelection,
      () => const PlanSelectionScreen(),
      binding: PlanSelectionBinding(),
    ),
    _guarded(Routes.shell, () => const ShellScreen(), binding: ShellBinding()),
    _guarded(
      Routes.buyerShell,
      () => const BuyerShellScreen(),
      binding: BuyerShellBinding(),
    ),
    _guarded(
      Routes.buyerBrowse,
      () => const BrowseScreen(),
      binding: BrowseBinding(),
    ),
    _guarded(
      Routes.buyerSaved,
      () => const SavedScreen(),
      binding: SavedBinding(),
    ),
    _guarded(
      Routes.buyerCompare,
      () => const CompareScreen(),
      binding: CompareBinding(),
    ),
    _guarded(
      Routes.buyerMyProperties,
      () => const MyPropertiesScreen(),
      binding: MyPropertiesBinding(),
    ),
    _guarded(
      Routes.buyerProfile,
      () => const BuyerProfileScreen(),
      binding: BuyerProfileBinding(),
    ),
    _guarded(
      Routes.notifications,
      () => const NotificationsScreen(),
      binding: NotificationsBinding(),
    ),
    _guarded(
      Routes.taskDetail,
      () => const TaskDetailScreen(),
      binding: TaskDetailBinding(),
    ),
    _guarded(
      Routes.attendance,
      () => const AttendanceScreen(),
      binding: AttendanceBinding(),
    ),
    _guarded(
      Routes.officeLocation,
      () => const OfficeLocationScreen(),
      binding: OfficeLocationBinding(),
    ),
    _guarded(Routes.leave, () => const LeaveScreen(), binding: LeaveBinding()),
    // No binding — reuses the LeaveController from the LeaveScreen beneath it.
    _guarded(Routes.leaveRequest, () => const LeaveRequestScreen()),
    _guarded(
      Routes.approvals,
      () => const ApprovalsScreen(),
      binding: ApprovalsBinding(),
    ),
    _guarded(
      Routes.customerDetail,
      () => const CustomerDetailScreen(),
      binding: CustomerDetailBinding(),
    ),
    _guarded(
      Routes.followUps,
      () => const FollowUpsScreen(),
      binding: FollowUpsBinding(),
    ),
    _guarded(
      Routes.expenses,
      () => const ExpensesScreen(),
      binding: ExpensesBinding(),
    ),
    // No binding — reuses the ExpensesController from the ExpensesScreen beneath.
    _guarded(Routes.expenseNew, () => const ExpenseNewScreen()),
    _guarded(
      Routes.documents,
      () => const DocumentsScreen(),
      binding: DocumentsBinding(),
    ),
    _guarded(
      Routes.projects,
      () => const ProjectsScreen(),
      binding: ProjectsBinding(),
    ),
    _guarded(
      Routes.postProject,
      () => const PostProjectScreen(),
      binding: PostProjectBinding(),
    ),
    _guarded(
      Routes.projectDetail,
      () => const ProjectDetailScreen(),
      binding: ProjectDetailBinding(),
    ),
    _guarded(
      Routes.requirementForm,
      () => const RequirementFormScreen(),
      binding: RequirementFormBinding(),
    ),
    _guarded(
      Routes.propertyMatches,
      () => const MatchesScreen(),
      binding: MatchesBinding(),
    ),
    _guarded(
      Routes.siteVisits,
      () => const SiteVisitsScreen(),
      binding: SiteVisitsBinding(),
    ),
    _guarded(
      Routes.offers,
      () => const OffersScreen(),
      binding: OffersBinding(),
    ),
    _guarded(
      Routes.offerThread,
      () => const OfferThreadScreen(),
      binding: OfferThreadBinding(),
    ),
    _guarded(
      Routes.newOffer,
      () => const NewOfferScreen(),
      binding: NewOfferBinding(),
    ),
    _guarded(
      Routes.reBookings,
      () => const ReBookingsScreen(),
      binding: ReBookingsBinding(),
    ),
    _guarded(
      Routes.reBookingDetail,
      () => const ReBookingDetailScreen(),
      binding: ReBookingDetailBinding(),
    ),
    _guarded(
      Routes.reports,
      () => const ReportsScreen(),
      binding: ReportsBinding(),
    ),
    _guarded(
      Routes.invoices,
      () => const InvoicesScreen(),
      binding: InvoicesBinding(),
    ),
    _guarded(
      Routes.invoiceDetail,
      () => const InvoiceDetailScreen(),
      binding: InvoiceDetailBinding(),
    ),
    _guarded(Routes.team, () => const TeamScreen(), binding: TeamBinding()),
    _guarded(
      Routes.holidays,
      () => const HolidaysScreen(),
      binding: HolidaysBinding(),
    ),
    _guarded(Routes.settings, () => const SettingsScreen()),
    _guarded(Routes.profile, () => const ProfileScreen()),
    _guarded(Routes.comingSoon, () => const ComingSoonScreen()),
  ];
}
