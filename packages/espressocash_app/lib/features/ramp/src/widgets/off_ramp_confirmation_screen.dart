import 'package:auto_route/auto_route.dart';
import 'package:decimal/decimal.dart';
import 'package:dfunc/dfunc.dart';
import 'package:flutter/material.dart';
import 'package:solana/solana.dart';

import '../../../../core/fee_label.dart';
import '../../../../core/tokens/token.dart';
import '../../../../l10n/device_locale.dart';
import '../../../../l10n/l10n.dart';
import '../../../../ui/amount_with_equivalent.dart';
import '../../../../ui/app_bar.dart';
import '../../../../ui/bordered_row.dart';
import '../../../../ui/button.dart';
import '../../../../ui/dialogs.dart';
import '../../../../ui/number_formatter.dart';
import '../../../../ui/theme.dart';

class OffRampConfirmationScreen extends StatefulWidget {
  const OffRampConfirmationScreen({
    super.key,
    required this.amount,
    required this.recipient,
    required this.provider,
    required this.token,
  });

  final String amount;
  final Ed25519HDPublicKey recipient;
  final String provider;
  final Token token;

  @override
  State<OffRampConfirmationScreen> createState() =>
      _OffRampConfirmationScreenState();
}

class _OffRampConfirmationScreenState extends State<OffRampConfirmationScreen> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.amount);
  }

  void _onSubmit() {
    final locale = DeviceLocale.localeOf(context);
    final amount = _amountController.text.toDecimalOrZero(locale);
    if (amount == Decimal.zero) {
      //TODO
      showWarningDialog(
        context,
        title: context.l10n.zeroAmountTitle,
        message: context.l10n.zeroAmountMessage(context.l10n.operationSend),
      );
    } else {
      context.router.pop(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final address = widget.recipient.toBase58();

    return CpTheme.dark(
      child: Scaffold(
        appBar: CpAppBar(),
        body: Column(
          children: [
            CpBorderedRow(
              title: Text(context.l10n.to),
              content: BorderedRowChip(
                child: Text(
                  '${substring(address, 0, 6)}'
                  '\u2026'
                  '${substring(address, address.length - 6)}',
                  style: _textStyle,
                ),
              ),
            ),
            CpBorderedRow(
              title: const Text('Provider'),
              content: BorderedRowChip(
                child: Text(widget.provider, style: _textStyle),
              ),
            ),
            CpBorderedRow(
              title: Text(context.l10n.sendAs),
              content: BorderedRowChip(
                child: Text(widget.token.symbol, style: _textStyle),
              ),
            ),
            const SizedBox(height: 38),
            AmountWithEquivalent(
              inputController: _amountController,
              token: widget.token,
              collapsed: false,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    SizedBox(height: constraints.maxHeight),
              ),
            ),
            const SizedBox(height: 16),
            FeeLabel(type: FeeType.direct(widget.recipient)),
            const SizedBox(height: 21),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: CpButton(
                text: 'Send',
                minWidth: width,
                onPressed: _onSubmit,
                size: CpButtonSize.big,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

const _textStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w500,
);