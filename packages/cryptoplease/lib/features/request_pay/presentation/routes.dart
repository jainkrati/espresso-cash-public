import 'package:auto_route/auto_route.dart';
import 'package:cryptoplease/features/request_pay/presentation/screens/direct_pay_screen.dart';
import 'package:decimal/decimal.dart';

const requestDirectRoutes = [
  AutoRoute<Decimal>(page: DirectPayScreen),
];
