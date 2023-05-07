import 'package:auto_route/auto_route.dart';

import 'src/widgets/off_ramp_confirmation_screen.dart';
import 'src/widgets/off_ramp_details_screen.dart';

const rampRoutes = [
  AutoRoute<bool>(page: OffRampConfirmationScreen),
  AutoRoute<void>(page: OffRampDetailsScreen),
];
