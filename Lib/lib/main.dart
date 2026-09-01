import 'package:flutter/material.dart';

void main() => runApp(const TradeApp());

class Trade {
  final String symbol, side;
  final double risk, reward;
  final bool won;
  Trade(this.symbol, this.side, this.risk, this.reward, this.won);
}

class TradeApp extends StatefulWidget {
  const TradeApp({super.key});
  @override State<TradeApp> createState() => _TradeAppState();
}

class _TradeAppState extends State<TradeApp> {
  double balance = 1000;
  double risk = 100;
  double leverage = 10;
  String symbol = 'BTCUSDT';
  String side = 'LONG';
  final List<Trade> history = [];

  double get reward => risk * 1.6;
  int get wins => history.where((x) => x.won).length;
  double get winRate => history.isEmpty ? 0 : wins / history.length * 100;

  void openDemoTrade() {
    final won = DateTime.now().millisecondsSinceEpoch % 2 == 0;
    setState(() {
      balance += won ? reward : -risk;
      history.insert(0, Trade(symbol, side, risk, reward, won));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(won ? 'Demo işlem kazandı: +\$${reward.toStringAsFixed(2)}' : 'Demo işlem kaybetti: -\$${risk.toStringAsFixed(2)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C5CFF), brightness: Brightness.dark),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('1.6X TRADE', style: TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: const Color(0xFF090D16),
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined))],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _balanceCard(),
              const SizedBox(height: 18),
              const Text('İŞLEM AÇ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 10),
              _tradeCard(),
              const SizedBox(height: 20),
              Row(children: [
                _stat('İŞLEMLER', '${history.length}'),
                const SizedBox(width: 10),
                _stat('KAZANMA', '${winRate.toStringAsFixed(1)}%'),
                const SizedBox(width: 10),
                _stat('R/R', '1 : 1.6'),
              ]),
              const SizedBox(height: 22),
              const Text('SON İŞLEMLER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 10),
              if (history.isEmpty)
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('Henüz demo işlem yok.')),
                )
              else
                ...history.take(8).map((t) => _historyTile(t)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _balanceCard() => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF191B35), Color(0xFF101827)]),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('DEMO BAKİYE', style: TextStyle(color: Colors.white54, fontSize: 12)),
      const SizedBox(height: 5),
      Text('\$${balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      Row(children: [
        _mini('KAZANÇ HEDEFİ', '+\$${reward.toStringAsFixed(0)}'),
        const SizedBox(width: 22),
        _mini('KAYIP LİMİTİ', '-\$${risk.toStringAsFixed(0)}'),
      ])
    ]),
  );

  Widget _mini(String a, String b) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(a, style: const TextStyle(color: Colors.white38, fontSize: 10)),
    const SizedBox(height: 3),
    Text(b, style: const TextStyle(fontWeight: FontWeight.bold)),
  ]);

  Widget _tradeCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(18)),
    child: Column(children: [
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(
          value: symbol, dropdownColor: const Color(0xFF111827),
          decoration: const InputDecoration(labelText: 'PARİTE', border: OutlineInputBorder()),
          items: ['BTCUSDT','ETHUSDT','SOLUSDT'].map((x) => DropdownMenuItem(value:x, child:Text(x))).toList(),
          onChanged: (v) => setState(() => symbol = v!),
        )),
        const SizedBox(width: 10),
        Expanded(child: DropdownButtonFormField<double>(
          value: leverage, dropdownColor: const Color(0xFF111827),
          decoration: const InputDecoration(labelText: 'KALDIRAÇ', border: OutlineInputBorder()),
          items: [1,5,10,20,50].map((x) => DropdownMenuItem(value:x, child:Text('${x}x'))).toList(),
          onChanged: (v) => setState(() => leverage = v!),
        )),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _sideButton('LONG', const Color(0xFF159A72))),
        const SizedBox(width: 10),
        Expanded(child: _sideButton('SHORT', const Color(0xFFD24A63))),
      ]),
      const SizedBox(height: 12),
      Slider(
        value: risk, min: 10, max: 500, divisions: 49,
        label: '\$${risk.toStringAsFixed(0)} risk',
        onChanged: (v) => setState(() => risk = v),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Risk'),
        Text('\$${risk.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Take Profit', style: TextStyle(color: Colors.white70)),
        Text('+\$${reward.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 14),
      SizedBox(width: double.infinity, height: 52, child: FilledButton(
        onPressed: balance >= risk ? openDemoTrade : null,
        child: const Text('DEMO İŞLEM AÇ', style: TextStyle(fontWeight: FontWeight.w800)),
      )),
    ]),
  );

  Widget _sideButton(String label, Color c) => OutlinedButton(
    onPressed: () => setState(() => side = label),
    style: OutlinedButton.styleFrom(
      backgroundColor: side == label ? c.withOpacity(.22) : Colors.transparent,
      side: BorderSide(color: side == label ? c : Colors.white12),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    child: Text(label, style: TextStyle(color: side == label ? c : Colors.white70, fontWeight: FontWeight.bold)),
  );

  Widget _stat(String a, String b) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(a, style: const TextStyle(color: Colors.white38, fontSize: 9)),
      const SizedBox(height: 5),
      Text(b, style: const TextStyle(fontWeight: FontWeight.w800)),
    ]),
  ));

  Widget _historyTile(Trade t) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      CircleAvatar(radius: 18, child: Icon(t.won ? Icons.arrow_upward : Icons.arrow_downward, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${t.symbol} • ${t.side}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(t.won ? 'Take Profit' : 'Stop Loss', style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ])),
      Text('${t.won ? '+' : '-'}\$${(t.won ? t.reward : t.risk).toStringAsFixed(0)}',
        style: TextStyle(fontWeight: FontWeight.w800, color: t.won ? const Color(0xFF31D39A) : const Color(0xFFFF6680))),
    ]),
  );
}
