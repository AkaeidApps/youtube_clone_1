import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../widgets/video_card.dart';
import '../widgets/shimmer_skeleton.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    if (value.trim().isNotEmpty) {
      _focusNode.unfocus();
      context.read<SearchProvider>().search(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            searchProvider.clearQuery();
            Navigator.pop(context);
          },
        ),
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF272727) : const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search YouTube',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        searchProvider.clearQuery();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              setState(() {});
            },
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8, left: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF272727) : const Color(0xFFEFEFEF),
            ),
            child: IconButton(
              icon: const Icon(Icons.mic, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listening...')),
                );
              },
            ),
          ),
        ],
      ),
      body: searchProvider.hasSearched
          ? (searchProvider.isLoading
              ? ListView.builder(
                  itemCount: 4,
                  itemBuilder: (_, _) => const VideoCardSkeleton(),
                )
              : (searchProvider.searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No results found for "${searchProvider.query}"',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different keywords or remove search filters',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchProvider.searchResults.length,
                      itemBuilder: (context, index) {
                        return VideoCard(video: searchProvider.searchResults[index]);
                      },
                    )))
          : ListView(
              children: [
                if (searchProvider.searchHistory.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Searches',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: searchProvider.clearAllHistory,
                          child: const Text(
                            'Clear all',
                            style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final item in searchProvider.searchHistory)
                    ListTile(
                      leading: const Icon(Icons.history, color: Colors.grey),
                      title: Text(item, style: const TextStyle(fontSize: 14)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.north_west, size: 18, color: Colors.grey),
                            onPressed: () {
                              _searchController.text = item;
                              _searchController.selection = TextSelection.fromPosition(
                                TextPosition(offset: item.length),
                              );
                              setState(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                            onPressed: () => searchProvider.removeHistoryItem(item),
                          ),
                        ],
                      ),
                      onTap: () {
                        _searchController.text = item;
                        _onSearch(item);
                      },
                    ),
                  const Divider(height: 24),
                ],

                // Trending search topics
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Trending on YouTube',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                for (final trending in const [
                  'Flutter 3 state management',
                  'Next gen gaming consoles 2026',
                  'Lo-Fi hip hop live stream',
                  'Quantum AI processor breakdown',
                ])
                  ListTile(
                    leading: const Icon(Icons.trending_up, color: Colors.red),
                    title: Text(trending, style: const TextStyle(fontSize: 14)),
                    onTap: () {
                      _searchController.text = trending;
                      _onSearch(trending);
                    },
                  ),
              ],
            ),
    );
  }
}
