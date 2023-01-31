import 'package:dfunc/dfunc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:solana/solana.dart';

import '../../../../config.dart';
import '../../../../core/presentation/utils.dart';
import '../../../../core/tokens/token.dart';
import '../../../../di.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../l10n/l10n.dart';
import '../../../../ui/app_bar.dart';
import '../../../../ui/colors.dart';
import '../../../../ui/content_padding.dart';
import '../../../../ui/dialogs.dart';
import '../../../../ui/loader.dart';
import '../../../../ui/partner_button.dart';
import '../../../../ui/theme.dart';
import '../bl/on_ramp_bloc.dart';

class OffRampScreen extends StatelessWidget {
  const OffRampScreen({
    Key? key,
    required this.token,
    required this.wallet,
  }) : super(key: key);

  final Token token;
  final Wallet wallet;

  @override
  Widget build(BuildContext context) => BlocProvider<OnRampBloc>(
        //DELETE bloc
        create: (_) => sl<OnRampBloc>(
          param1: token,
          param2: wallet,
        ),
        child: BlocConsumer<OnRampBloc, OnRampState>(
          listener: (context, state) => state.maybeWhen(
            failure: (_) => showWarningDialog(
              context,
              title: context.l10n.buySolFailedTitle,
              message: context.l10n.buySolFailedMessage,
            ),
            success: context.openLink,
            orElse: ignore,
          ),
          builder: (context, state) => CpTheme.dark(
            child: Scaffold(
              backgroundColor: CpColors.darkBackground,
              appBar: CpAppBar(
                leading: const CloseButton(),
                title: const Text('CASH OUT'),
              ),
              body: CpLoader(
                isLoading: state.isProcessing(),
                child: CpContentPadding(
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    children: [
                      const Text(
                        'Cash out with one\nof our secure partners.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.5),
                      ),
                      const SizedBox(height: 24),
                      PartnerButton(
                        onTap: () {
                          final Configuration configuration = Configuration()
                            ..hostAppName = 'Espresso Cash'
                            ..hostLogoUrl =
                                'https://www.espressocash.com/landing/img/asset-2-2x@2x.png'
                            ..hostApiKey = rampApiKey
                            // ..enabledFlows = ['OFFRAMP']
                            ..defaultAsset = 'SOLANA_USDC'
                            ..swapAsset = 'SOLANA_USDC'
                            // ..offrampAsset = 'SOLANA_USDC'
                            ..userAddress = wallet.address
                            ..url = 'https://ri-widget-staging.firebaseapp.com';

                          RampFlutter.showRamp(
                            configuration,
                            (_, __, ___) {},
                            () {},
                            () {},
                          );
                        },
                        image: Assets.images.logoRamp,
                        backgroundColor: const Color(0xff5272d6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
