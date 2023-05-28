import 'package:dfunc/dfunc.dart';
import 'package:espressocash_api/espressocash_api.dart';
import 'package:espressocash_app/core/accounts/bl/ec_wallet.dart';
import 'package:espressocash_app/core/amount.dart';
import 'package:espressocash_app/core/currency.dart';
import 'package:espressocash_app/core/link_shortener.dart';
import 'package:espressocash_app/core/tokens/token.dart';
import 'package:espressocash_app/core/transactions/tx_sender.dart';
import 'package:espressocash_app/features/outgoing_split_key_payments/models/outgoing_split_key_payment.dart';
import 'package:espressocash_app/features/outgoing_split_key_payments/src/bl/cancel_tx_created_watcher.dart';
import 'package:espressocash_app/features/outgoing_split_key_payments/src/bl/cancel_tx_sent_watcher.dart';
import 'package:espressocash_app/features/outgoing_split_key_payments/src/bl/oskp_service.dart';
import 'package:espressocash_app/features/outgoing_split_key_payments/src/bl/repository.dart';
import 'package:espressocash_app/features/outgoing_split_key_payments/src/bl/tx_confirmed_watcher.dart';
import 'package:espressocash_app/features/outgoing_split_key_payments/src/bl/tx_created_watcher.dart';
import 'package:espressocash_app/features/outgoing_split_key_payments/src/bl/tx_ready_watcher.dart';
import 'package:espressocash_app/features/outgoing_split_key_payments/src/bl/tx_sent_watcher.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

import 'service_test.mocks.dart';

final sender = MockTxSender();
final client = MockCryptopleaseClient();
final solanaClient = MockSolanaClient();
final linkShortener = MockLinkShortener();

