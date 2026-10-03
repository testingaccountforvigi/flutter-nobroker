import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String roomUrl;
  final String token;
  final String callId;
  final String otherUserId;
  final String otherUserName;
  final bool isOutgoing;

  const CallScreen({
    super.key,
    required this.roomUrl,
    required this.token,
    required this.callId,
    required this.otherUserId,
    required this.otherUserName,
    this.isOutgoing = true,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  Room? _room;
  bool _isMuted = false;
  bool _isConnecting = true;
  String _callStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    try {
      _room = Room();

      // Set up event listeners before connecting
      _room!.addListener(_onRoomUpdate);

      // Connect to the room
      await _room!.connect(
        widget.roomUrl,
        widget.token,
        roomOptions: const RoomOptions(
          defaultAudioPublishOptions: AudioPublishOptions(
            dtx: true,
          ),
        ),
      );

      // Enable audio
      await _room!.localParticipant?.setMicrophoneEnabled(true);

      setState(() {
        _isConnecting = false;
        _callStatus = widget.isOutgoing ? 'Calling...' : 'Connected';
      });

      // Wait for remote participant
      _checkForRemoteParticipant();
    } catch (e) {
      print('Failed to connect: $e');
      setState(() {
        _isConnecting = false;
        _callStatus = 'Connection failed';
      });
    }
  }

  void _checkForRemoteParticipant() {
    if (_room != null && _room!.remoteParticipants.isNotEmpty) {
      setState(() {
        _callStatus = 'In call';
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _room != null) {
          _checkForRemoteParticipant();
        }
      });
    }
  }

  void _onRoomUpdate() {
    if (_room != null && _room!.remoteParticipants.isNotEmpty) {
      setState(() {
        _callStatus = 'In call';
      });
    }
  }

  Future<void> _toggleMute() async {
    if (_room == null) return;
    
    final enabled = !_isMuted;
    await _room!.localParticipant!.setMicrophoneEnabled(enabled);
    
    setState(() {
      _isMuted = !enabled;
    });
  }

  Future<void> _endCall() async {
    await _room?.disconnect();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _room?.removeListener(_onRoomUpdate);
    _room?.disconnect();
    _room?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _endCall,
                  ),
                  const Spacer(),
                  Text(
                    _callStatus,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const Spacer(),

            // User Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFD4735A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.otherUserName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // User Name
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Call Duration or Status
            if (_isConnecting)
              const CircularProgressIndicator(color: Colors.white70)
            else
              Text(
                _room?.remoteParticipants.isNotEmpty ?? false
                    ? 'Connected'
                    : 'Waiting...',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

            const Spacer(),

            // Call Controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute Button
                  _CallButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    color: _isMuted ? Colors.red : Colors.white24,
                    onPressed: _toggleMute,
                  ),

                  // End Call Button
                  _CallButton(
                    icon: Icons.call_end,
                    label: 'End Call',
                    color: Colors.red,
                    size: 72,
                    iconSize: 36,
                    onPressed: _endCall,
                  ),

                  // Speaker Button (placeholder)
                  _CallButton(
                    icon: Icons.volume_up,
                    label: 'Speaker',
                    color: Colors.white24,
                    onPressed: () {
                      // Speaker toggle would go here
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.size = 64,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
