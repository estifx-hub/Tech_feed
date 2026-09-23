import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ads.dart';
import 'data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  runApp(MaterialApp(
    title: 'Tech Feed',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.lightBlue),
    home: Shell(prefs: prefs),
  ));
}

class Shell extends StatefulWidget {
  final SharedPreferences prefs;
  const Shell({super.key, required this.prefs});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  String query = '';
  late final Set<String> favs = (widget.prefs.getStringList('favs') ?? []).toSet();

  void toggle(Post p) {
    setState(() { if (!favs.remove(p.id)) favs.add(p.id); });
    widget.prefs.setStringList('favs', favs.toList());
  }

  void open(Post p) => Navigator.push(context, MaterialPageRoute(
      builder: (_) => Detail(post: p, isFav: favs.contains(p.id), onToggle: () => toggle(p))));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final q = query.toLowerCase();
    final pages = <Widget>[
      Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              hintText: 'Tech Feed',
              filled: true,
              fillColor: cs.primaryContainer,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Padding(padding: EdgeInsets.all(8), child: CircleAvatar(child: Icon(Icons.bolt))),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(child: PostList(
          posts: posts.where((p) => p.title.toLowerCase().contains(q)).toList(),
          favs: favs, onOpen: open, onFav: toggle)),
      ]),
      CategoryPage(favs: favs, onOpen: open, onFav: toggle),
      PostList(posts: posts.where((p) => favs.contains(p.id)).toList(),
          favs: favs, onOpen: open, onFav: toggle, empty: 'No favorites yet'),
    ];
    return Scaffold(
      body: SafeArea(child: Column(children: [Expanded(child: pages[tab]), const BannerAdWidget()])),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Recent'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Category'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favorite'),
        ],
      ),
    );
  }
}

class PostList extends StatelessWidget {
  final List<Post> posts;
  final Set<String> favs;
  final void Function(Post) onOpen, onFav;
  final String empty;
  const PostList({super.key, required this.posts, required this.favs,
    required this.onOpen, required this.onFav, this.empty = 'Nothing found'});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return Center(child: Text(empty));
    final n = posts.length;
    return ListView.builder(
      itemCount: n + (n - 1) ~/ 4, // one native ad after every 4 posts
      itemBuilder: (_, i) {
        if (i % 5 == 4) return const NativeAdCard();
        final p = posts[i - i ~/ 5];
        return InkWell(
          onTap: () => onOpen(p),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.title, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(p.excerpt, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 6),
                  Text(fmt(p.date)),
                  const Spacer(),
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (_) => onFav(p),
                    itemBuilder: (_) => [PopupMenuItem(value: 1,
                        child: Text(favs.contains(p.id) ? 'Remove favorite' : 'Add to favorites'))],
                  ),
                ]),
              ])),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(width: 100, height: 100, color: p.color,
                    child: Icon(p.icon, color: Colors.white, size: 40)),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class CategoryPage extends StatelessWidget {
  final Set<String> favs;
  final void Function(Post) onOpen, onFav;
  const CategoryPage({super.key, required this.favs, required this.onOpen, required this.onFav});

  @override
  Widget build(BuildContext context) => ListView(children: [
    const Padding(padding: EdgeInsets.all(16),
        child: Text('Categories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    for (final c in categories)
      ListTile(
        leading: const Icon(Icons.folder_outlined),
        title: Text(c),
        trailing: Text('${posts.where((p) => p.category == c).length}'),
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => CatList(cat: c, favs: favs, onOpen: onOpen, onFav: onFav))),
      ),
  ]);
}

class CatList extends StatefulWidget {
  final String cat;
  final Set<String> favs;
  final void Function(Post) onOpen, onFav;
  const CatList({super.key, required this.cat, required this.favs, required this.onOpen, required this.onFav});
  @override
  State<CatList> createState() => _CatListState();
}

class _CatListState extends State<CatList> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.cat)),
    body: PostList(
      posts: posts.where((p) => p.category == widget.cat).toList(),
      favs: widget.favs,
      onOpen: widget.onOpen,
      onFav: (p) { widget.onFav(p); setState(() {}); },
    ),
    bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
  );
}

class Detail extends StatefulWidget {
  final Post post;
  final bool isFav;
  final VoidCallback onToggle;
  const Detail({super.key, required this.post, required this.isFav, required this.onToggle});
  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late bool fav = widget.isFav;
  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
          onPressed: () { widget.onToggle(); setState(() => fav = !fav); },
        ),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(p.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('${fmt(p.date)}  ·  ${p.category}', style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(height: 16),
        Text(p.body, style: Theme.of(context).textTheme.bodyLarge),
      ]),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
    );
  }
}
