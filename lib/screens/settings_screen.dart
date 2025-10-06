
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            // Mock UI for now - controls are disabled.
            SwitchListTile(
              title: Text('Dark Mode'),
              value: false,
              onChanged: null, // Disabled
            ),
            Divider(),
            ListTile(
              title: Text('Font Size'),
              subtitle: Slider(
                value: 1.0,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                label: '1.0',
                onChanged: null, // Disabled
              ),
            ),
            Divider(),
            SwitchListTile(
              title: Text('Enable Notifications'),
              value: false,
              onChanged: null, // Disabled
            ),
          ],
        ),
      ),
    );
  }
}
