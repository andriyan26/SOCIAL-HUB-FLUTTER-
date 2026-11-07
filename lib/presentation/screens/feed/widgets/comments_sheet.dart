import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../providers/feed_provider.dart';
import '../../../providers/auth_provider.dart';

class CommentsSheet extends StatefulWidget {
  final int postId;
  final int totalComments;

  const CommentsSheet({
    super.key,
    required this.postId,
    required this.totalComments,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FeedProvider>().loadComments(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final username = auth.currentUser?.username ?? 'andrianpei';

    context.read<FeedProvider>().addComment(widget.postId, username, text);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();
    final comments = feedProvider.currentComments;

    return Container(
      height: MediaQuery.of(context).size.height * 0.68,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    '${Formatters.formatThousands(widget.totalComments)} komentar',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),

          // Comments List
          Expanded(
            child: feedProvider.isLoadingComments
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : comments.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada komentar. Jadilah yang pertama!',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final c = comments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 17,
                                  backgroundColor: AppColors.avatarPurple,
                                  backgroundImage: c.userAvatar.isNotEmpty
                                      ? AssetImage(c.userAvatar)
                                      : null,
                                  child: c.userAvatar.isEmpty
                                      ? Text(
                                          c.username.isNotEmpty ? c.username[0].toUpperCase() : '?',
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.username,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        c.text,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text(
                                            'Baru saja',
                                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                          const SizedBox(width: 14),
                                          GestureDetector(
                                            onTap: () {},
                                            child: const Text(
                                              'Balas',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.favorite_border, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.likesCount.toString(),
                                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Bottom Input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF141418),
                border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.avatarPurple,
                    child: Text('a', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24242A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Tambahkan komentar...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 22),
                    onPressed: _sendComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
