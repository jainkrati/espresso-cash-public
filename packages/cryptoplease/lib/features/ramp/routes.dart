import 'package:auto_route/auto_route.dart';

import 'src/widgets/off_ramp_screen.dart';
import 'src/widgets/on_ramp_screen.dart';

const rampRoutes = [
  AutoRoute<void>(page: OnRampScreen, fullscreenDialog: true),
  AutoRoute<void>(page: OffRampScreen, fullscreenDialog: true),
];
