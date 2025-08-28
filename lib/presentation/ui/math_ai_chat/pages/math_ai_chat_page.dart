  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:flutter_ai_math_2/app.dart';
  import 'package:flutter_svg/svg.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:io';

  import '../../../../core/routes/app_routes.dart';
  import '../../history/page/history_tabs_page.dart';
  import '../bloc/math_ai_chat_bloc.dart';
  import '../bloc/math_ai_chat_event.dart';
  import '../bloc/math_ai_chat_state.dart';

  class MathAiChatPage extends StatefulWidget {
    final int? mathAiId;

    const MathAiChatPage({super.key, this.mathAiId});

    @override
    State<MathAiChatPage> createState() => _MathAiChatPageState();
  }

  class _MathAiChatPageState extends State<MathAiChatPage>
      with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
    final TextEditingController _messageController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    File? _selectedImage;
    final ImagePicker _picker = ImagePicker();
    int? _currentMathAiId;
    bool _isCreatingSession = false;
    final FocusNode _focusNode = FocusNode();
    final MathAiUseCase mathAiUseCase = sl<MathAiUseCase>();
    final MathAiChatUseCase mathAiChatUseCase = sl<MathAiChatUseCase>();


    bool checkReset = false;
    bool checkBack = false;

    @override
    bool get wantKeepAlive => true;
    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addObserver(this);
      _messageController.addListener(() {
        setState(() {});
      });
      _initializeSession();
    }

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      // Clear focus when widget dependencies change (like when switching tabs)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !ModalRoute.of(context)!.isCurrent) {
          _clearFocus();
        }
      });
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
      super.didChangeAppLifecycleState(state);
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        _clearFocus();
        _onPageVisibilityChanged(false);
      } else if (state == AppLifecycleState.resumed) {
        _onPageVisibilityChanged(true);
      }
    }

    void _clearFocus() {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
      FocusScope.of(context).unfocus();
    }

    void _onPageVisibilityChanged(bool isVisible) {
      if (!isVisible) {
        _clearFocus();
      }
    }

    Future<void> _initializeSession() async {
      if (widget.mathAiId != null) {
        _currentMathAiId = widget.mathAiId;
        _startWatchingMessages();
      } else {
        await _createNewSession();
      }
    }

    Future<void> _createNewSession() async {
      setState(() {
        _isCreatingSession = true;
      });

      try {
        final newMathAi = MathAi(isContent: 0, createdAt: DateTime.now().toIso8601String());

        final mathAiUseCase = sl<MathAiUseCase>();
        final sessionId = await mathAiUseCase.insert(newMathAi);

        _currentMathAiId = sessionId;
        _startWatchingMessages();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create session: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isCreatingSession = false;
          });
        }
      }
    }

    void _startWatchingMessages() {
      if (_currentMathAiId != null) {
        context.read<MathAiChatBloc>().add(MathAiChatWatchByMathAiIdEvent(_currentMathAiId!));
      }
      print("lmao   asdasdasdsadasd");
    }

    @override
    void dispose() {
      WidgetsBinding.instance.removeObserver(this);
      _clearFocus();
      _messageController.dispose();
      _scrollController.dispose();
      _focusNode.dispose();
      super.dispose();
    }

    void _scrollToBottom() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    Future<void> _pickImage() async {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }

    Future<void> _takePhoto() async {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    }


    void _sendMessage() {
      _clearFocus();
      final message = _messageController.text.trim();
      if ((message.isNotEmpty || _selectedImage != null) && _currentMathAiId != null) {
        context.read<MathAiChatBloc>().add(
          MathAiChatSendMessageEvent(
            mathAiId: _currentMathAiId!,
            message: message,
            image: _selectedImage,
          ),
        );

        _messageController.clear();
        setState(() {
          _selectedImage = null;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    }

    @override
    Widget build(BuildContext context) {
      super.build(context); // Required for AutomaticKeepAliveClientMixin

      return Scaffold(
        backgroundColor: const Color(0xFF181D27),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80), // chiều cao 100
          child: AppBar(
            backgroundColor: const Color(0xFF0A0D12),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Math AI',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            leading: IconButton(
              icon: Image.asset('assets/images/img_ai.webp', width: 40, height: 40),
              onPressed: () {
                // Navigator.pushNamed(context, AppRoutes.history);
              },
            ),
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ic_history_ai_chat.svg',
                  width: 40,
                  height: 40,
                ),
                onPressed: () {
                  _clearFocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryTabsPage(
                        initialTabIsPhoto: false,
                      ),
                    ),
                  ).then((_) async {
                    // Khi quay lại

                      // load từ DB
                      final sessions = await mathAiUseCase.selectAll();
                     // final chats = await mathAiChatUseCase.selectAll();
                      debugPrint("🔎 [HistoryCheck] sessions count = ${sessions.length}");
                      //debugPrint("🔎 [HistoryCheck] chats count = ${chats.length}");
                      if (sessions.isEmpty) {
                        // session bị xoá trong history → tạo mới
                         await _createNewSession();
                      }

                  });
                },


              ),

              IconButton(
                icon: SvgPicture.asset('assets/icons/ic_reset_ai_chat.svg', width: 40, height: 40),
                onPressed: () {
                  _clearFocus();
                  _createNewSession();
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: const Color(0xFF414651), height: 1),
            ),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // Tap ra ngoài sẽ ẩn bàn phím và unfocus ô nhập
            _clearFocus();
          },
          child: Column(
            children: [
              Expanded(
                child: BlocConsumer<MathAiChatBloc, MathAiChatState>(
                  listener: (context, state) {
                    if (state is MathAiChatWatchByMathAiIdState ||
                        state is MathAiChatMessageSentState) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                    }
                    if (state is MathAiChatErrorState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (_isCreatingSession) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.blue),
                            SizedBox(height: 16),
                            Text(
                              'Creating new chat session...',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    if (_currentMathAiId == null) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (state is MathAiChatLoadingState) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    List<MathAiChat> messages = [];
                    bool isLoading = false;

                    if (state is MathAiChatWatchByMathAiIdState) {
                      messages = state.messages;
                    } else if (state is MathAiChatSendingMessageState) {
                      messages = state.messages;
                      isLoading = true;
                    } else if (state is MathAiChatMessageSentState) {
                      messages = state.messages;
                    }

                    if (messages.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Text(
                              "I am your Ai Math Robot. You can give me difficult math problems to solve !!",
                              style: TextStyle(color: Color(0xFFFDFDFD), fontSize: 14),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: const EdgeInsets.only(left: 16, bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Hi I'm AI Math !! How can I help you ?",
                                    style: TextStyle(color: Colors.black87, fontSize: 15),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE53935),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'You get 3 Free AI Math chats',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _takePhoto,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24.0),
                                      ),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/ic_scan_math.svg',
                                      width: 130,
                                      height: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (isLoading && index == messages.length) {
                          return _buildTypingIndicator();
                        }

                        final message = messages[index];
                        return _buildMessageBubble(message);
                      },
                    );
                  },
                ),
              ),

              if (_selectedImage != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF252B37),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                focusNode: _focusNode,
                                autofocus: false,
                                enableInteractiveSelection: true,
                                controller: _messageController,
                                style: const TextStyle(color: Colors.black),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: const InputDecoration(
                                  hintText: 'Write your message...',
                                  hintStyle: TextStyle(color: Color(0xFF717680)),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                                onTap: () async {
                                  final sessions = await mathAiUseCase.selectAll();
                                  if (sessions.isEmpty) {
                                    _createNewSession();
                                  }
                                  // Chỉ cho focus khi user tap vào
                                  if (!_focusNode.hasFocus) {
                                    _focusNode.requestFocus();
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                // load từ DB
                               /* final sessions = await mathAiUseCase.selectAll();
                                // final chats = await mathAiChatUseCase.selectAll();
                                debugPrint("🔎 [HistoryCheck] sessions count = ${sessions.length}");
                                //debugPrint("🔎 [HistoryCheck] chats count = ${chats.length}");
                                if (sessions.isEmpty) {
                                  // session bị xoá trong history → tạo mới
                                   _createNewSession();
                                }else {*/
                                  // session hàng ngày → tạo session mới
                                  _sendMessage();
                                //}
                              },
                              icon: SvgPicture.asset(
                                'assets/icons/ic_send_mess.svg',
                                width: 32,
                                height: 32,
                              ),
                              padding: const EdgeInsets.all(8),
                              style: IconButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: Colors.black26, // nếu muốn nền mờ tròn
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_selectedImage != null)
                      Container(
                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildMessageBubble(MathAiChat message) {
      final isUser = message.role == 'user';

      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF3369FF) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(isUser ? 0 : 16),
              bottomLeft: Radius.circular(isUser ? 16 : 0), // bot: dưới trái vuông
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.content != null && message.content!.isNotEmpty)
                Text(
                  message.content!,
                  style: TextStyle(
                    color: isUser ? const Color(0xFFF5F5F5) : Colors.black,
                    fontSize: 14,
                  ),
                ),

              if (message.imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(message.imagePath!), width: 200, fit: BoxFit.cover),
                  ),
                ),

              const SizedBox(height: 0),
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),

              if (!isUser) ...[
                const SizedBox(height: 4),
                // Hàng 1: 2 nút
                const Divider(
                  color: Colors.grey, // màu line
                  thickness: 0.5, // độ dày line
                  height: 16, // khoảng cách trên dưới
                ),
                Row(
                  children: [
                    _buildActionButton("assets/icons/ic_copy.svg"),
                    const SizedBox(width: 8),
                    _buildActionButton("assets/icons/ic_repeat.svg"),
                  ],
                ),
                const SizedBox(height: 8),

                // Hàng 2: 1 nút
                Row(children: [_buildActionButton("assets/icons/ic_scan_math.svg")]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        "assets/images/img_premium_chat.webp",
                        width: 335,
                        height: 80,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      );
    }

    Widget _buildActionButton(String assetPath, {double size = 32}) {
      return GestureDetector(
        onTap: () {
          final state = context.read<MathAiChatBloc>().state;
          MathAiChat? lastUserMessage;
          MathAiChat? lastMathAiMessage;

          // Lấy message cuối cùng của user
          if (state is MathAiChatWatchByMathAiIdState && state.messages.isNotEmpty) {
            lastUserMessage = state.messages.reversed.firstWhere(
              (msg) => msg.role == 'user',
              orElse: () => state.messages.last,
            );
          } else if (state is MathAiChatMessageSentState && state.messages.isNotEmpty) {
            lastUserMessage = state.messages.reversed.firstWhere(
              (msg) => msg.role == 'user',
              orElse: () => state.messages.last,
            );
          } else if (state is MathAiChatSendingMessageState && state.messages.isNotEmpty) {
            lastUserMessage = state.messages.reversed.firstWhere(
              (msg) => msg.role == 'user',
              orElse: () => state.messages.last,
            );
          }

          // lấy message cuối cùng của math ai
          if (state is MathAiChatWatchByMathAiIdState && state.messages.isNotEmpty) {
            lastMathAiMessage = state.messages.reversed.firstWhere(
                  (msg) => msg.role == 'math_ai',
              orElse: () => state.messages.last,
            );
          } else if (state is MathAiChatMessageSentState && state.messages.isNotEmpty) {
            lastMathAiMessage = state.messages.reversed.firstWhere(
                  (msg) => msg.role == 'math_ai',
              orElse: () => state.messages.last,
            );
          } else if (state is MathAiChatSendingMessageState && state.messages.isNotEmpty) {
            lastMathAiMessage = state.messages.reversed.firstWhere(
                  (msg) => msg.role == 'math_ai',
              orElse: () => state.messages.last,
            );
          }
          if (lastUserMessage == null) return;
          if (lastMathAiMessage == null ) return;

          // Copy text
          if (assetPath == "assets/icons/ic_copy.svg") {
            if (lastMathAiMessage.content != null && lastMathAiMessage.content!.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: lastMathAiMessage.content!));

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) {
                  return Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "Copied to clipboard",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              // Auto close sau 1 giây
              Future.delayed(const Duration(seconds: 1), () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              });
            }
          }

          // Repeat message (text + image)
          else if (assetPath == "assets/icons/ic_repeat.svg") {
            if (_currentMathAiId != null) {
              context.read<MathAiChatBloc>().add(
                MathAiChatSendMessageEvent(
                  mathAiId: _currentMathAiId!,
                  message: lastUserMessage.content ?? '',
                  image: lastUserMessage.imagePath != null ? File(lastUserMessage.imagePath!) : null,
                ),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
            }
          }
          // Scan math (camera)
          else if (assetPath == "assets/icons/ic_scan_math.svg") {
            _takePhoto();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(assetPath, width: size, height: size),
        ),
      );
    }

    Widget _buildTypingIndicator() {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Thinking...', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    String _formatTime(DateTime dateTime) {
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    }
  }
