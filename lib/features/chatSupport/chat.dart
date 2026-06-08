import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  // ✅ receive path
  const ChatScreen({super.key, this.profileImagePath});
  final String? profileImagePath;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final List<ChatMessage> messages = [
    ChatMessage(
      text:
          'Please describe your issue in brief by Selecting any one of the options below.',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      showOptions: true,
    ),
  ];

  // Quick reply options shown in the first bot message
  final List<String> _quickOptions = [
    'Items are bad quality',
    'Packaging has been temporary',
    'Items are contaminated',
    'Items are expired',
  ];

  void _sendMessage([String? quickText]) {
    final text = quickText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });

    _messageController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          messages.add(
            ChatMessage(
              text:
                  'Thank you for your message. Our team will get back to you shortly.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          messages.add(
            ChatMessage(
              text: '',
              imagePath: image.path,
              isUser: true,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              messages.add(
                ChatMessage(
                  text:
                      'Thank you for providing the image. Our team will review it.',
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              );
            });
            _scrollToBottom();
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(context),
        ),
        title: const Text(
          'Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: messages.length + 1, // +1 for date header
              itemBuilder: (context, index) {
                // First item is always the date separator
                if (index == 0) {
                  return _buildDateSeparator('Today');
                }
                final message = messages[index - 1];
                return _buildMessageItem(message);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ─── Date Separator ───────────────────────────────────────────
  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        ],
      ),
    );
  }

  // ─── Message Row (avatar + bubble) ────────────────────────────
  Widget _buildMessageItem(ChatMessage message) {
    if (message.isUser) {
      return _buildUserMessage(message);
    } else {
      return _buildBotMessage(message);
    }
  }

  Widget _buildUserMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.imagePath != null)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: message.text.isNotEmpty ? 4 : 0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(message.imagePath!),
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (message.text.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.70,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C9E19),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // User avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage:
                (widget.profileImagePath != null &&
                    widget.profileImagePath!.isNotEmpty)
                ? FileImage(File(widget.profileImagePath!)) as ImageProvider
                : const AssetImage('assets/images/profile image.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildBotMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Support green icon avatar
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 252, 253, 251),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE9DD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          // Quick reply option buttons
          if (message.showOptions == true) ...[
            const SizedBox(height: 16),
            ..._quickOptions.map((option) => _buildOptionButton(option)),
          ],
        ],
      ),
    );
  }

  // ─── Quick Reply Option Button ─────────────────────────────────
  Widget _buildOptionButton(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ─── Input Bar ────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // User avatar on the left
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE0E0E0),
                backgroundImage:
                    (widget.profileImagePath != null &&
                        widget.profileImagePath!.isNotEmpty)
                    ? FileImage(File(widget.profileImagePath!)) as ImageProvider
                    : const AssetImage('assets/images/profile image.png'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C9E19),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(),
              decoration: const InputDecoration(
                hintText: 'Enter your message here!',
                hintStyle: TextStyle(
                  color: Color(0xFFB0B5CD),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),
          // Attachment icon
          IconButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(
              Icons.attach_file,
              color: Color(0xFFB0B5CD),
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          // Camera icon
          IconButton(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(
              Icons.camera_alt,
              color: Color(0xFFB0B5CD),
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF2C9E19),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.showOptions,
    this.imagePath,
  });
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool? showOptions;
  final String? imagePath;
}
// import 'package:flutter/material.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final List<ChatMessage> messages = [
//     ChatMessage(
//       text: 'Hi! How can we help you today?',
//       isUser: false,
//       timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
//     ),
//   ];

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty){
//         return;
//     }

//     setState(() {
//       messages.add(ChatMessage(
//         text: _messageController.text,
//         isUser: true,
//         timestamp: DateTime.now(),
//       ));
//     });

//     _messageController.clear();

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         setState(() {
//           messages.add(ChatMessage(
//             text: 'Thank you for your message. Our team will get back to you shortly.',
//             isUser: false,
//             timestamp: DateTime.now(),
//           ));
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => context.pop(context),
//         ),
//         title: const Text(
//           'Lagroce Support',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         centerTitle: false,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final message = messages[index];
//                 return _buildMessageBubble(message);
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border(
//                 top: BorderSide(color: Colors.grey[300]!),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                       hintStyle: TextStyle(color: Colors.grey[400]),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(24),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(24),
//                         borderSide: BorderSide(color: Colors.grey[300]!),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(24),
//                         borderSide: const BorderSide(
//                           color: Color(0xFFE97C3C),
//                         ),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 GestureDetector(
//                   onTap: _sendMessage,
//                   child: Container(
//                     height: 44,
//                     width: 44,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE97C3C),
//                       borderRadius: BorderRadius.circular(22),
//                     ),
//                     child: const Icon(
//                       Icons.send,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(ChatMessage message) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Align(
//         alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
//         child: Container(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.75,
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           decoration: BoxDecoration(
//             color: message.isUser
//                 ? const Color(0xFFE97C3C)
//                 : Colors.grey[200],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             message.text,
//             style: TextStyle(
//               color: message.isUser ? Colors.white : Colors.black,
//               fontSize: 14,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isUser;
//   final DateTime timestamp;

//   ChatMessage({
//     required this.text,
//     required this.isUser,
//     required this.timestamp,
//   });
// }
