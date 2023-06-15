import 'package:auto_route/auto_route.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:solana/solana.dart';

import '../../../../../l10n/l10n.dart';
import '../../../config.dart';
import '../../../core/accounts/bl/account.dart';
import '../../../core/balances/context_ext.dart';
import '../../../core/tokens/token.dart';
import '../../../routes.gr.dart';
import '../../../ui/button.dart';
import 'extensions.dart';

class AddCashButton extends StatelessWidget {
  const AddCashButton({
    super.key,
    this.size = CpButtonSize.normal,
  });

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

class CashOutButton extends StatefulWidget {
  const CashOutButton({
    super.key,
    this.size = CpButtonSize.normal,
  });

  final CpButtonSize size;

  @override
  State<CashOutButton> createState() => _CashOutButtonState();
}

class _CashOutButtonState extends State<CashOutButton> {
  Future<void> onOffRamp(
    BuildContext context, {
    required Decimal amount,
    required Ed25519HDPublicKey recipient,
  }) async {
    final confirmedAmount = await context.router.push<bool>(
      OffRampConfirmationRoute(
        amount: amount.toString(),
        recipient: recipient,
        provider: 'Ramp Network',
        token: Token.usdc,
      ),
    );

    if (confirmedAmount == null) return;

    if (!mounted) return;
    final id = await context.createORP(
      amountInUsdc: amount,
      receiver: recipient,
    );

    if (!mounted) return;
    await context.router.push(OffRampDetailsRoute(id: id));
  }

  @override
  Widget build(BuildContext context) => Flexible(
        child: CpButton(
          size: widget.size,
          minWidth: 250,
          text: context.l10n.cashOut,
          onPressed: () {
            final configuration = _defaultConfiguration
              ..defaultFlow = 'OFFRAMP'
              ..useSendCryptoCallback = true
              ..userAddress =
                  context.read<MyAccount>().wallet.publicKey.toBase58();

            RampFlutter()
              ..onRampClosed = () {
                context.notifyBalanceAffected();
              }
              ..onSendCryptoRequested = (payload) {
                print('offramp created: $payload'); //TODO

                onOffRamp(
                  context,
                  amount: Decimal.fromInt(1),
                  recipient: Ed25519HDPublicKey.fromBase58(
                    'HH9LcH8Uzt3wkryUN8fmDcyw6C8FbtPtVbvfQVHLWH7W',
                  ),
                );
              }
              ..showRamp(configuration);
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
