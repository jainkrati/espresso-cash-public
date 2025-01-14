import 'package:auto_route/auto_route.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../../l10n/l10n.dart';
import '../../../routes.gr.dart';
import '../../../ui/app_bar.dart';
import '../../../ui/back_button.dart';
import '../../../ui/button.dart';
import '../../../ui/colors.dart';
import '../../../ui/theme.dart';
import '../models/ramp_partner.dart';

enum RampType { onRamp, offRamp }

@RoutePage()
class RampPartnerSelectScreen extends StatelessWidget {
  const RampPartnerSelectScreen({
    super.key,
    required this.topPartner,
    required this.otherPartners,
    required this.type,
    required this.onPartnerSelected,
  });

  static const route = RampPartnerSelectRoute.new;

  final RampPartner topPartner;
  final IList<RampPartner> otherPartners;
  final RampType type;
  final ValueSetter<RampPartner> onPartnerSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CpAppBar(
          leading: const CpTheme.dark(child: CpBackButton()),
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: CpColors.dashboardBackgroundColor,
        body: Column(
          children: [
            _TopPartner(
              partner: topPartner,
              type: type,
              onPartnerSelected: onPartnerSelected,
            ),
            const SizedBox(height: 27),
            Text(
              context.l10n.rampOtherPartnersTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            for (final partner in otherPartners)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 7, horizontal: 18),
                child: ListTile(
                  tileColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                  title: Text(
                    partner.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2B2C),
                    ),
                  ),
                  subtitle: Text(
                    context.l10n
                        .rampMinimumTransferAmount(partner.minimumAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: CpColors.menuPrimaryTextColor,
                    ),
                  ),
                  trailing: const _Arrow(),
                  onTap: () => onPartnerSelected(partner),
                ),
              ),
          ],
        ),
      );
}

class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) => RotatedBox(
        quarterTurns: 2,
        child: Assets.icons.arrow.svg(
          height: 14,
          color: const Color(0xFF2D2B2C),
        ),
      );
}

class _TopPartner extends StatelessWidget {
  const _TopPartner({
    required this.partner,
    required this.type,
    required this.onPartnerSelected,
  });

  final RampPartner partner;
  final RampType type;
  final ValueSetter<RampPartner> onPartnerSelected;

  AssetGenImage get image => switch (type) {
        RampType.onRamp => Assets.images.onRampTopPartner,
        RampType.offRamp => Assets.images.offRampTopPartner,
      };

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 428 / 453,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Image.asset(
              image.path,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            image.image(
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: Text(
                      switch (type) {
                        RampType.onRamp => context.l10n.onRampTopPartnerTitle,
                        RampType.offRamp => context.l10n.offRampTopPartnerTitle,
                      },
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CpButton(
                    text: partner.title,
                    width: double.infinity,
                    size: CpButtonSize.big,
                    trailing: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: _Arrow(),
                    ),
                    onPressed: () => onPartnerSelected(partner),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n
                        .rampMinimumTransferAmount(partner.minimumAmount),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      );
}
