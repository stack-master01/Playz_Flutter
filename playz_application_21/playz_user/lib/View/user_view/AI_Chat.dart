import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';
// Note: Removed imports for Firestore, Notifiers, SharedPreferences, etc.,
// as they are not used in the Gemini API chat logic.

// ⚠️ Replace with your valid key
const String geminiApiKey = "AIzaSyAIqRzXGO72L94qsjQGKbkbW6163ujXITM";
const String geminiModel = "gemini-2.5-flash";
String get apiUrl =>
    "https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey";

// --- Dummy/Placeholder for Reusable Functions/Colors (MUST BE PROVIDED IN YOUR PROJECT) ---
// In a real app, you would import these from your 'reusable.dart'

// ------------------------------------------------------------------

class ChatMessage {
  final String role;
  final String content;
  final DateTime dateTime; // Added to show message time

  ChatMessage({
    required this.role,
    required this.content,
    required this.dateTime,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _sending = false;
  // Simplified dark mode/theme check based on a local state for UI adaptation

  // Placeholder for the group name/image structure from FriendChat
  String _groupNameKey = "AI Assistant";
  String _groupImage =
      "https://via.placeholder.com/50/FFC107/000000?text=AI"; // Placeholder image

  Future<void> _sendMessage(String userInput) async {
    if (userInput.trim().isEmpty || _sending) return;

    final now = DateTime.now();
    setState(() {
      _sending = true;
      _messages.add(
        ChatMessage(role: "user", content: userInput.trim(), dateTime: now),
      );
    });

    // ✅ Build Gemini request body with system instruction
    final Map<String, dynamic> requestBody = {
      "contents": [
        ..._messages.map(
          (m) => {
            "role": m.role == "assistant" ? "model" : m.role,
            "parts": [
              {"text": m.content},
            ],
          },
        ),
      ],
      "systemInstruction": {
        "parts": [
          {"text": "You are a helpful assistant. Keep responses concise."},
        ],
      },
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            (data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
                    'No reply')
                .toString()
                .trim();

        setState(() {
          _messages.add(
            ChatMessage(
              role: "assistant",
              content: reply,
              dateTime: DateTime.now(),
            ),
          );
          final List<dynamic> playerMap = jsonDecode(reply);
          log("Fetched map data: ${playerMap}");
          // Note: JSON parsing of map data removed as it's not relevant for simple AI chat.
        });
      } else {
        log('Response (${response.statusCode}): ${response.body}');
        String errorContent;
        switch (response.statusCode) {
          case 400:
            errorContent =
                'Error: Bad request. The input may be too long or invalid.';
            break;
          case 401:
            errorContent =
                'Error: Invalid API key. Please check your Gemini API key.';
            break;
          case 429:
            errorContent =
                'Error: Rate limit exceeded. Please try again later.';
            break;
          case 500:
            errorContent =
                'Error: Gemini server error. Please try again later.';
            break;
          default:
            errorContent =
                'Error: Failed to connect to AI. Status ${response.statusCode}';
        }
        setState(() {
          _messages.add(
            ChatMessage(
              role: "assistant",
              content: errorContent,
              dateTime: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        log("Error: ${e}");
      });
    } finally {
      setState(() {
        _sending = false;
      });
      _controller.clear();
    }
  }

  void _clearChat() => setState(() => _messages.clear());

  // Placeholder for theme loading

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await ThemeSettings(
      theme: null,
    ).loadSelectedTheme();
    appSettingsNotifier.value = ThemeSettings(theme: selectedTheme);
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
    // Simulating the group info structure for the header
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on the simplified dark mode check

    final inputHintKey =
        "Type a Message"; // Reusing a key concept, though not translated here
    final pinnedMessageKey = "AI Chat Context"; // Placeholder
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier,
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          body: Stack(
            children: [
              // ✅ Green header (Adapted from FriendChat)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(
                        context,
                      ).padding.top, // Use actual top padding
                      left: 10,
                      right: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                size: 25,
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              child: Row(
                                children: [
                                  SizedBox(width: 10),
                                  Text(
                                    _groupNameKey, // Static AI Name
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Actions like clear chat can go here instead of AppBar
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: _clearChat,
                          color: isDark
                              ? Reusable.getDarkModeBlack()
                              : Reusable.getWhite(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ✅ White bottom sheet for chat (Adapted from FriendChat)
              Positioned(
                top: 110, // Positioned below the header
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Reusable.getDarkModeBlack()
                        : Reusable.getWhite(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage(
                              isDark
                                  ? "assets/Images/dark1.png"
                                  : "assets/Images/light1_upscaled.png",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Positioned elements on top of the background sheet
              Positioned(
                top: 110,
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  children: [
                    // Pinned message container placeholder (Commented out as it's not relevant for simple AI chat)
                    // ... (Pinned message logic from FriendChat)
                    const SizedBox(height: 20),

                    // 🔹 Chat messages ListView (Adapted from FriendChat StreamBuilder)
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 20,
                        ),
                        reverse: true, // Display latest message at the bottom
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[_messages.length - 1 - index];
                          final isUser = msg.role == "user";

                          // Determine message time format (e.g., "10:30 AM")
                          final String formattedTime = DateFormat(
                            'jm',
                          ).format(msg.dateTime);

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen()
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(
                                      isUser ? 20 : 0,
                                    ),
                                    bottomRight: Radius.circular(
                                      isUser ? 0 : 20,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isUser)
                                      const Text(
                                        "AI Assistant", // Static sender name for AI
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    Text(
                                      msg.content, // AI/User message content
                                      style: TextStyle(
                                        color: isUser
                                            ? isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite()
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          formattedTime, // Message time
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    if (_sending)
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getGreen(),
                        ),
                      ),

                    // Message input field (Adapted from FriendChat)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Container(
                          height: 60,
                          width:
                              MediaQuery.of(context).size.width *
                              0.9, // Use width based on screen size
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                            ),
                            cursorColor: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getGreen(),
                            decoration: InputDecoration(
                              hintText:
                                  "Ask something...", // Replaced translation concept
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getDarkGrey(),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                              suffixIcon: GestureDetector(
                                onTap: () async {
                                  await _sendMessage(_controller.text);
                                  // No need to clear local message list, API call handles it
                                },
                                child: Icon(
                                  Icons.send,
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                  size: 30,
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons
                                    .add_circle_outline, // Kept the icon from the original UI
                                color: Colors
                                    .grey, // Changed color as this feature isn't fully implemented here
                                size: 30,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Reusable.getLightGrey(),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom > 0
                          ? 0
                          : 15,
                    ), // Space above SafeArea boundary if needed
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Generate a JSON array containing multiple warm-up exercises specifically designed for playing football (soccer). Each object in the array must strictly adhere to the following structure: {"exercise": "name of exercise", "no of repetetions": "number or duration", "how to do it": "steps to perform"}. Return only this JSON array, with absolutely no preceding or succeeding text, explanations, or markdown formatting (like code fences).

//Generate a JSON array containing multiple warm-up exercises specifically designed for playing football (soccer). Each object in the array must strictly adhere to the following structure: {"exercise": "name of exercise", "no of repetetions": "number or duration", "how to do it": "steps to perform"}. Return only this JSON array, with absolutely no preceding or succeeding text, explanations, or markdown formatting (like code fences).