@GenerateMocks([
  TxSender,
  CryptopleaseClient,
  SolanaClient,
  LinkShortener,
])
Future<void> main() async {
  late TxCreatedWatcher txCreatedWatcher;
  late TxConfirmedWatcher txConfirmedWatcher;
  late TxReadyWatcher txReadyWatcher;
  late TxSentWatcher txSentWatcher;

  late CancelTxCreatedWatcher cancelTxCreatedWatcher;
  late CancelTxSentWatcher cancelTxSentWatcher;

  final account = LocalWallet(await Ed25519HDKeyPair.random());
  final repository = MemoryRepository();

  setUp(() {
    reset(sender);
    reset(client);

    txCreatedWatcher = TxCreatedWatcher(repository, sender)
      ..call(onBalanceAffected: ignore);
    txConfirmedWatcher = TxConfirmedWatcher(repository, linkShortener)
      ..call(onBalanceAffected: ignore);
    txReadyWatcher = TxReadyWatcher(
      solanaClient,
      repository,
      userPublicKey: account.publicKey,
    )..init(onBalanceAffected: ignore);
    txSentWatcher = TxSentWatcher(repository, sender)
      ..call(onBalanceAffected: ignore);

    cancelTxCreatedWatcher = CancelTxCreatedWatcher(repository, sender)
      ..call(onBalanceAffected: ignore);
    cancelTxSentWatcher = CancelTxSentWatcher(repository, sender)
      ..call(onBalanceAffected: ignore);

    when(sender.send(any, minContextSlot: anyNamed('minContextSlot')))
        .thenAnswer((_) async => const TxSendResult.sent());
    when(sender.wait(any, minContextSlot: anyNamed('minContextSlot')))
        .thenAnswer((_) async => const TxWaitResult.success());

    when(linkShortener.buildShortUrl(any))
        .thenAnswer((_) async => Uri.parse(''));
    when(linkShortener.buildFullUrl(any)).thenAnswer((_) => Uri.parse(''));
  });

  tearDown(
    () async {
      txCreatedWatcher.dispose();
      txConfirmedWatcher.dispose();
      txReadyWatcher.dispose();
      txSentWatcher.dispose();

      cancelTxCreatedWatcher.dispose();
      cancelTxSentWatcher.dispose();

      await repository.clear();
    },
  );

  final stubTx = await Message.only(
    MemoInstruction(signers: const [], memo: 'test'),
  )
      .compile(
        recentBlockhash: 'EkSnNWid2cvwEVnVx9aBqawnmiCNiDgp3gUdkDPTKN1N',
        feePayer: account.publicKey,
      )
      .let(
        (it) async => SignedTx(
          compiledMessage: it,
          signatures: await account.sign(
            [it.toByteArray().toList().let(Uint8List.fromList)],
          ),
        ),
      )
      .then((it) => it.encode());

  final testCreateApiResponse = CreatePaymentResponseDto(
    transaction: stubTx,
    slot: BigInt.zero,
  );

  final testCancelApiResponse = CancelPaymentResponseDto(
    transaction: stubTx,
    slot: BigInt.zero,
  );

  const testAmount = CryptoAmount(
    value: 100000000,
    cryptoCurrency: CryptoCurrency(token: Token.usdc),
  );

  OSKPService createService() => OSKPService(client, repository);

  Future<String> createOSKP(OSKPService service) async {
    final payment = await service.create(
      account: account,
      amount: testAmount,
    );

    return payment.id;
  }

  Future<String> cancelOSKP(
    OSKPService service,
    OutgoingSplitKeyPayment oskp,
  ) async {
    final payment = await service.cancel(
      oskp,
      account: account,
    );

    return payment.id;
  }

  test('Happy path', () async {
    when(client.createPaymentEc(any))
        .thenAnswer((_) async => testCreateApiResponse);

    final paymentId = await createService().let(createOSKP);
    final payment = repository.watch(paymentId);

    await expectLater(
      payment,
      emitsInOrder(
        [
          isA<OutgoingSplitKeyPayment>()
              .having((it) => it.status, 'status', isA<OSKPStatusTxCreated>()),
          isA<OutgoingSplitKeyPayment>()
              .having((it) => it.status, 'status', isA<OSKPStatusTxSent>()),
          isA<OutgoingSplitKeyPayment>().having(
            (it) => it.status,
            'status',
            isA<OSKPStatusTxConfirmed>(),
          ),
          isA<OutgoingSplitKeyPayment>()
              .having((it) => it.status, 'status', isA<OSKPStatusLinksReady>())
        ],
      ),
    );

    verify(sender.send(any, minContextSlot: anyNamed('minContextSlot')))
        .called(1);
    verify(sender.wait(any, minContextSlot: anyNamed('minContextSlot')))
        .called(1);
  });

  test('Happy path, cancel payment', () async {
    when(client.createPaymentEc(any))
        .thenAnswer((_) async => testCreateApiResponse);

    when(client.cancelPaymentEc(any))
        .thenAnswer((_) async => testCancelApiResponse);

    final service = createService();

    final createPaymentId = await service.let(createOSKP);
    final payment = repository.watch(createPaymentId);

    await expectLater(
      payment,
      emitsInOrder(
        [
          isA<OutgoingSplitKeyPayment>()
              .having((it) => it.status, 'status', isA<OSKPStatusTxCreated>()),
          isA<OutgoingSplitKeyPayment>()
              .having((it) => it.status, 'status', isA<OSKPStatusTxSent>()),
          isA<OutgoingSplitKeyPayment>().having(
            (it) => it.status,
            'status',
            isA<OSKPStatusTxConfirmed>(),
          ),
          isA<OutgoingSplitKeyPayment>()
              .having((it) => it.status, 'status', isA<OSKPStatusLinksReady>())
        ],
      ),
    );

    final oskp = await repository.load(createPaymentId);

    // ignore: avoid-non-null-assertion, should fail if not existent
    await cancelOSKP(service, oskp!);

    await expectLater(
      payment,
      emitsInOrder(
        [
          isA<OutgoingSplitKeyPayment>().having(
            (it) => it.status,
            'status',
            isA<OSKPStatusCancelTxCreated>(),
          ),
          isA<OutgoingSplitKeyPayment>().having(
            (it) => it.status,
            'status',
            isA<OSKPStatusCancelTxSent>(),
          ),
          isA<OutgoingSplitKeyPayment>()
              .having((it) => it.status, 'status', isA<OSKPStatusCanceled>()),
        ],
      ),
    );
  });
}

