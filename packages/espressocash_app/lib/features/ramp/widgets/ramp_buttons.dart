import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/ramp_flutter.dart';

import '../../../../../l10n/l10n.dart';
import '../../../config.dart';
import '../../../core/accounts/bl/account.dart';
import '../../../core/balances/context_ext.dart';
import '../../../ui/button.dart';

class AddCashButton extends StatelessWidget {
  const AddCashButton({
    Key? key,
    this.size = CpButtonSize.normal,
  }) : super(key: key);

  final CpButtonSize size;

  @override
  Widget build(BuildContext context) => Flexible(
        child: CpButton(
          size: size,
          minWidth: 250,
          text: context.l10n.addCash,
          onPressed: () {
            final configuration = _defaultConfiguration
              ..defaultFlow = 'ONRAMP'
              ..userAddress =
                  context.read<MyAccount>().wallet.publicKey.toBase58();

            RampFlutter()
              ..onRampClosed = () {
                context.notifyBalanceAffected();
              }
              ..showRamp(configuration);
          },
        ),
      );
}

class CashOutButton extends StatelessWidget {
  const CashOutButton({
    Key? key,
    this.size = CpButtonSize.normal,
  }) : super(key: key);

  final CpButtonSize size;

  @override
  Widget build(BuildContext context) => Flexible(
        child: CpButton(
          size: size,
          minWidth: 250,
          text: context.l10n.cashOut,
          onPressed: () {
            final configuration = _defaultConfiguration
              ..defaultFlow = 'OFFRAMP'
              ..useSendCryptoCallback = true
              ..userAddress =
                  context.read<MyAccount>().wallet.publicKey.toBase58();

            final ramp = RampFlutter()
              ..onRampClosed = () {
                context.notifyBalanceAffected();
              }
              ..onSendCryptoRequested = (payload) {
                print('offramp created: $payload');
              }
              ..showRamp(configuration);

            // ramp.sendCrypto('todo');
          },
        ),
      );
}

final _defaultConfiguration = Configuration()
  ..hostApiKey = rampApiKey
  ..hostAppName = 'Espresso Cash'
  ..hostLogoUrl =
      'https://www.espressocash.com/landing/img/asset-2-2x-copy@2x.png'
  ..swapAsset = 'SOLANA_USDC'
  ..defaultAsset = 'SOLANA_USDC';
