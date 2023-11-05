import 'package:flutter/material.dart';
import 'package:flutter8/theme/colors.dart';
import 'package:flutter8/theme/spacers.dart';

class ProfileScreenWidget extends StatefulWidget {
  const ProfileScreenWidget(this.id, this.name, this.avatar, {super.key});

  final String id;
  final String name;
  final String avatar;

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(width: double.infinity),
            _avatarSection(),
            const Spacer1(),
            Text(widget.name, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _avatarSection() => Container(
      width: 100,
      height: 100,
      decoration: widget.name.isEmpty
          ? const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)
          : BoxDecoration(
              color: Colors.orange,
              image: DecorationImage(image: NetworkImage(widget.avatar), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(50),
            ),
      child: widget.avatar.isEmpty
          ? Center(
              child: Text(widget.name.substring(0, 1), style: const TextStyle(fontSize: 32)),
            )
          : const SizedBox.shrink());
}