typedef PaymentMap = IMap<String, OutgoingSplitKeyPayment>;

class MemoryRepository implements OSKPRepository {
  final _data = BehaviorSubject<PaymentMap>.seeded(PaymentMap());

  @override
  Future<OutgoingSplitKeyPayment?> load(String id) async => _data.value[id];

  @override
  Future<void> save(OutgoingSplitKeyPayment payment) async {
    _data.add(_data.value.add(payment.id, payment));
  }

  @override
  Stream<OutgoingSplitKeyPayment> watch(String id) =>
      // ignore: avoid-non-null-assertion, should fail if not existent
      _data.stream.map((it) => it[id]!);

  @override
  Stream<IList<OutgoingSplitKeyPayment>> watchReady() => _watchWithStatuses([
        OSKPStatusDto.linksReady,
        OSKPStatusDto.cancelTxCreated,
        OSKPStatusDto.cancelTxSendFailure,
        OSKPStatusDto.cancelTxSent,
        OSKPStatusDto.cancelTxWaitFailure,
        OSKPStatusDto.cancelTxFailure,
      ]);

  @override
  Stream<IList<OutgoingSplitKeyPayment>> watchTxCreated() =>
      _watchWithStatuses([
        OSKPStatusDto.txCreated,
        OSKPStatusDto.txSendFailure,
      ]);

  @override
  Stream<IList<OutgoingSplitKeyPayment>> watchTxConfirmed() =>
      _watchWithStatuses([
        OSKPStatusDto.txConfirmed,
        OSKPStatusDto.txLinksFailure,
      ]);

  @override
  Stream<IList<OutgoingSplitKeyPayment>> watchCancelTxCreated() =>
      _watchWithStatuses([
        OSKPStatusDto.cancelTxCreated,
        OSKPStatusDto.cancelTxSendFailure,
      ]);

  @override
  Stream<IList<OutgoingSplitKeyPayment>> watchTxSent() => _watchWithStatuses([
        OSKPStatusDto.txSent,
        OSKPStatusDto.txWaitFailure,
      ]);

  @override
  Stream<IList<OutgoingSplitKeyPayment>> watchCancelTxSent() =>
      _watchWithStatuses([
        OSKPStatusDto.cancelTxSent,
        OSKPStatusDto.cancelTxWaitFailure,
      ]);

  @override
  Future<void> clear() async {
    _data.add(_data.value.clear());
  }

  Stream<IList<OutgoingSplitKeyPayment>> _watchWithStatuses(
    Iterable<OSKPStatusDto> statuses,
  ) =>
      _data.stream.map(
        (it) => it.values
            .where((it) => statuses.contains(it.status.toDto()))
            .toIList(),
      );
}

extension on OSKPStatus {
  OSKPStatusDto toDto() => this.map(
        txCreated: always(OSKPStatusDto.txCreated),
        txSent: always(OSKPStatusDto.txSent),
        txConfirmed: always(OSKPStatusDto.txConfirmed),
        linksReady: always(OSKPStatusDto.linksReady),
        withdrawn: always(OSKPStatusDto.withdrawn),
        txFailure: always(OSKPStatusDto.txFailure),
        canceled: always(OSKPStatusDto.canceled),
        cancelTxCreated: always(OSKPStatusDto.cancelTxCreated),
        cancelTxFailure: always(OSKPStatusDto.cancelTxFailure),
        cancelTxSent: always(OSKPStatusDto.cancelTxSent),
      );
}
