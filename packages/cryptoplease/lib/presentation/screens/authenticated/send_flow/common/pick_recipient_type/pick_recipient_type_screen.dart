import 'package:auto_route/auto_route.dart';
import 'package:cryptoplease/l10n/l10n.dart';
import 'package:cryptoplease/presentation/screens/authenticated/send_flow/common/pick_recipient_type/components/pick_recipient_type_button.dart';
import 'package:cryptoplease/presentation/screens/authenticated/send_flow/common/send_flow_router.dart';
import 'package:cryptoplease_ui/cryptoplease_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PickRecipientTypeScreen extends StatefulWidget {
  const PickRecipientTypeScreen({Key? key}) : super(key: key);

  @override
  _PickRecipientTypeScreenState createState() =>
      _PickRecipientTypeScreenState();
}

class _PickRecipientTypeScreenState extends State<PickRecipientTypeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CpAppBar(
          hasBorder: false,
          leading: BackButton(
            onPressed: () => context.router.pop(),
          ),
        ),
        body: CpContentPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  context.l10n.send,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline2?.copyWith(
                        color: CpColors.primaryTextColor,
                        fontSize: 21,
                      ),
                ),
              ),
              const SizedBox(height: 23),
              // Only send SOL tokens via link
              PickRecipientTypeButton(
                text: context.l10n.anyoneByCreatingUniqueCode,
                helpString: context.l10n.pickRecipientTypeLongText,
                onPressed: () =>
                    context.read<SendFlowRouter>().onSplitKeySelected(),
              ),
              PickRecipientTypeButton(
                text: context.l10n.solanaAddress,
                onPressed: () =>
                    context.read<SendFlowRouter>().onDirectSelected(),
              ),
              PickRecipientTypeButton(
                text: context.l10n.byScanningQRCode,
                onPressed: () =>
                    context.read<SendFlowRouter>().onQrCodeSelected(),
              ),
            ],
          ),
        ),
      );
}