import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// GOOGLE TEST IDs. Replace with your real AdMob unit IDs only when publishing.
class AdIds {
  static String get banner => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';
  static String get native => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});
  @override
  State<BannerAdWidget> createState() => _BannerState();
}

class _BannerState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _ok = false;

  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) { if (mounted) setState(() => _ok = true); },
        onAdFailedToLoad: (ad, e) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() { _ad?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_ok) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      height: 50,
      child: SizedBox(width: 320, child: AdWidget(ad: _ad!)),
    );
  }
}

class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});
  @override
  State<NativeAdCard> createState() => _NativeState();
}

class _NativeState extends State<NativeAdCard> with AutomaticKeepAliveClientMixin {
  NativeAd? _ad;
  bool _ok = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ad = NativeAd(
      adUnitId: AdIds.native,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) { if (mounted) setState(() => _ok = true); },
        onAdFailedToLoad: (ad, e) { ad.dispose(); _ad = null; },
      ),
      nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.small),
    )..load();
  }

  @override
  void dispose() { _ad?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_ok || _ad == null) return const SizedBox.shrink();
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Advertisement', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320, minHeight: 90, maxHeight: 120),
          child: AdWidget(ad: _ad!),
        ),
      ]),
    );
  }
}
