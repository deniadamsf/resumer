import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumer/core/services/coin_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CoinService.instance.init();
    // Reset state for isolation
    CoinService.instance.coinsNotifier.value = 0;
    CoinService.instance.adCoinsClaimedTodayNotifier.value = 0;
  });

  group('CoinService Rewarded Ad Rewards Daily Limit', () {
    test('initial state allows 3 ad coin claims', () {
      expect(CoinService.instance.adCoinsClaimedToday, 0);
      expect(CoinService.instance.remainingAdCoinsToday, 3);
      expect(CoinService.instance.canClaimAdCoin, isTrue);
    });

    test('awards 1st, 2nd, and 3rd ad coin, but blocks 4th claim', () async {
      // 1st claim
      final claim1 = await CoinService.instance.awardAdCoinReward();
      expect(claim1, isTrue);
      expect(CoinService.instance.coinsNotifier.value, 1);
      expect(CoinService.instance.adCoinsClaimedToday, 1);
      expect(CoinService.instance.remainingAdCoinsToday, 2);
      expect(CoinService.instance.canClaimAdCoin, isTrue);

      // 2nd claim
      final claim2 = await CoinService.instance.awardAdCoinReward();
      expect(claim2, isTrue);
      expect(CoinService.instance.coinsNotifier.value, 2);
      expect(CoinService.instance.adCoinsClaimedToday, 2);
      expect(CoinService.instance.remainingAdCoinsToday, 1);
      expect(CoinService.instance.canClaimAdCoin, isTrue);

      // 3rd claim
      final claim3 = await CoinService.instance.awardAdCoinReward();
      expect(claim3, isTrue);
      expect(CoinService.instance.coinsNotifier.value, 3);
      expect(CoinService.instance.adCoinsClaimedToday, 3);
      expect(CoinService.instance.remainingAdCoinsToday, 0);
      expect(CoinService.instance.canClaimAdCoin, isFalse);

      // 4th claim (exceeds daily limit of 3)
      final claim4 = await CoinService.instance.awardAdCoinReward();
      expect(claim4, isFalse);
      expect(CoinService.instance.coinsNotifier.value, 3); // Not changed
      expect(CoinService.instance.adCoinsClaimedToday, 3);
      expect(CoinService.instance.canClaimAdCoin, isFalse);
    });
  });
}
